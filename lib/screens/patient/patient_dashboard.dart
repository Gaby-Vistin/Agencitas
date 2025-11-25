import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/patient.dart';
import '../../services/database_service.dart';
import 'patient_appointments.dart';
import 'patient_schedule.dart';
import 'patient_history.dart';
import 'patient_reminders.dart';
import '../patient_edit_screen.dart';
import '../change_password_screen.dart';

class PatientDashboard extends StatefulWidget {
  final User patient;

  const PatientDashboard({
    Key? key,
    required this.patient,
  }) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PatientAppointments(patientId: widget.patient.username),
      PatientSchedule(patientId: widget.patient.username),
      PatientHistory(patientId: widget.patient.username),
      PatientReminders(patientId: widget.patient.username),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${widget.patient.displayName}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfile(),
            tooltip: 'Mi Perfil',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(user: widget.patient),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Recordatorios',
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notificaciones'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: [
                _buildNotificationItem(
                  'Recordatorio de Cita',
                  'Su cita con Dr. García es mañana a las 10:00 AM',
                  Icons.schedule,
                  Colors.blue,
                  '2 horas',
                ),
                _buildNotificationItem(
                  'Terapia Completada',
                  'Felicitaciones! Ha completado su sesión de fisioterapia',
                  Icons.check_circle,
                  Colors.green,
                  '1 día',
                ),
                _buildNotificationItem(
                  'Nueva Cita Programada',
                  'Su cita ha sido confirmada para el 15 de noviembre',
                  Icons.event,
                  Colors.orange,
                  '3 días',
                ),
                _buildNotificationItem(
                  'Resultado de Examen',
                  'Los resultados de su examen están disponibles',
                  Icons.assignment,
                  Colors.purple,
                  '1 semana',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 3; // Ir a recordatorios
                });
              },
              child: const Text('Ver Todos'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String content, IconData icon, Color color, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(content),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        // Navegar a la sección correspondiente
      },
    );
  }

  void _showProfile() {
    // Simular datos del paciente con información de provincia
    final isFromProvince = widget.patient.username == 'paciente'; // Para demo
    final patientProvince = isFromProvince ? 'Guayas' : null;
    final referralCode = isFromProvince ? '09' : null;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mi Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileItem('Nombre', widget.patient.displayName),
              _buildProfileItem('Email', widget.patient.email),
              _buildProfileItem('Usuario', widget.patient.username),
              _buildProfileItem('Rol', widget.patient.role.displayName),
              _buildProfileItem('Estado', widget.patient.isActive ? 'Activo' : 'Inactivo'),
              
              const SizedBox(height: 16),
              const Text(
                'Información de Origen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileItem('Tipo de Paciente', isFromProvince ? 'Provincia' : 'Pichincha'),
              if (isFromProvince) ...[
                _buildProfileItem('Provincia de Origen', patientProvince ?? 'N/A'),
                _buildProfileItem('Código de Referencia', referralCode ?? 'N/A'),
              ],
              
              const SizedBox(height: 16),
              const Text(
                'Información Médica',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileItem('Tipo de Sangre', 'O+'),
              _buildProfileItem('Alergias', 'Ninguna conocida'),
              _buildProfileItem('Médico Asignado', 'Dr. María García'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editProfile();
              },
              child: const Text('Editar Perfil'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    // Buscar el paciente completo en la base de datos
    try {
      final dbService = DatabaseService();
      final patients = await dbService.getAllPatients();
      
      // Buscar el paciente que coincida con el email del usuario
      final patient = patients.firstWhere(
        (p) => p.email == widget.patient.email,
        orElse: () => Patient(
          name: widget.patient.displayName.split(' ').first,
          lastName: widget.patient.displayName.split(' ').length > 1 
              ? widget.patient.displayName.split(' ').sublist(1).join(' ')
              : '',
          identification: '0000000000',
          email: widget.patient.email,
          phone: '0000000000',
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
          address: 'No especificada',
          isFromProvince: false,
          createdAt: DateTime.now(),
        ),
      );
      
      if (mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PatientEditScreen(patient: patient),
          ),
        );
        
        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                Navigator.of(context).pushReplacementNamed('/login');
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
