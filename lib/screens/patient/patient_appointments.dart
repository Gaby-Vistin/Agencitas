import 'package:flutter/material.dart';
import '../../models/appointment.dart';

// Modelo simplificado para las citas del paciente
class PatientAppointment {
  final String id;
  final String doctorName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final TherapyStatus therapyStatus;
  final String specialty;
  final String reason;
  final String location;
  final String notes;
  final bool isFromProvince;
  final String? province;
  final String? referralCode;

  PatientAppointment({
    required this.id,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.therapyStatus,
    required this.specialty,
    required this.reason,
    this.location = '',
    this.notes = '',
    this.isFromProvince = false,
    this.province,
    this.referralCode,
  });
}

class PatientAppointments extends StatefulWidget {
  final String patientId;

  const PatientAppointments({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<PatientAppointment> _appointments = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de citas del paciente
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _appointments = _generateSampleAppointments();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar citas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<PatientAppointment> _generateSampleAppointments() {
    final now = DateTime.now();
    return [
      PatientAppointment(
        id: '1',
        doctorName: 'Dr. María García',
        appointmentDate: now.add(const Duration(days: 1)),
        appointmentTime: '10:00',
        status: AppointmentStatus.scheduled,
        therapyStatus: TherapyStatus.notStarted,
        specialty: 'Cardiología',
        reason: 'Consulta de control',
        location: 'Consultorio 201',
        notes: 'Control de presión arterial y seguimiento cardiovascular',
        isFromProvince: false, // Paciente de Pichincha
      ),
      PatientAppointment(
        id: '2',
        doctorName: 'Dr. Carlos Rodríguez',
        appointmentDate: now.add(const Duration(days: 7)),
        appointmentTime: '14:30',
        status: AppointmentStatus.scheduled,
        therapyStatus: TherapyStatus.notStarted,
        specialty: 'Neurología',
        reason: 'Seguimiento neurológico',
        location: 'Consultorio 105',
        notes: 'Seguimiento de cefaleas tensionales',
        isFromProvince: true, // Paciente de provincia
        province: 'Guayas',
        referralCode: '09',
      ),
      PatientAppointment(
        id: '3',
        doctorName: 'Dr. María García',
        appointmentDate: now.subtract(const Duration(days: 7)),
        appointmentTime: '09:00',
        status: AppointmentStatus.completed,
        therapyStatus: TherapyStatus.completed,
        specialty: 'Cardiología',
        reason: 'Consulta inicial',
        location: 'Consultorio 201',
        notes: 'Primera consulta cardiovascular completada',
        isFromProvince: false,
      ),
      PatientAppointment(
        id: '4',
        doctorName: 'Dra. Ana Martínez',
        appointmentDate: now.subtract(const Duration(days: 14)),
        appointmentTime: '11:00',
        status: AppointmentStatus.completed,
        therapyStatus: TherapyStatus.inProgress,
        specialty: 'Fisioterapia',
        reason: 'Terapia física',
        location: 'Sala de Fisioterapia',
        notes: 'Sesión 8/15 - Rehabilitación de rodilla',
        isFromProvince: true,
        province: 'Azuay',
        referralCode: '01',
      ),
      PatientAppointment(
        id: '5',
        doctorName: 'Dr. Luis Fernández',
        appointmentDate: now.add(const Duration(days: 14)),
        appointmentTime: '15:00',
        status: AppointmentStatus.scheduled,
        therapyStatus: TherapyStatus.notStarted,
        specialty: 'Medicina General',
        reason: 'Consulta general',
        location: 'Consultorio 302',
        notes: 'Evaluación médica general',
        isFromProvince: true,
        province: 'Manabí',
        referralCode: '13',
      ),
    ];
  }

  List<PatientAppointment> get _upcomingAppointments {
    final now = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.appointmentDate.isAfter(now) && 
             appointment.status == AppointmentStatus.scheduled;
    }).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  List<PatientAppointment> get _todayAppointments {
    final now = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.appointmentDate.year == now.year &&
             appointment.appointmentDate.month == now.month &&
             appointment.appointmentDate.day == now.day;
    }).toList();
  }

  List<PatientAppointment> get _pastAppointments {
    final now = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.appointmentDate.isBefore(now);
    }).toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  List<PatientAppointment> get _pendingAppointments {
    return _appointments.where((appointment) {
      return appointment.status == AppointmentStatus.cancelled; // Usar cancelled en lugar de pending
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header con botón para nueva cita
          _buildHeader(),
          
          // Tabs para diferentes vistas
          TabBar(
            controller: _tabController,
            labelColor: Colors.green[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.green[700],
            tabs: [
              Tab(text: 'Próximas (${_upcomingAppointments.length})'),
              Tab(text: 'Hoy (${_todayAppointments.length})'),
              Tab(text: 'Historial (${_pastAppointments.length})'),
              Tab(text: 'Pendientes (${_pendingAppointments.length})'),
            ],
          ),
          
          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_upcomingAppointments, 'upcoming'),
                _buildAppointmentsList(_todayAppointments, 'today'),
                _buildAppointmentsList(_pastAppointments, 'past'),
                _buildAppointmentsList(_pendingAppointments, 'pending'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scheduleNewAppointment,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Mis Citas Médicas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tus citas y consultas médicas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Resumen rápido
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Próximas',
                  _upcomingAppointments.length.toString(),
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Completadas',
                  _pastAppointments.length.toString(),
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Pendientes',
                  _pendingAppointments.length.toString(),
                  Icons.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
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
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<PatientAppointment> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(type),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(type),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (type == 'upcoming') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _scheduleNewAppointment,
                icon: const Icon(Icons.add),
                label: const Text('Agendar Primera Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index], type);
        },
      ),
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'today':
        return Icons.today;
      case 'past':
        return Icons.history;
      case 'pending':
        return Icons.pending_actions;
      default:
        return Icons.calendar_today;
    }
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'today':
        return 'No tienes citas para hoy';
      case 'past':
        return 'No tienes historial de citas';
      case 'pending':
        return 'No tienes citas pendientes';
      default:
        return 'No tienes citas próximas';
    }
  }

  Widget _buildAppointmentCard(PatientAppointment appointment, String type) {
    final isToday = type == 'today';
    final isPast = type == 'past';
    final isPending = type == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y doctor
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: _getStatusColor(appointment.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.specialty,
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
                    Text(
                      _formatDate(appointment.appointmentDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      appointment.appointmentTime,
                      style: TextStyle(
                        color: isToday ? Colors.red[600] : Colors.grey[600],
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Motivo de la cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información adicional
            if (appointment.location.isNotEmpty || appointment.isFromProvince) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (appointment.location.isNotEmpty) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.location,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (appointment.location.isNotEmpty && appointment.isFromProvince)
                    const SizedBox(width: 16),
                  if (appointment.isFromProvince) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map,
                            size: 12,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Provincia: ${appointment.province ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            
            // Notas adicionales
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (isPast) ...[
              const SizedBox(height: 12),
              // Estado de la terapia para citas pasadas
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: _getTherapyStatusColor(appointment.therapyStatus),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terapia: ${_getTherapyStatusText(appointment.therapyStatus)}',
                    style: TextStyle(
                      color: _getTherapyStatusColor(appointment.therapyStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isPast && !isPending) ...[
                  TextButton.icon(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _rescheduleAppointment(appointment),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Reprogramar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[600],
                    ),
                  ),
                ],
                if (isPending) ...[
                  TextButton.icon(
                    onPressed: () => _confirmAppointment(appointment),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Confirmar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[600],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _viewAppointmentDetails(appointment),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
      case AppointmentStatus.rescheduled:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.person_off;
      case AppointmentStatus.rescheduled:
        return Icons.update;
    }
  }

  Color _getTherapyStatusColor(TherapyStatus status) {
    switch (status) {
      case TherapyStatus.notStarted:
        return Colors.red;
      case TherapyStatus.inProgress:
        return Colors.orange;
      case TherapyStatus.completed:
        return Colors.green;
    }
  }

  String _getTherapyStatusText(TherapyStatus status) {
    switch (status) {
      case TherapyStatus.notStarted:
        return 'No iniciada';
      case TherapyStatus.inProgress:
        return 'En progreso';
      case TherapyStatus.completed:
        return 'Completada';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 0) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _scheduleNewAppointment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentBookingScreen(patientId: widget.patientId),
      ),
    ).then((result) {
      if (result == true) {
        _loadAppointments(); // Recargar citas si se agendó una nueva
      }
    });
  }

  void _cancelAppointment(PatientAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Text('¿Está seguro que desea cancelar la cita con ${appointment.doctorName}?'),
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
                  content: Text('Cita cancelada correctamente'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadAppointments();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(PatientAppointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reprogramar cita con ${appointment.doctorName}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _confirmAppointment(PatientAppointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cita confirmada con ${appointment.doctorName}'),
        backgroundColor: Colors.green,
      ),
    );
    _loadAppointments();
  }

  void _viewAppointmentDetails(PatientAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Doctor:', appointment.doctorName),
            _buildDetailRow('Especialidad:', appointment.specialty),
            _buildDetailRow('Fecha:', _formatDate(appointment.appointmentDate)),
            _buildDetailRow('Hora:', appointment.appointmentTime),
            if (appointment.location.isNotEmpty)
              _buildDetailRow('Ubicación:', appointment.location),
            _buildDetailRow('Motivo:', appointment.reason),
            if (appointment.notes.isNotEmpty)
              _buildDetailRow('Notas:', appointment.notes),
            _buildDetailRow('Estado:', appointment.status.toString().split('.').last),
            if (appointment.isFromProvince) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map, size: 16, color: Colors.orange[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Paciente de Provincia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (appointment.province != null)
                      Text('Provincia: ${appointment.province}'),
                    if (appointment.referralCode != null)
                      Text('Código de referencia: ${appointment.referralCode}'),
                  ],
                ),
              ),
            ],
            if (appointment.status == AppointmentStatus.completed)
              _buildDetailRow('Terapia:', _getTherapyStatusText(appointment.therapyStatus)),
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
}

// Pantalla para agendar nueva cita
class AppointmentBookingScreen extends StatefulWidget {
  final String patientId;

  const AppointmentBookingScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSpecialty;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isLoading = false;
  bool _isFromProvince = false;
  String? _selectedProvince;
  String? _referralCode;
  
  List<String> _specialties = [
    'Cardiología',
    'Neurología',
    'Pediatría',
    'Fisioterapia',
    'Medicina General',
    'Dermatología',
  ];
  
  Map<String, List<DoctorInfo>> _doctorsBySpecialty = {
    'Cardiología': [
      DoctorInfo('Dr. María García', 'doctor1'),
      DoctorInfo('Dr. Roberto Silva', 'doctor2'),
    ],
    'Neurología': [
      DoctorInfo('Dr. Carlos Rodríguez', 'doctor3'),
    ],
    'Pediatría': [
      DoctorInfo('Dra. Ana Martínez', 'doctor4'),
    ],
    'Fisioterapia': [
      DoctorInfo('Dr. Luis Hernández', 'doctor5'),
    ],
    'Medicina General': [
      DoctorInfo('Dra. Carmen López', 'doctor6'),
    ],
    'Dermatología': [
      DoctorInfo('Dr. Fernando Cruz', 'doctor7'),
    ],
  };
  
  List<String> _availableTimes = [
    '08:00', '09:00', '10:00', '11:00',
    '14:00', '15:00', '16:00', '17:00',
  ];
  
  List<String> _ecuadorianProvinces = [
    'Azuay',
    'Bolívar',
    'Cañar',
    'Carchi',
    'Cotopaxi',
    'Chimborazo',
    'El Oro',
    'Esmeraldas',
    'Guayas',
    'Imbabura',
    'Loja',
    'Los Ríos',
    'Manabí',
    'Morona Santiago',
    'Napo',
    'Pastaza',
    'Pichincha',
    'Tungurahua',
    'Zamora Chinchipe',
    'Galápagos',
    'Sucumbíos',
    'Orellana',
    'Santo Domingo de los Tsáchilas',
    'Santa Elena',
  ];

  String? _getProvinceCode(String? province) {
    if (province == null) return null;
    
    // Usar los mismos códigos numéricos que ya tiene el sistema
    Map<String, String> provinceCodes = {
      'Azuay': '01',
      'Bolívar': '02',
      'Cañar': '03',
      'Carchi': '04',
      'Cotopaxi': '05',
      'Chimborazo': '06',
      'El Oro': '07',
      'Esmeraldas': '08',
      'Guayas': '09',
      'Imbabura': '10',
      'Loja': '11',
      'Los Ríos': '12',
      'Manabí': '13',
      'Morona Santiago': '14',
      'Napo': '15',
      'Pastaza': '16',
      'Pichincha': '17',
      'Tungurahua': '18',
      'Zamora Chinchipe': '19',
      'Galápagos': '20',
      'Sucumbíos': '21',
      'Orellana': '22',
      'Santo Domingo de los Tsáchilas': '24',
      'Santa Elena': '26',
    };
    
    return provinceCodes[province];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Nueva Cita'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Asignación Automática',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'El sistema asignará automáticamente el médico disponible según la especialidad y fecha seleccionada.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Especialidad
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              value: _selectedSpecialty,
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialty = value;
                  // Reset doctor selection cuando cambia la especialidad
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor seleccione una especialidad';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Fecha
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha preferida',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Hora preferida
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Hora preferida',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              value: _selectedTime,
              items: _availableTimes.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTime = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Información de origen del paciente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Origen',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Soy paciente de provincia'),
                      subtitle: const Text('Requiere código de referencia específico'),
                      value: _isFromProvince,
                      onChanged: (value) {
                        setState(() {
                          _isFromProvince = value ?? false;
                          if (!_isFromProvince) {
                            _selectedProvince = null;
                            _referralCode = null;
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (_isFromProvince) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Provincia de origen',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        value: _selectedProvince,
                        items: _ecuadorianProvinces.map((province) {
                          return DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProvince = value;
                            // Generar código de referencia basado en la provincia
                            _referralCode = _getProvinceCode(value);
                          });
                        },
                        validator: (value) {
                          if (_isFromProvince && value == null) {
                            return 'Debe seleccionar su provincia de origen';
                          }
                          return null;
                        },
                      ),
                      if (_referralCode != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Código de referencia generado: $_referralCode',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Motivo
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Motivo de la consulta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Guardar el motivo localmente si es necesario
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el motivo de la consulta';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Información del médico asignado
            if (_selectedSpecialty != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Médico Asignado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getAssignedDoctor(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Botón de agendar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _scheduleAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Agendar Cita',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getAssignedDoctor() {
    if (_selectedSpecialty == null) return 'Seleccione una especialidad';
    
    final doctors = _doctorsBySpecialty[_selectedSpecialty!] ?? [];
    if (doctors.isEmpty) return 'No hay doctores disponibles';
    
    // Simular asignación automática basada en disponibilidad
    final availableDoctor = doctors.first; // En la práctica, se verificaría disponibilidad real
    return '${availableDoctor.name} - $_selectedSpecialty';
  }

  Future<void> _scheduleAppointment() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular proceso de agendamiento
      await Future.delayed(const Duration(seconds: 2));
      
      // Aquí se realizaría la lógica real de asignación automática
      final assignedDoctor = _getAssignedDoctor();
      
      String successMessage = 'Cita agendada correctamente con $assignedDoctor';
      if (_isFromProvince && _selectedProvince != null) {
        successMessage += '\nPaciente de provincia: $_selectedProvince (Código: $_referralCode)';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      
      Navigator.of(context).pop(true); // Retornar true para indicar éxito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agendar cita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class DoctorInfo {
  final String name;
  final String id;
  
  DoctorInfo(this.name, this.id);
}