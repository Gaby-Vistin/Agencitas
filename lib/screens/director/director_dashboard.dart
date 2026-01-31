import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'director_statistics.dart';
import 'director_appointments.dart';
import 'director_doctors.dart';
import 'director_patients.dart';
import 'director_therapy_status.dart';
import 'director_schedules.dart';
import 'director_users.dart';
import '../change_password_screen.dart';

class DirectorDashboard extends StatefulWidget {
  final User director;

  const DirectorDashboard({
    Key? key,
    required this.director,
  }) : super(key: key);

  @override
  State<DirectorDashboard> createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends State<DirectorDashboard> {
  int _selectedIndex = 0;
  
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DirectorStatistics(),
      const DirectorAppointments(),
      const DirectorDoctors(),
      const DirectorPatients(),
      const DirectorTherapyStatus(),
      const DirectorSchedules(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Director - ${widget.director.displayName}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: _showUsersManagement,
            tooltip: 'Gestión de Usuarios',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(user: widget.director),
                  ),
                );
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Cambiar Contraseña'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index < 5) {
            setState(() {
              _selectedIndex = index;
            });
          } else {
            // Para la sexta pestaña (Horarios), mostrar como modal
            _showSchedulesModal();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Médicos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.traffic),
            label: 'Semáforo',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSchedulesModal,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.schedule),
        label: const Text('Horarios'),
        tooltip: 'Ver horarios de médicos',
      ),
    );
  }

  void _showSchedulesModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Horarios de Médicos'),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          body: const DirectorSchedules(),
        ),
      ),
    );
  }

  void _showUsersManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DirectorUsers(),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                SessionManager.logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
