import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';
import '../widgets/logout_button.dart';
import 'patient_registration_screen.dart';
import 'patient_list_screen.dart';
import 'doctor_list_screen.dart';
import 'appointment_scheduling_screen.dart';
import 'appointment_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _totalPatients = 0;
  int _todayAppointments = 0;
  int _activePatients = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final patients = await _dbService.getAllPatients();
      final appointments = await _dbService.getAllAppointments();

      final today = DateTime.now();
      final todayAppointments = appointments.where((a) {
        final appointmentDate = a.appointmentDate;
        return appointmentDate.year == today.year &&
            appointmentDate.month == today.month &&
            appointmentDate.day == today.day &&
            a.status == AppointmentStatus.scheduled;
      }).length;

      if (mounted) {
        setState(() {
          _totalPatients = patients.length;
          _activePatients = patients.where((p) => p.isActive).length;
          _todayAppointments = todayAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido
            children: [
              Icon(
                icon,
                size: 36, // Reducido de 48 a 36
                color: color,
              ),
              const SizedBox(height: 8), // Reducido de 12 a 8
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  // Cambiado de headlineMedium a headlineSmall
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2), // Reducido de 4 a 2
              Flexible(
                // Agregado Flexible para evitar overflow
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall, // Cambiado de bodyMedium a bodySmall
                  textAlign: TextAlign.center,
                  overflow: TextOverflow
                      .ellipsis, // Agregar ellipsis para texto largo
                  maxLines: 2, // Máximo 2 líneas
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencitas - Sistema de Citas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: const [LogoutButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Dashboard Statistics
              Text(
                'Resumen del Sistema',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Detectar si estamos en web y ajustar el layout
                    bool isWeb = constraints.maxWidth > 600;
                    int crossAxisCount = isWeb
                        ? 4
                        : 2; // 4 columnas en web, 2 en móvil
                    double childAspectRatio = isWeb
                        ? 1.3
                        : 1.0; // Más ancho en web

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: isWeb ? 20 : 12,
                      mainAxisSpacing: isWeb ? 20 : 12,
                      children: [
                        _buildDashboardCard(
                          title: 'Total Pacientes',
                          value: _totalPatients.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PatientListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: 'Pacientes Activos',
                          value: _activePatients.toString(),
                          icon: Icons.person,
                          color: Colors.green,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PatientListScreen(
                                  showOnlyActive: true,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: 'Citas Hoy',
                          value: _todayAppointments.toString(),
                          icon: Icons.today,
                          color: Colors.orange,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: 'Doctores',
                          value: '3',
                          icon: Icons.medical_services,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DoctorListScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20), // Reducido de 32 a 20
              // Action Buttons
              Text(
                'Acciones Principales',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                title: 'Registrar Paciente',
                subtitle: 'Agregar un nuevo paciente al sistema',
                icon: Icons.person_add,
                color: Colors.blue,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PatientRegistrationScreen(),
                    ),
                  );
                  _loadDashboardData(); // Refresh data
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Agendar Cita',
                subtitle: 'Programar una nueva cita médica',
                icon: Icons.calendar_today,
                color: Colors.green,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentSchedulingScreen(),
                    ),
                  );
                  _loadDashboardData(); // Refresh data
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Ver Citas',
                subtitle: 'Consultar todas las citas programadas',
                icon: Icons.list_alt,
                color: Colors.orange,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Lista de Doctores',
                subtitle: 'Ver información de todos los doctores',
                icon: Icons.medical_services,
                color: Colors.purple,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DoctorListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Information Card
              Card(
                color: Colors.amber.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Información Importante',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Los pacientes deben completar las citas en orden (1ra, 2da, 3ra etapa)',
                      ),
                      const Text(
                        '• Pacientes de provincia requieren código de referencia',
                      ),
                      const Text(
                        '• Después de 2 faltas, el paciente debe reiniciar el proceso',
                      ),
                      const Text(
                        '• Las citas se marcan automáticamente como "no presentado" después del horario',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
