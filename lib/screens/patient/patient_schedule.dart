import 'package:flutter/material.dart';

class PatientSchedule extends StatefulWidget {
  final String patientId;

  const PatientSchedule({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientSchedule> createState() => _PatientScheduleState();
}

class _PatientScheduleState extends State<PatientSchedule> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<ScheduleEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de agenda del paciente
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _events = _generateSampleEvents();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar agenda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ScheduleEvent> _generateSampleEvents() {
    final now = DateTime.now();
    return [
      ScheduleEvent(
        id: '1',
        title: 'Cita con Dr. García',
        description: 'Consulta cardiológica de control',
        date: now.add(const Duration(days: 1)),
        time: '10:00',
        type: EventType.appointment,
        doctorName: 'Dr. María García',
        location: 'Consultorio 201',
      ),
      ScheduleEvent(
        id: '2',
        title: 'Recordatorio: Medicación',
        description: 'Tomar medicamento para la presión',
        date: now,
        time: '08:00',
        type: EventType.medication,
        isRecurring: true,
      ),
      ScheduleEvent(
        id: '3',
        title: 'Examen de laboratorio',
        description: 'Análisis de sangre completo',
        date: now.add(const Duration(days: 3)),
        time: '07:30',
        type: EventType.test,
        location: 'Laboratorio - Planta Baja',
      ),
      ScheduleEvent(
        id: '4',
        title: 'Fisioterapia',
        description: 'Sesión de rehabilitación',
        date: now.add(const Duration(days: 2)),
        time: '15:00',
        type: EventType.therapy,
        doctorName: 'Dr. Luis Hernández',
        location: 'Sala de Fisioterapia',
      ),
      ScheduleEvent(
        id: '5',
        title: 'Recordatorio: Ejercicios',
        description: 'Rutina de ejercicios recomendada',
        date: now,
        time: '18:00',
        type: EventType.exercise,
        isRecurring: true,
      ),
    ];
  }

  List<ScheduleEvent> get _todayEvents {
    final today = DateTime.now();
    return _events.where((event) {
      return event.date.year == today.year &&
             event.date.month == today.month &&
             event.date.day == today.day;
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  List<ScheduleEvent> get _upcomingEvents {
    final today = DateTime.now();
    return _events.where((event) {
      return event.date.isAfter(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSchedule,
        child: CustomScrollView(
          slivers: [
            // Header con calendario
            _buildCalendarHeader(),
            
            // Eventos de hoy
            if (_todayEvents.isNotEmpty) ...[
              _buildSectionHeader('Hoy'),
              _buildEventsList(_todayEvents),
            ],
            
            // Próximos eventos
            if (_upcomingEvents.isNotEmpty) ...[
              _buildSectionHeader('Próximos Eventos'),
              _buildEventsList(_upcomingEvents),
            ],
            
            // Si no hay eventos
            if (_todayEvents.isEmpty && _upcomingEvents.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes eventos programados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return SliverToBoxAdapter(
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mi Agenda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _showCalendarPicker,
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  tooltip: 'Seleccionar fecha',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Resumen del día
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem(
                    'Hoy',
                    _todayEvents.length.toString(),
                    Icons.today,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Próximos',
                    _upcomingEvents.length.toString(),
                    Icons.upcoming,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Total',
                    _events.length.toString(),
                    Icons.event,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<ScheduleEvent> events) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildEventCard(events[index]),
          );
        },
        childCount: events.length,
      ),
    );
  }

  Widget _buildEventCard(ScheduleEvent event) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Indicador de tipo de evento
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getEventColor(event.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            
            // Icono del evento
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Contenido del evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (event.isRecurring)
                            const Icon(
                              Icons.repeat,
                              size: 16,
                              color: Colors.orange,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            event.time,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (event.doctorName != null || event.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (event.doctorName != null) ...[
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.doctorName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (event.location != null)
                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                        ],
                        if (event.location != null) ...[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Botón de acciones
            IconButton(
              onPressed: () => _showEventActions(event),
              icon: const Icon(Icons.more_vert),
              tooltip: 'Opciones',
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.appointment:
        return Colors.blue;
      case EventType.medication:
        return Colors.red;
      case EventType.test:
        return Colors.purple;
      case EventType.therapy:
        return Colors.green;
      case EventType.exercise:
        return Colors.orange;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.appointment:
        return Icons.medical_services;
      case EventType.medication:
        return Icons.medication;
      case EventType.test:
        return Icons.biotech;
      case EventType.therapy:
        return Icons.healing;
      case EventType.exercise:
        return Icons.fitness_center;
    }
  }

  void _showCalendarPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      // Aquí podrías filtrar eventos por la fecha seleccionada
    }
  }

  void _showEventActions(ScheduleEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (event.type == EventType.appointment) ...[
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('Ver Detalles'),
                onTap: () {
                  Navigator.pop(context);
                  _viewEventDetails(event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Modificar Cita'),
                onTap: () {
                  Navigator.pop(context);
                  _modifyAppointment(event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancelar Cita'),
                onTap: () {
                  Navigator.pop(context);
                  _cancelEvent(event);
                },
              ),
            ],
            
            if (event.type == EventType.medication) ...[
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Marcar como Tomado'),
                onTap: () {
                  Navigator.pop(context);
                  _markMedicationTaken(event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.orange),
                title: const Text('Posponer Recordatorio'),
                onTap: () {
                  Navigator.pop(context);
                  _postponeReminder(event);
                },
              ),
            ],
            
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.purple),
              title: const Text('Configurar Recordatorio'),
              onTap: () {
                Navigator.pop(context);
                _configureReminder(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewEventDetails(ScheduleEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Fecha:', '${event.date.day}/${event.date.month}/${event.date.year}'),
            _buildDetailRow('Hora:', event.time),
            _buildDetailRow('Descripción:', event.description),
            if (event.doctorName != null)
              _buildDetailRow('Doctor:', event.doctorName!),
            if (event.location != null)
              _buildDetailRow('Ubicación:', event.location!),
            if (event.isRecurring)
              _buildDetailRow('Repetición:', 'Evento recurrente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _modifyAppointment(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modificar cita: ${event.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelEvent(ScheduleEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Evento'),
        content: Text('¿Está seguro que desea cancelar "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evento cancelado'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadSchedule(); // Recargar eventos
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _markMedicationTaken(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medicación "${event.title}" marcada como tomada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _postponeReminder(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recordatorio de "${event.title}" pospuesto 30 minutos'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _configureReminder(ScheduleEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configurar recordatorio para: ${event.title}'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

enum EventType {
  appointment,
  medication,
  test,
  therapy,
  exercise,
}

class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final EventType type;
  final String? doctorName;
  final String? location;
  final bool isRecurring;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    this.doctorName,
    this.location,
    this.isRecurring = false,
  });
}