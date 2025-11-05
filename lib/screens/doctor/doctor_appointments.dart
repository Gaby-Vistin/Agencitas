import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart' as doctor_models;

class DoctorAppointments extends StatefulWidget {
  final String doctorId;

  const DoctorAppointments({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  List<Patient> _patients = [];
  
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
      // Simulación de carga de citas del doctor
      await Future.delayed(const Duration(seconds: 1));
      
      // En una aplicación real, filtrarías por doctor ID
      // final appointments = await db.getAppointmentsByDoctor(widget.doctorId);
      
      setState(() {
        _appointments = _generateSampleAppointments();
        _patients = _generateSamplePatients();
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

  // Método para generar citas de ejemplo
  List<Appointment> _generateSampleAppointments() {
    final today = DateTime.now();
    return [
      // Citas de hoy
      Appointment(
        id: 1,
        patientId: 1,
        doctorId: 1,
        appointmentDate: today,
        appointmentTime: doctor_models.TimeOfDay(hour: 9, minute: 0),
        status: AppointmentStatus.scheduled,
        stage: AppointmentStage.first,
        therapyStatus: TherapyStatus.notStarted,
        notes: 'Primera consulta',
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 2,
        patientId: 2,
        doctorId: 1,
        appointmentDate: today,
        appointmentTime: doctor_models.TimeOfDay(hour: 10, minute: 30),
        status: AppointmentStatus.scheduled,
        stage: AppointmentStage.second,
        therapyStatus: TherapyStatus.inProgress,
        notes: 'Seguimiento de tratamiento',
        createdAt: DateTime.now(),
      ),
      // Citas programadas
      Appointment(
        id: 3,
        patientId: 3,
        doctorId: 1,
        appointmentDate: today.add(const Duration(days: 1)),
        appointmentTime: doctor_models.TimeOfDay(hour: 14, minute: 0),
        status: AppointmentStatus.scheduled,
        stage: AppointmentStage.first,
        therapyStatus: TherapyStatus.notStarted,
        createdAt: DateTime.now(),
      ),
      // Citas canceladas
      Appointment(
        id: 4,
        patientId: 4,
        doctorId: 1,
        appointmentDate: today.subtract(const Duration(days: 1)),
        appointmentTime: doctor_models.TimeOfDay(hour: 11, minute: 0),
        status: AppointmentStatus.cancelled,
        stage: AppointmentStage.first,
        therapyStatus: TherapyStatus.notStarted,
        cancellationReason: 'Paciente enfermo',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Patient> _generateSamplePatients() {
    return [
      Patient(
        id: 1,
        name: 'Juan',
        lastName: 'Pérez',
        identification: '12345678',
        email: 'juan.perez@email.com',
        phone: '555-0001',
        birthDate: DateTime(1985, 5, 15),
        address: 'Calle 123 #45-67',
        isFromProvince: false,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 2,
        name: 'María',
        lastName: 'García',
        identification: '87654321',
        email: 'maria.garcia@email.com',
        phone: '555-0002',
        birthDate: DateTime(1990, 8, 22),
        address: 'Carrera 89 #12-34',
        isFromProvince: true,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 3,
        name: 'Carlos',
        lastName: 'López',
        identification: '11223344',
        email: 'carlos.lopez@email.com',
        phone: '555-0003',
        birthDate: DateTime(1978, 12, 3),
        address: 'Avenida 56 #78-90',
        isFromProvince: false,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 4,
        name: 'Ana',
        lastName: 'Martínez',
        identification: '55667788',
        email: 'ana.martinez@email.com',
        phone: '555-0004',
        birthDate: DateTime(1992, 3, 18),
        address: 'Diagonal 23 #45-67',
        isFromProvince: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<Appointment> get _todayAppointments {
    final today = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.appointmentDate.year == today.year &&
             appointment.appointmentDate.month == today.month &&
             appointment.appointmentDate.day == today.day &&
             appointment.status == AppointmentStatus.scheduled;
    }).toList();
  }

  List<Appointment> get _scheduledAppointments {
    return _appointments.where((appointment) {
      return appointment.status == AppointmentStatus.scheduled;
    }).toList();
  }

  List<Appointment> get _pendingAppointments {
    return _appointments.where((appointment) {
      return appointment.status == AppointmentStatus.scheduled &&
             appointment.therapyStatus == TherapyStatus.notStarted;
    }).toList();
  }

  List<Appointment> get _cancelledAppointments {
    return _appointments.where((appointment) {
      return appointment.status == AppointmentStatus.cancelled;
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
          // Resumen de citas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Hoy', _todayAppointments.length, Colors.blue),
                _buildSummaryItem('Programadas', _scheduledAppointments.length, Colors.green),
                _buildSummaryItem('Pendientes', _pendingAppointments.length, Colors.orange),
                _buildSummaryItem('Canceladas', _cancelledAppointments.length, Colors.red),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.green[800],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green[800],
            tabs: const [
              Tab(text: 'Hoy'),
              Tab(text: 'Programadas'),
              Tab(text: 'En Espera'),
              Tab(text: 'Canceladas'),
            ],
          ),

          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_todayAppointments, 'Hoy'),
                _buildAppointmentsList(_scheduledAppointments, 'Programadas'),
                _buildAppointmentsList(_pendingAppointments, 'En Espera'),
                _buildAppointmentsList(_cancelledAppointments, 'Canceladas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay citas $type',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
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
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final patient = _patients.firstWhere(
      (p) => p.id == appointment.patientId,
      orElse: () => Patient(
        id: 0,
        name: 'Paciente',
        lastName: 'Desconocido',
        identification: '00000000',
        email: '',
        phone: '',
        birthDate: DateTime.now(),
        address: '',
        isFromProvince: false,
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar del paciente
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del paciente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${patient.identification}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (patient.isFromProvince)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Provincia',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Estado de la terapia
                _buildTherapyStatusIndicator(appointment.therapyStatus),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de la cita
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                _buildStatusChip(appointment.status),
              ],
            ),
            
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (appointment.cancellationReason?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Motivo: ${appointment.cancellationReason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Acciones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPatientDetails(patient),
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('Ver Paciente'),
                  ),
                ),
                const SizedBox(width: 8),
                if (appointment.status == AppointmentStatus.scheduled) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateTherapyStatus(appointment),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Estado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleAppointmentAction(appointment, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Completar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cancelar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(
                          children: [
                            Icon(Icons.schedule),
                            SizedBox(width: 8),
                            Text('Reprogramar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapyStatusIndicator(TherapyStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              color: status.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String label;

    switch (status) {
      case AppointmentStatus.scheduled:
        color = Colors.blue;
        label = 'Programada';
        break;
      case AppointmentStatus.completed:
        color = Colors.green;
        label = 'Completada';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
      case AppointmentStatus.noShow:
        color = Colors.orange;
        label = 'No se presentó';
        break;
      case AppointmentStatus.rescheduled:
        color = Colors.purple;
        label = 'Reprogramada';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paciente: ${patient.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Identificación', patient.identification),
              _buildDetailItem('Email', patient.email),
              _buildDetailItem('Teléfono', patient.phone),
              _buildDetailItem('Dirección', patient.address),
              _buildDetailItem('Fecha de Nacimiento', 
                '${patient.birthDate.day}/${patient.birthDate.month}/${patient.birthDate.year}'),
              _buildDetailItem('Es de Provincia', patient.isFromProvince ? 'Sí' : 'No'),
            ],
          ),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _updateTherapyStatus(Appointment appointment) {
    TherapyStatus? newStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado de Terapia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TherapyStatus.values.map((status) {
            return RadioListTile<TherapyStatus>(
              title: Row(
                children: [
                  Icon(status.icon, color: status.color, size: 20),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
              value: status,
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value;
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: newStatus != null ? () {
              Navigator.pop(context);
              _updateAppointmentTherapyStatus(appointment, newStatus!);
            } : null,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _updateAppointmentTherapyStatus(Appointment appointment, TherapyStatus newStatus) {
    // Aquí actualizarías la base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado de terapia actualizado a: ${newStatus.displayName}'),
        backgroundColor: newStatus.color,
      ),
    );
    _loadAppointments(); // Recargar datos
  }

  void _handleAppointmentAction(Appointment appointment, String action) {
    switch (action) {
      case 'complete':
        _completeAppointment(appointment);
        break;
      case 'cancel':
        _cancelAppointment(appointment);
        break;
      case 'reschedule':
        _rescheduleAppointment(appointment);
        break;
    }
  }

  void _completeAppointment(Appointment appointment) {
    // Implementar completar cita
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cita marcada como completada'),
        backgroundColor: Colors.green,
      ),
    );
    _loadAppointments();
  }

  void _cancelAppointment(Appointment appointment) {
    String reason = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Está seguro que desea cancelar esta cita?'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => reason = value,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar cancelación con el motivo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cita cancelada${reason.isNotEmpty ? ': $reason' : ''}'),
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

  void _rescheduleAppointment(Appointment appointment) {
    // Implementar reprogramación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de reprogramación pendiente'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}