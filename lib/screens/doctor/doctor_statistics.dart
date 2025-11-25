import 'package:flutter/material.dart';

class DoctorStatistics extends StatefulWidget {
  final String doctorId;

  const DoctorStatistics({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<DoctorStatistics> createState() => _DoctorStatisticsState();
}

class _DoctorStatisticsState extends State<DoctorStatistics> {
  bool _isLoading = true;
  
  // Estadísticas del doctor
  int _totalPatients = 0;
  int _todayAppointments = 0;
  int _weeklyAppointments = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;
  int _scheduledAppointments = 0;
  
  // Estadísticas de terapias
  int _therapiesNotStarted = 0;
  int _therapiesInProgress = 0;
  int _therapiesCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de datos del doctor específico
      await Future.delayed(const Duration(milliseconds: 300));
      
      // En una aplicación real, aquí filtrarías por doctor ID
      // final appointments = await db.getAppointmentsByDoctor(widget.doctorId);
      // final patients = await db.getPatientsByDoctor(widget.doctorId);
      
      setState(() {
        // Datos simulados para el doctor
        _totalPatients = 25;
        _todayAppointments = 6;
        _weeklyAppointments = 28;
        _completedAppointments = 180;
        _cancelledAppointments = 12;
        _scheduledAppointments = 15;
        
        _therapiesNotStarted = 8;
        _therapiesInProgress = 12;
        _therapiesCompleted = 5;
        
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar estadísticas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              _buildWelcomeCard(),
              
              const SizedBox(height: 24),
              
              Text(
                'Resumen de Hoy',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              
              // Estadísticas de hoy
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Citas Hoy',
                      _todayAppointments.toString(),
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Esta Semana',
                      _weeklyAppointments.toString(),
                      Icons.calendar_view_week,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Mis Pacientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              
              // Estadísticas de pacientes
              _buildStatCard(
                'Total de Pacientes Asignados',
                _totalPatients.toString(),
                Icons.people,
                Colors.green,
                isWide: true,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Estado de Terapias',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              
              // Semáforo de terapias del doctor
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTherapyStatusItem(
                          'Sin Iniciar',
                          _therapiesNotStarted,
                          Colors.red,
                          Icons.play_circle_outline,
                        ),
                        _buildTherapyStatusItem(
                          'En Progreso',
                          _therapiesInProgress,
                          Colors.orange,
                          Icons.pending,
                        ),
                        _buildTherapyStatusItem(
                          'Completadas',
                          _therapiesCompleted,
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progreso visual
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          if (_therapiesNotStarted > 0)
                            Expanded(
                              flex: _therapiesNotStarted,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          if (_therapiesInProgress > 0)
                            Expanded(
                              flex: _therapiesInProgress,
                              child: Container(
                                color: Colors.orange,
                              ),
                            ),
                          if (_therapiesCompleted > 0)
                            Expanded(
                              flex: _therapiesCompleted,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Estado de Citas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              
              // Estadísticas de citas
              Row(
                children: [
                  Expanded(
                    child: _buildAppointmentStatusCard(
                      'Programadas',
                      _scheduledAppointments,
                      Colors.blue,
                      Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAppointmentStatusCard(
                      'Completadas',
                      _completedAppointments,
                      Colors.green,
                      Icons.check,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAppointmentStatusCard(
                      'Canceladas',
                      _cancelledAppointments,
                      Colors.red,
                      Icons.cancel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Buenos días';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[700]!,
            Colors.green[500]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            greetingIcon,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tienes $_todayAppointments citas programadas hoy',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTherapyStatusItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            icon,
            size: 30,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
