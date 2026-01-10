
//INTERFAZ DE AGENDAR CITAS


import 'package:agencitas/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/logout_button.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await _appointmentService.getAllAppointments();
      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

  // Filtrar citas según el estado seleccionado
  List<Appointment> get _filteredAppointments {
    switch (_selectedFilter) {
      case 'scheduled':
        return _appointments
            .where((a) => a.status == AppointmentStatus.scheduled)
            .toList();
      case 'completed':
        return _appointments
            .where((a) => a.status == AppointmentStatus.completed)
            .toList();
      case 'cancelled':
        return _appointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .toList();
      case 'noShow':
        return _appointments
            .where((a) => a.status == AppointmentStatus.noShow)
            .toList();
      case 'today':
        final today = DateTime.now();
        return _appointments.where((a) {
          final appointmentDate = a.appointmentDate;
          return appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
        }).toList();
      default:
        return _appointments;
    }
  }

  // Mostrar acciones disponibles para una cita
  Future<void> _showAppointmentActions(Appointment appointment) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Acciones para la cita',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (appointment.status == AppointmentStatus.scheduled) ...[
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Marcar como Completada'),
                onTap: () {
                  Navigator.pop(context);
                  _completeAppointment(appointment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_off, color: Colors.red),
                title: const Text('Marcar como No se Presentó'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsNoShow(appointment);
                },
              ),
              if (appointment.canBeCancelled)
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.orange),
                  title: const Text('Cancelar Cita'),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelAppointment(appointment);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Marcar una cita como completada
  Future<void> _completeAppointment(Appointment appointment) async {
    try {
      await _appointmentService.completeAppointment(appointment.id!);
      await _loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita marcada como completada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Marcar una cita como no se presentó
  Future<void> _markAsNoShow(Appointment appointment) async {
    try {
      await _appointmentService.markAppointmentAsNoShow(appointment.id!);
      await _loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita marcada como no se presentó'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Cancelar una cita con motivo
  Future<void> _cancelAppointment(Appointment appointment) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cancelar Cita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Está seguro de que desea cancelar esta cita?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Motivo de cancelación',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      try {
        await _appointmentService.cancelAppointment(
          appointment.id!,
          reason.isNotEmpty ? reason : 'Cancelado por el usuario',
        );
        await _loadAppointments();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAppointmentActions(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: appointment.status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      // Usar getter seguro para mostrar siempre el nombre
                      appointment.patientFullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appointment.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status.displayName,
                      style: TextStyle(
                        color: appointment.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Detalles de la cita
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dr. ${appointment.doctorFullName} - ${appointment.doctor?.specialty ?? ''}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              // Fecha y hora de la cita
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'es_ES')
                        .format(appointment.appointmentDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.appointmentTime.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment.stage.displayName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
              if (appointment.isPastDue &&
                  appointment.status == AppointmentStatus.scheduled) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cita vencida - Se marcará automáticamente como no presentado',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        title: const Text('Lista de Citas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          LogoutButton(),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _selectedFilter == 'all',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'all';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Hoy'),
                    selected: _selectedFilter == 'today',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'today';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Programadas'),
                    selected: _selectedFilter == 'scheduled',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'scheduled';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Completadas'),
                    selected: _selectedFilter == 'completed',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'completed';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Canceladas'),
                    selected: _selectedFilter == 'cancelled',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'cancelled';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('No se presentó'),
                    selected: _selectedFilter == 'noShow',
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = 'noShow';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Appointments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'all'
                                  ? 'No hay citas registradas'
                                  : 'No hay citas con este filtro',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(
                                _filteredAppointments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
