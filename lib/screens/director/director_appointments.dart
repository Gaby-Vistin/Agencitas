import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart';

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
        email: '',
        phone: '',
        birthDate: DateTime.now(),
        address: '',
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
