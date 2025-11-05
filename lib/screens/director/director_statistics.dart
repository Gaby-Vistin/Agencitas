import 'package:flutter/material.dart';

class DirectorStatistics extends StatefulWidget {
  const DirectorStatistics({Key? key}) : super(key: key);

  @override
  State<DirectorStatistics> createState() => _DirectorStatisticsState();
}

class _DirectorStatisticsState extends State<DirectorStatistics> {
  bool _isLoading = true;
  
  // Estadísticas generales
  int _totalPatients = 0;
  int _totalDoctors = 0;
  int _totalAppointments = 0;
  int _todayAppointments = 0;
  
  // Estadísticas de terapias (semáforo)
  int _therapiesNotStarted = 0;
  int _therapiesInProgress = 0;
  int _therapiesCompleted = 0;
  
  // Estadísticas de citas
  int _scheduledAppointments = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;

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
      // Simular carga de datos desde la base de datos
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo para la demostración
      setState(() {
        _totalPatients = 145;
        _totalDoctors = 12;
        _totalAppointments = 238;
        _todayAppointments = 18;
        
        _therapiesNotStarted = 45;
        _therapiesInProgress = 89;
        _therapiesCompleted = 104;
        
        _scheduledAppointments = 156;
        _completedAppointments = 67;
        _cancelledAppointments = 15;
        
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

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con saludo
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            
            // Resumen general
            _buildGeneralStats(),
            const SizedBox(height: 24),
            
            // Semáforo de terapias
            _buildTherapyTrafficLight(),
            const SizedBox(height: 24),
            
            // Estadísticas de citas
            _buildAppointmentStats(),
            const SizedBox(height: 24),
            
            // Gráfico de progreso
            _buildProgressChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    String greeting = _getTimeBasedGreeting();
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Director del Centro Médico',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Citas hoy: $_todayAppointments',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días, Director';
    } else if (hour < 18) {
      return 'Buenas tardes, Director';
    } else {
      return 'Buenas noches, Director';
    }
  }

  Widget _buildGeneralStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pacientes',
                _totalPatients.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Doctores',
                _totalDoctors.toString(),
                Icons.medical_services,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Citas',
                _totalAppointments.toString(),
                Icons.calendar_today,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Hoy',
                _todayAppointments.toString(),
                Icons.today,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyTrafficLight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semáforo de Terapias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTrafficLightItem(
                    'Sin Iniciar',
                    _therapiesNotStarted,
                    Colors.red,
                    Icons.circle,
                  ),
                  _buildTrafficLightItem(
                    'En Progreso',
                    _therapiesInProgress,
                    Colors.orange,
                    Icons.circle,
                  ),
                  _buildTrafficLightItem(
                    'Completadas',
                    _therapiesCompleted,
                    Colors.green,
                    Icons.circle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (_therapiesCompleted / (_therapiesCompleted + _therapiesInProgress + _therapiesNotStarted)),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
              const SizedBox(height: 8),
              Text(
                '${((_therapiesCompleted / (_therapiesCompleted + _therapiesInProgress + _therapiesNotStarted)) * 100).toStringAsFixed(1)}% de terapias completadas',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficLightItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppointmentStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de Citas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
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
            const SizedBox(width: 12),
            Expanded(
              child: _buildAppointmentStatusCard(
                'Completadas',
                _completedAppointments,
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
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
    );
  }

  Widget _buildAppointmentStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso del Centro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          
          // Eficiencia del centro
          _buildProgressItem(
            'Eficiencia General',
            0.85,
            Colors.blue,
            '85%',
          ),
          const SizedBox(height: 12),
          
          // Satisfacción del paciente
          _buildProgressItem(
            'Satisfacción del Paciente',
            0.92,
            Colors.green,
            '92%',
          ),
          const SizedBox(height: 12),
          
          // Ocupación
          _buildProgressItem(
            'Ocupación de Horarios',
            0.78,
            Colors.orange,
            '78%',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, Color color, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}