import 'package:flutter/material.dart';

class PatientReminders extends StatefulWidget {
  final String patientId;

  const PatientReminders({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientReminders> createState() => _PatientRemindersState();
}

class _PatientRemindersState extends State<PatientReminders> {
  List<ReminderItem> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de recordatorios
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _reminders = _generateReminders();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar recordatorios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ReminderItem> _generateReminders() {
    final now = DateTime.now();
    return [
      // Citas próximas
      ReminderItem(
        id: '1',
        title: 'Cita con Dr. María García',
        description: 'Consulta de seguimiento cardiológico',
        dateTime: now.add(const Duration(days: 2, hours: 10)),
        type: ReminderType.appointment,
        isRead: false,
        priority: ReminderPriority.high,
        canReschedule: true,
        doctorInfo: DoctorInfo('Dr. María García', 'Cardiología'),
      ),
      ReminderItem(
        id: '2',
        title: 'Sesión de Fisioterapia',
        description: 'Rehabilitación de rodilla - Sesión 13/15',
        dateTime: now.add(const Duration(days: 1, hours: 14)),
        type: ReminderType.therapy,
        isRead: false,
        priority: ReminderPriority.medium,
        canReschedule: true,
        therapyInfo: TherapyInfo('Fisioterapia de Rodilla', 13, 15),
      ),
      
      // Medicamentos
      ReminderItem(
        id: '3',
        title: 'Tomar Losartán',
        description: '50mg - Con el desayuno',
        dateTime: now.add(const Duration(hours: 8)),
        type: ReminderType.medication,
        isRead: true,
        priority: ReminderPriority.high,
        isRecurring: true,
        medicationInfo: MedicationInfo('Losartán', '50mg', 'Con el desayuno'),
      ),
      ReminderItem(
        id: '4',
        title: 'Aplicar hielo en rodilla',
        description: 'Terapia de frío durante 15 minutos',
        dateTime: now.add(const Duration(hours: 4)),
        type: ReminderType.treatment,
        isRead: false,
        priority: ReminderPriority.medium,
        isRecurring: true,
      ),
      
      // Exámenes
      ReminderItem(
        id: '5',
        title: 'Análisis de sangre',
        description: 'Laboratorio Central - En ayunas',
        dateTime: now.add(const Duration(days: 5, hours: 8)),
        type: ReminderType.test,
        isRead: false,
        priority: ReminderPriority.medium,
        testInfo: TestInfo('Análisis de sangre completo', 'Laboratorio Central', true),
      ),
      
      // Ejercicios
      ReminderItem(
        id: '6',
        title: 'Ejercicios cardiovasculares',
        description: 'Caminata de 30 minutos',
        dateTime: now.add(const Duration(hours: 2)),
        type: ReminderType.exercise,
        isRead: true,
        priority: ReminderPriority.low,
        isRecurring: true,
        exerciseInfo: ExerciseInfo('Caminata', '30 minutos', 'Intensidad moderada'),
      ),
      
      // Recordatorios pasados
      ReminderItem(
        id: '7',
        title: 'Cita perdida',
        description: 'Consulta con Dr. Carlos Rodríguez',
        dateTime: now.subtract(const Duration(days: 1)),
        type: ReminderType.appointment,
        isRead: false,
        priority: ReminderPriority.high,
        isMissed: true,
        canReschedule: true,
        doctorInfo: DoctorInfo('Dr. Carlos Rodríguez', 'Neurología'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickActions(),
          Expanded(child: _buildRemindersList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    final upcomingCount = _reminders.where((r) => 
      r.dateTime.isAfter(DateTime.now()) && !r.isRead
    ).length;
    
    final missedCount = _reminders.where((r) => r.isMissed && !r.isRead).length;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Recordatorios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mantente al día con tu tratamiento',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Próximos',
                  upcomingCount.toString(),
                  Icons.schedule,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Perdidos',
                  missedCount.toString(),
                  Icons.warning,
                  missedCount > 0 ? Colors.red[300]! : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Hoy',
                  _getTodayRemindersCount().toString(),
                  Icons.today,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _filterReminders(ReminderFilter.today),
              icon: const Icon(Icons.today),
              label: const Text('Hoy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _filterReminders(ReminderFilter.upcoming),
              icon: const Icon(Icons.upcoming),
              label: const Text('Próximos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _filterReminders(ReminderFilter.missed),
              icon: const Icon(Icons.warning),
              label: const Text('Perdidos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    final sortedReminders = _reminders.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedReminders.length,
        itemBuilder: (context, index) {
          return _buildReminderCard(sortedReminders[index]);
        },
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem reminder) {
    final isToday = _isToday(reminder.dateTime);
    final isPast = reminder.dateTime.isBefore(DateTime.now());
    final timeUntil = _getTimeUntilString(reminder.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: reminder.isRead ? 1 : 3,
      color: reminder.isMissed ? Colors.red[50] : null,
      child: InkWell(
        onTap: () => _markAsRead(reminder),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _getReminderIcon(reminder.type),
                    color: _getReminderColor(reminder.type),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: reminder.isRead ? Colors.grey[600] : Colors.black,
                          ),
                        ),
                        if (reminder.description.isNotEmpty)
                          Text(
                            reminder.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(reminder.priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityText(reminder.priority),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(reminder.priority),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!reminder.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información de tiempo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isToday ? Colors.blue[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isToday ? Icons.today : isPast ? Icons.history : Icons.schedule,
                      size: 16,
                      color: isToday ? Colors.blue[600] : isPast ? Colors.red[600] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${reminder.dateTime.day}/${reminder.dateTime.month} a las ${reminder.dateTime.hour.toString().padLeft(2, '0')}:${reminder.dateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isToday ? Colors.blue[700] : Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeUntil,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.red[600] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Información específica del tipo
              if (reminder.doctorInfo != null) ...[
                const SizedBox(height: 8),
                _buildDoctorInfo(reminder.doctorInfo!),
              ],
              
              if (reminder.medicationInfo != null) ...[
                const SizedBox(height: 8),
                _buildMedicationInfo(reminder.medicationInfo!),
              ],
              
              if (reminder.testInfo != null) ...[
                const SizedBox(height: 8),
                _buildTestInfo(reminder.testInfo!),
              ],
              
              if (reminder.therapyInfo != null) ...[
                const SizedBox(height: 8),
                _buildTherapyInfo(reminder.therapyInfo!),
              ],
              
              if (reminder.exerciseInfo != null) ...[
                const SizedBox(height: 8),
                _buildExerciseInfo(reminder.exerciseInfo!),
              ],
              
              // Acciones
              if (reminder.canReschedule || reminder.isMissed) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (reminder.isMissed)
                      TextButton.icon(
                        onPressed: () => _rescheduleReminder(reminder),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Reagendar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange[600],
                        ),
                      ),
                    if (reminder.canReschedule && !reminder.isMissed)
                      TextButton.icon(
                        onPressed: () => _rescheduleReminder(reminder),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Cambiar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _dismissReminder(reminder),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Descartar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              // Indicador de recurrencia
              if (reminder.isRecurring)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.repeat, size: 12, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Recurrente',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(DoctorInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(
            '${info.name} - ${info.specialty}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationInfo(MedicationInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, size: 16, color: Colors.red[600]),
          const SizedBox(width: 8),
          Text(
            '${info.name} ${info.dose} - ${info.instructions}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestInfo(TestInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, size: 16, color: Colors.purple[600]),
              const SizedBox(width: 8),
              Text(
                '${info.testName} - ${info.location}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (info.requiresFasting)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⚠️ Requiere ayuno',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.purple[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTherapyInfo(TherapyInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.healing, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Text(
            '${info.therapyName} - Sesión ${info.currentSession}/${info.totalSessions}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(ExerciseInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            '${info.exerciseName} - ${info.duration} (${info.intensity})',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return Icons.medical_services;
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.test:
        return Icons.science;
      case ReminderType.therapy:
        return Icons.healing;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.treatment:
        return Icons.healing;
    }
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return Colors.green[600]!;
      case ReminderType.medication:
        return Colors.red[600]!;
      case ReminderType.test:
        return Colors.purple[600]!;
      case ReminderType.therapy:
        return Colors.orange[600]!;
      case ReminderType.exercise:
        return Colors.blue[600]!;
      case ReminderType.treatment:
        return Colors.teal[600]!;
    }
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.blue;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
    }
  }

  String _getPriorityText(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return 'Baja';
      case ReminderPriority.medium:
        return 'Media';
      case ReminderPriority.high:
        return 'Alta';
    }
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  String _getTimeUntilString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inDays > 0) {
        return 'Hace ${pastDifference.inDays} día${pastDifference.inDays > 1 ? 's' : ''}';
      } else if (pastDifference.inHours > 0) {
        return 'Hace ${pastDifference.inHours} hora${pastDifference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Hace ${pastDifference.inMinutes} min';
      }
    }
    
    if (difference.inDays > 0) {
      return 'En ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'En ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'En ${difference.inMinutes} min';
    }
  }

  int _getTodayRemindersCount() {
    final now = DateTime.now();
    return _reminders.where((r) => _isToday(r.dateTime)).length;
  }

  void _markAsRead(ReminderItem reminder) {
    setState(() {
      reminder.isRead = true;
    });
  }

  void _filterReminders(ReminderFilter filter) {
    // Implementar filtrado de recordatorios
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filtro ${filter.name} aplicado')),
    );
  }

  void _rescheduleReminder(ReminderItem reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reagendar Recordatorio'),
        content: const Text('¿Desea reagendar este recordatorio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recordatorio reagendado')),
              );
            },
            child: const Text('Reagendar'),
          ),
        ],
      ),
    );
  }

  void _dismissReminder(ReminderItem reminder) {
    setState(() {
      _reminders.remove(reminder);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recordatorio descartado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _reminders.add(reminder);
            });
          },
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo Recordatorio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Próximamente...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelos de datos para recordatorios
class ReminderItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final ReminderType type;
  bool isRead;
  final ReminderPriority priority;
  final bool isRecurring;
  final bool canReschedule;
  final bool isMissed;
  final DoctorInfo? doctorInfo;
  final MedicationInfo? medicationInfo;
  final TestInfo? testInfo;
  final TherapyInfo? therapyInfo;
  final ExerciseInfo? exerciseInfo;

  ReminderItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.isRead = false,
    required this.priority,
    this.isRecurring = false,
    this.canReschedule = false,
    this.isMissed = false,
    this.doctorInfo,
    this.medicationInfo,
    this.testInfo,
    this.therapyInfo,
    this.exerciseInfo,
  });
}

enum ReminderType {
  appointment,
  medication,
  test,
  therapy,
  exercise,
  treatment,
}

enum ReminderPriority {
  low,
  medium,
  high,
}

enum ReminderFilter {
  today,
  upcoming,
  missed,
}

class DoctorInfo {
  final String name;
  final String specialty;

  DoctorInfo(this.name, this.specialty);
}

class MedicationInfo {
  final String name;
  final String dose;
  final String instructions;

  MedicationInfo(this.name, this.dose, this.instructions);
}

class TestInfo {
  final String testName;
  final String location;
  final bool requiresFasting;

  TestInfo(this.testName, this.location, this.requiresFasting);
}

class TherapyInfo {
  final String therapyName;
  final int currentSession;
  final int totalSessions;

  TherapyInfo(this.therapyName, this.currentSession, this.totalSessions);
}

class ExerciseInfo {
  final String exerciseName;
  final String duration;
  final String intensity;

  ExerciseInfo(this.exerciseName, this.duration, this.intensity);
}