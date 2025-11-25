import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../models/appointment.dart';
import '../patient_edit_screen.dart';

class DirectorPatients extends StatefulWidget {
  const DirectorPatients({Key? key}) : super(key: key);

  @override
  State<DirectorPatients> createState() => _DirectorPatientsState();
}

class _DirectorPatientsState extends State<DirectorPatients> {
  bool _isLoading = true;
  List<Patient> _patients = [];
  List<Appointment> _appointments = [];
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de datos
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _patients = []; // Cargar desde la base de datos
        _appointments = []; // Cargar desde la base de datos
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar pacientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Patient> get _filteredPatients {
    List<Patient> filtered = _patients;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((patient) {
        return patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               patient.identification.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               patient.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por estado
    if (_filterStatus != 'all') {
      switch (_filterStatus) {
        case 'active':
          filtered = filtered.where((patient) => patient.isActive).toList();
          break;
        case 'inactive':
          filtered = filtered.where((patient) => !patient.isActive).toList();
          break;
        case 'province':
          filtered = filtered.where((patient) => patient.isFromProvince).toList();
          break;
        case 'local':
          filtered = filtered.where((patient) => !patient.isFromProvince).toList();
          break;
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda y filtros
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
                    hintText: 'Buscar pacientes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos')),
                          DropdownMenuItem(value: 'active', child: Text('Activos')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactivos')),
                          DropdownMenuItem(value: 'province', child: Text('De Provincia')),
                          DropdownMenuItem(value: 'local', child: Text('Locales')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value ?? 'all';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddPatientDialog(),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Nuevo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_filteredPatients.length} paciente(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de pacientes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No hay pacientes registrados'
                                  : 'No se encontraron pacientes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddPatientDialog(),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Registrar Primer Paciente'),
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
                        onRefresh: _loadPatients,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return _buildPatientCard(patient);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    // Calcular estadísticas del paciente
    final patientAppointments = _appointments.where((a) => a.patientId == patient.id).toList();
    final completedAppointments = patientAppointments.where((a) => a.status == AppointmentStatus.completed).length;
    final cancelledAppointments = patientAppointments.where((a) => a.status == AppointmentStatus.cancelled).length;

    // Calcular edad
    final age = DateTime.now().difference(patient.birthDate).inDays ~/ 365;

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
                  backgroundColor: Colors.purple[100],
                  child: Text(
                    patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 18,
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
                      Text(
                        '$age años',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: patient.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: patient.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        patient.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: patient.isActive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (patient.isFromProvince) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Provincia',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                          patient.email,
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
                        patient.phone,
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
            
            // Etapa actual y citas perdidas
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Etapa Actual',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getStageText(patient.currentStage),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: patient.missedAppointments > 0 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: patient.missedAppointments > 0 
                            ? Colors.red.withOpacity(0.3) 
                            : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Citas Perdidas',
                          style: TextStyle(
                            fontSize: 10,
                            color: patient.missedAppointments > 0 ? Colors.red[700] : Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          patient.missedAppointments.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: patient.missedAppointments > 0 ? Colors.red[700] : Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Estadísticas de citas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', patientAppointments.length.toString(), Icons.calendar_month),
                  _buildStatItem('Completadas', completedAppointments.toString(), Icons.check_circle),
                  _buildStatItem('Canceladas', cancelledAppointments.toString(), Icons.cancel),
                  if (patient.referralCode?.isNotEmpty == true)
                    _buildStatItem('Remisión', 'Sí', Icons.medical_services),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Acciones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPatientHistory(patient),
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPatientAppointments(patient),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Citas'),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePatientAction(patient, value),
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
                    const PopupMenuItem(
                      value: 'schedule',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Agendar Cita'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: patient.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            patient.isActive ? Icons.block : Icons.check_circle,
                            color: patient.isActive ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            patient.isActive ? 'Desactivar' : 'Activar',
                            style: TextStyle(
                              color: patient.isActive ? Colors.red : Colors.green,
                            ),
                          ),
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
          size: 16,
          color: Colors.purple[700],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.purple[700],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getStageText(AppointmentStage stage) {
    switch (stage) {
      case AppointmentStage.first:
        return 'Primera';
      case AppointmentStage.second:
        return 'Segunda';
      case AppointmentStage.third:
        return 'Tercera';
    }
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nuevo Paciente'),
        content: const Text('Esta funcionalidad abrirá un formulario para registrar un nuevo paciente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPatientForm();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showPatientForm() {
    // Aquí implementarías el formulario completo para agregar/editar paciente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de formulario de paciente pendiente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showPatientHistory(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historial - ${patient.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem('Identificación', patient.identification),
                _buildInfoItem('Email', patient.email),
                _buildInfoItem('Teléfono', patient.phone),
                _buildInfoItem('Dirección', patient.address),
                _buildInfoItem('Fecha de Nacimiento', 
                  '${patient.birthDate.day}/${patient.birthDate.month}/${patient.birthDate.year}'),
                if (patient.referralCode?.isNotEmpty == true)
                  _buildInfoItem('Código de Remisión', patient.referralCode!),
                _buildInfoItem('Es de Provincia', patient.isFromProvince ? 'Sí' : 'No'),
                _buildInfoItem('Etapa Actual', _getStageText(patient.currentStage)),
                _buildInfoItem('Citas Perdidas', patient.missedAppointments.toString()),
                _buildInfoItem('Estado', patient.isActive ? 'Activo' : 'Inactivo'),
                _buildInfoItem('Fecha de Registro', 
                  '${patient.createdAt.day}/${patient.createdAt.month}/${patient.createdAt.year}'),
              ],
            ),
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

  Widget _buildInfoItem(String label, String value) {
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

  void _showPatientAppointments(Patient patient) {
    final patientAppointments = _appointments.where((a) => a.patientId == patient.id).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Citas - ${patient.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: patientAppointments.isEmpty
              ? const Center(child: Text('No hay citas registradas'))
              : ListView.builder(
                  itemCount: patientAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = patientAppointments[index];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}'),
                      subtitle: Text('${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            label: Text(
                              appointment.status.toString().split('.').last,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getStatusColor(appointment.status).withOpacity(0.1),
                          ),
                        ],
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
          if (patient.canScheduleAppointment)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _scheduleAppointment(patient);
              },
              child: const Text('Nueva Cita'),
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

  void _handlePatientAction(Patient patient, String action) {
    switch (action) {
      case 'edit':
        _editPatient(patient);
        break;
      case 'schedule':
        _scheduleAppointment(patient);
        break;
      case 'activate':
      case 'deactivate':
        _togglePatientStatus(patient);
        break;
    }
  }
  
  Future<void> _editPatient(Patient patient) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientEditScreen(patient: patient),
      ),
    );
    if (result == true) {
      _loadPatients();
    }
  }

  void _scheduleAppointment(Patient patient) {
    if (!patient.canScheduleAppointment) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Puede Agendar'),
          content: Text(
            patient.missedAppointments >= 2
                ? 'El paciente ha perdido ${patient.missedAppointments} citas y no puede agendar nuevas citas.'
                : 'El paciente está inactivo y no puede agendar citas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de agendar cita pendiente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _togglePatientStatus(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${patient.isActive ? 'Desactivar' : 'Activar'} Paciente'),
        content: Text(
          patient.isActive
              ? '¿Está seguro que desea desactivar a ${patient.fullName}? No podrá agendar nuevas citas.'
              : '¿Está seguro que desea activar a ${patient.fullName}?',
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
                  content: Text('Paciente ${patient.isActive ? 'desactivado' : 'activado'}'),
                  backgroundColor: patient.isActive ? Colors.orange : Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: patient.isActive ? Colors.orange : Colors.green,
            ),
            child: Text(patient.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}