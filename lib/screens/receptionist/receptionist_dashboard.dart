import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'receptionist_doctors.dart';
import 'receptionist_patients.dart';
//import 'receptionist_appointments.dart';
import '../change_password_screen.dart';

class ReceptionistDashboard extends StatefulWidget {
  final User receptionist;

  const ReceptionistDashboard({
    Key? key,
    required this.receptionist,
  }) : super(key: key);

  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
  int _selectedIndex = 0;
  
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      //const ReceptionistAppointments(),
      const ReceptionistPatients(),
      const ReceptionistDoctors(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recepción - ${widget.receptionist.displayName}'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(user: widget.receptionist),
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
        selectedItemColor: Colors.purple[700],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Médicos',
          ),
        ],
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
