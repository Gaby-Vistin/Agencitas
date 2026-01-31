

 // interfaz de las citas que vea el director


import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart';
import '../../models/user.dart';
import '../../services/api_doctores.dart';

class DirectorAppointments extends StatefulWidget {
  const DirectorAppointments({Key? key}) : super(key: key);

  @override
  State<DirectorAppointments> createState() => _DirectorAppointmentsState();
}

class _DirectorAppointmentsState extends State<DirectorAppointments> {
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  List<Patient> _patients = [];
  List<Doctor> _doctors = [];
  String _filterStatus = 'all';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de datos
      // En una aplicación real, aquí cargarías desde la base de datos
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _appointments = []; // Cargar de la base de datos
        _patients = []; // Cargar de la base de datos
        _doctors = []; // Cargar de la base de datos
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

  List<Appointment> get _filteredAppointments {
    List<Appointment> filtered = _appointments;

    // Filtrar por estado
    if (_filterStatus != 'all') {
      AppointmentStatus status;
      switch (_filterStatus) {
        case 'scheduled':
          status = AppointmentStatus.scheduled;
          break;
        case 'completed':
          status = AppointmentStatus.completed;
          break;
        case 'cancelled':
          status = AppointmentStatus.cancelled;
          break;
        default:
          status = AppointmentStatus.scheduled;
      }
      filtered = filtered.where((appointment) => appointment.status == status).toList();
    }

    // Filtrar por fecha
    if (_filterDate != null) {
      filtered = filtered.where((appointment) {
        return appointment.appointmentDate.year == _filterDate!.year &&
               appointment.appointmentDate.month == _filterDate!.month &&
               appointment.appointmentDate.day == _filterDate!.day;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por Estado',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todas')),
                          DropdownMenuItem(value: 'scheduled', child: Text('Programadas')),
                          DropdownMenuItem(value: 'completed', child: Text('Completadas')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Canceladas')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value ?? 'all';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _filterDate != null
                                    ? '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}'
                                    : 'Filtrar por fecha',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_filterDate != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _filterDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar fecha'),
                      ),
                    const Spacer(),
                    Text(
                      '${_filteredAppointments.length} citas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de citas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay citas para mostrar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _filteredAppointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    // Buscar paciente y doctor correspondientes
    final patient = _patients.firstWhere(
      (p) => p.id == appointment.patientId,
      orElse: () => Patient(
        id: 0,
        name: 'Paciente',
        lastName: 'Desconocido',
        identification: '00000000',
        birthDate: DateTime.now(),
        isFromProvince: false,
        createdAt: DateTime.now(),
      ),
    );

    final doctor = _doctors.firstWhere(
      (d) => d.id == appointment.doctorId,
      orElse: () => Doctor(
        id: 0,
        name: 'Doctor',
        lastName: 'Desconocido',
        specialty: '',
        license: '',
        phone: '',
        email: '',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${patient.name} ${patient.lastName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dr. ${doctor.name} ${doctor.lastName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTherapyStatusIndicator(appointment.therapyStatus),
              ],
            ),
            const SizedBox(height: 12),
            
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
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                _buildStatusChip(appointment.status),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAppointmentAction(appointment, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('Ver Detalles'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit_therapy',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Cambiar Estado Terapia'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'change_doctor',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Cambiar Doctor', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    if (appointment.status == AppointmentStatus.scheduled)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cancelar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapyStatusIndicator(TherapyStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case TherapyStatus.notStarted:
        color = Colors.red;
        icon = Icons.play_circle_outline;
        label = 'Sin iniciar';
        break;
      case TherapyStatus.inProgress:
        color = Colors.orange;
        icon = Icons.pending;
        label = 'En progreso';
        break;
      case TherapyStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Completada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _filterDate = date;
      });
    }
  }

  void _handleAppointmentAction(Appointment appointment, String action) {
    switch (action) {
      case 'view':
        _showAppointmentDetails(appointment);
        break;
      case 'edit_therapy':
        _showEditTherapyStatus(appointment);
        break;
      case 'change_doctor':
        _showChangeDoctorDialog(appointment);
        break;
      case 'cancel':
        _showCancelAppointment(appointment);
        break;
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${appointment.id}'),
            Text('Fecha: ${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}'),
            Text('Hora: ${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute}'),
            if (appointment.notes?.isNotEmpty == true)
              Text('Notas: ${appointment.notes}'),
            if (appointment.referralCode?.isNotEmpty == true)
              Text('Código de remisión: ${appointment.referralCode}'),
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

  void _showEditTherapyStatus(Appointment appointment) {
    TherapyStatus newStatus = appointment.therapyStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado de Terapia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TherapyStatus.values.map((status) {
            return RadioListTile<TherapyStatus>(
              title: Text(_getTherapyStatusLabel(status)),
              value: status,
              groupValue: newStatus,
              onChanged: (value) {
                if (value != null) {
                  newStatus = value;
                  Navigator.pop(context, newStatus);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    ).then((result) {
      if (result != null && result != appointment.therapyStatus) {
        _updateTherapyStatus(appointment, result);
      }
    });
  }

  String _getTherapyStatusLabel(TherapyStatus status) {
    switch (status) {
      case TherapyStatus.notStarted:
        return 'Sin iniciar';
      case TherapyStatus.inProgress:
        return 'En progreso';
      case TherapyStatus.completed:
        return 'Completada';
    }
  }

  void _showCancelAppointment(Appointment appointment) {
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
              _cancelAppointment(appointment, reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _updateTherapyStatus(Appointment appointment, TherapyStatus newStatus) {
    // Aquí actualizarías la base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estado de terapia actualizado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showChangeDoctorDialog(Appointment appointment) async {
    // Verificar permisos de director
    if (!SessionManager.isAdminOrDirector()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo el director puede cambiar el doctor de una cita'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cargar lista de doctores
    final apiDoctores = ApiDoctores();
    List<Doctor> availableDoctors = [];
    
    try {
      final response = await apiDoctores.getDoctors();
      availableDoctors = response
          .map<Doctor>((json) => Doctor.fromJson(json))
          .where((doctor) => doctor.isActive && doctor.id != appointment.doctorId)
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar doctores: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (availableDoctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay otros doctores disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentDoctor = _doctors.firstWhere(
      (d) => d.id == appointment.doctorId,
      orElse: () => Doctor(
        id: 0,
        name: 'Desconocido',
        lastName: '',
        specialty: '',
        license: '',
        email: '',
        createdAt: DateTime.now(),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Doctor Asignado'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor actual: Dr. ${currentDoctor.name} ${currentDoctor.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccione el nuevo doctor:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = availableDoctors[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            doctor.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('Dr. ${doctor.fullName}'),
                        subtitle: Text(doctor.specialty),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          _confirmDoctorChange(appointment, currentDoctor, doctor);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmDoctorChange(Appointment appointment, Doctor currentDoctor, Doctor newDoctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cambio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Está seguro de cambiar el doctor asignado?'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('De: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text('Dr. ${currentDoctor.fullName}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text('Dr. ${newDoctor.fullName}')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se notificará al paciente sobre el cambio',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changeDoctorAssignment(appointment, newDoctor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Cambio'),
          ),
        ],
      ),
    );
  }

  void _changeDoctorAssignment(Appointment appointment, Doctor newDoctor) {
    // Aquí actualizarías la base de datos con el nuevo doctor
    // Por ahora solo mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Doctor cambiado a: Dr. ${newDoctor.fullName}'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Recargar datos
    _loadData();
  }

  void _cancelAppointment(Appointment appointment, String reason) {
    // Aquí cancelarías la cita en la base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cita cancelada'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
