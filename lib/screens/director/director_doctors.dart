import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../doctor_edit_screen.dart';

class DirectorDoctors extends StatefulWidget {
  const DirectorDoctors({Key? key}) : super(key: key);

  @override
  State<DirectorDoctors> createState() => _DirectorDoctorsState();
}

class _DirectorDoctorsState extends State<DirectorDoctors> {
  bool _isLoading = true;
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de datos
      // En una aplicación real, aquí cargarías desde la base de datos
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _doctors = []; // Cargar desde la base de datos
        _appointments = []; // Cargar desde la base de datos
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar médicos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    
    return _doctors.where((doctor) {
      return doctor.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             doctor.license.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda
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
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar médicos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_filteredDoctors.length} médico(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDoctorDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Médico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de médicos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No hay médicos registrados'
                                  : 'No se encontraron médicos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddDoctorDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar Primer Médico'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDoctors,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _filteredDoctors[index];
                            return _buildDoctorCard(doctor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    // Calcular estadísticas del médico
    final doctorAppointments = _appointments.where((a) => a.doctorId == doctor.id).toList();
    final todayAppointments = doctorAppointments.where((appointment) {
      final today = DateTime.now();
      return appointment.appointmentDate.year == today.year &&
             appointment.appointmentDate.month == today.month &&
             appointment.appointmentDate.day == today.day;
    }).length;

    final completedAppointments = doctorAppointments.where((a) => a.status == AppointmentStatus.completed).length;

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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Licencia: ${doctor.license}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: doctor.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: doctor.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    doctor.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 12,
                      color: doctor.isActive ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de contacto
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        doctor.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Estadísticas del médico
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Citas Hoy', todayAppointments.toString(), Icons.today),
                  _buildStatItem('Total Citas', doctorAppointments.length.toString(), Icons.calendar_month),
                  _buildStatItem('Completadas', completedAppointments.toString(), Icons.check_circle),
                  _buildStatItem('Duración', '${doctor.appointmentDuration} min', Icons.timer),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Acciones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDoctorSchedule(doctor),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Horarios'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDoctorAppointments(doctor),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Citas'),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleDoctorAction(doctor, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: doctor.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            doctor.isActive ? Icons.block : Icons.check_circle,
                            color: doctor.isActive ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            doctor.isActive ? 'Desactivar' : 'Activar',
                            style: TextStyle(
                              color: doctor.isActive ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!doctor.isActive)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue[700],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Médico'),
        content: const Text('Esta funcionalidad abrirá un formulario para registrar un nuevo médico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDoctorForm();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showDoctorForm() {
    // Aquí implementarías el formulario completo para agregar/editar médico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de formulario de médico pendiente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDoctorSchedule(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Horarios - ${doctor.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (doctor.schedule.isEmpty)
                const Text('No hay horarios configurados')
              else
                ...doctor.schedule.map((schedule) => ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(schedule.dayOfWeek.toString()),
                  subtitle: Text('${schedule.startTime} - ${schedule.endTime}'),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar edición de horarios
            },
            child: const Text('Editar Horarios'),
          ),
        ],
      ),
    );
  }

  void _showDoctorAppointments(Doctor doctor) {
    final doctorAppointments = _appointments.where((a) => a.doctorId == doctor.id).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Citas - ${doctor.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: doctorAppointments.isEmpty
              ? const Center(child: Text('No hay citas programadas'))
              : ListView.builder(
                  itemCount: doctorAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = doctorAppointments[index];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('${appointment.appointmentDate.day}/${appointment.appointmentDate.month}'),
                      subtitle: Text('${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}'),
                      trailing: Chip(
                        label: Text(appointment.status.toString().split('.').last),
                        backgroundColor: _getStatusColor(appointment.status).withOpacity(0.1),
                      ),
                    );
                  },
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

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
      case AppointmentStatus.rescheduled:
        return Colors.purple;
    }
  }

  void _handleDoctorAction(Doctor doctor, String action) {
    switch (action) {
      case 'edit':
        _editDoctor(doctor);
        break;
      case 'activate':
      case 'deactivate':
        _toggleDoctorStatus(doctor);
        break;
      case 'delete':
        _showDeleteConfirmation(doctor);
        break;
    }
  }

  Future<void> _editDoctor(Doctor doctor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorEditScreen(doctor: doctor),
      ),
    );

    if (result == true) {
      _loadDoctors(); // Recargar la lista después de editar
    }
  }

  void _toggleDoctorStatus(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${doctor.isActive ? 'Desactivar' : 'Activar'} Médico'),
        content: Text(
          doctor.isActive
              ? '¿Está seguro que desea desactivar a ${doctor.fullName}? No podrá recibir nuevas citas.'
              : '¿Está seguro que desea activar a ${doctor.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí actualizarías el estado en la base de datos
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Médico ${doctor.isActive ? 'desactivado' : 'activado'}'),
                  backgroundColor: doctor.isActive ? Colors.orange : Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: doctor.isActive ? Colors.orange : Colors.green,
            ),
            child: Text(doctor.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Médico'),
        content: Text(
          '¿Está seguro que desea eliminar a ${doctor.fullName}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí eliminarías el médico de la base de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Médico eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}