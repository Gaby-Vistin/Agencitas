import 'package:flutter/material.dart';
import '../../models/patient.dart';

class DoctorPatients extends StatefulWidget {
  final String doctorId;

  const DoctorPatients({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<DoctorPatients> createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  bool _isLoading = true;
  List<Patient> _patients = [];
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
      // Simulación de carga de pacientes asignados al doctor
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _patients = _generateSamplePatients();
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

  List<Patient> _generateSamplePatients() {
    return [
      Patient(
        id: 1,
        name: 'Juan Carlos',
        lastName: 'Pérez González',
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
        name: 'María Elena',
        lastName: 'García López',
        identification: '87654321',
        email: 'maria.garcia@email.com',
        phone: '555-0002',
        birthDate: DateTime(1990, 8, 22),
        address: 'Carrera 89 #12-34',
        isFromProvince: true,
        currentStage: AppointmentStage.second,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 3,
        name: 'Carlos Alberto',
        lastName: 'López Martínez',
        identification: '11223344',
        email: 'carlos.lopez@email.com',
        phone: '555-0003',
        birthDate: DateTime(1978, 12, 3),
        address: 'Avenida 56 #78-90',
        isFromProvince: false,
        currentStage: AppointmentStage.third,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 4,
        name: 'Ana Patricia',
        lastName: 'Martínez Rivera',
        identification: '55667788',
        email: 'ana.martinez@email.com',
        phone: '555-0004',
        birthDate: DateTime(1992, 3, 18),
        address: 'Diagonal 23 #45-67',
        isFromProvince: true,
        missedAppointments: 1,
        createdAt: DateTime.now(),
      ),
      Patient(
        id: 5,
        name: 'Roberto',
        lastName: 'Silva Ramírez',
        identification: '99887766',
        email: 'roberto.silva@email.com',
        phone: '555-0005',
        birthDate: DateTime(1980, 11, 25),
        address: 'Transversal 45 #67-89',
        isFromProvince: false,
        isActive: false,
        createdAt: DateTime.now(),
      ),
    ];
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
        case 'missed':
          filtered = filtered.where((patient) => patient.missedAppointments > 0).toList();
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
              color: Colors.green[50],
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
                          DropdownMenuItem(value: 'missed', child: Text('Con Faltas')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_filteredPatients.length} paciente(s) asignado(s)',
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
                                  ? 'No hay pacientes asignados'
                                  : 'No se encontraron pacientes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
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
    // Calcular edad
    final age = DateTime.now().difference(patient.birthDate).inDays ~/ 365;
    
    // Simular próxima cita
    final hasUpcomingAppointment = patient.id! % 3 == 0; // Simulación
    final daysSinceLastVisit = 5 + (patient.id! % 15); // Simulación

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
                  backgroundColor: Colors.green[100],
                  child: Text(
                    patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
            
            // Estado del tratamiento y próxima cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Etapa: ${_getStageText(patient.currentStage)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Última visita: hace $daysSinceLastVisit días',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasUpcomingAppointment)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Próxima cita',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            if (patient.missedAppointments > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Citas perdidas: ${patient.missedAppointments}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
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
                    onPressed: () => _showPatientHistory(patient),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('Historial'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPatientAppointments(patient),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Citas'),
                  ),
                ),
                const SizedBox(width: 8),
                if (patient.isActive && patient.canScheduleAppointment)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleAppointment(patient),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Agendar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
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

  void _showPatientHistory(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historial - ${patient.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Información Personal', [
                  _buildInfoItem('Identificación', patient.identification),
                  _buildInfoItem('Email', patient.email),
                  _buildInfoItem('Teléfono', patient.phone),
                  _buildInfoItem('Dirección', patient.address),
                  _buildInfoItem('Fecha de Nacimiento', 
                    '${patient.birthDate.day}/${patient.birthDate.month}/${patient.birthDate.year}'),
                  _buildInfoItem('Es de Provincia', patient.isFromProvince ? 'Sí' : 'No'),
                ]),
                
                const SizedBox(height: 16),
                
                _buildInfoSection('Estado del Tratamiento', [
                  _buildInfoItem('Etapa Actual', _getStageText(patient.currentStage)),
                  _buildInfoItem('Citas Perdidas', patient.missedAppointments.toString()),
                  _buildInfoItem('Estado', patient.isActive ? 'Activo' : 'Inactivo'),
                  _buildInfoItem('Fecha de Registro', 
                    '${patient.createdAt.day}/${patient.createdAt.month}/${patient.createdAt.year}'),
                ]),
                
                const SizedBox(height: 16),
                
                _buildInfoSection('Notas Médicas', [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      'Paciente en seguimiento regular. Evolución positiva en el tratamiento. Recomendado continuar con terapia según protocolo establecido.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ]),
              ],
            ),
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
              _addNoteToPatient(patient);
            },
            child: const Text('Agregar Nota'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientAppointments(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Citas - ${patient.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              const Text('Historial de citas del paciente:'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildAppointmentHistoryItem('15/10/2024', '09:00', 'Completada', Colors.green),
                    _buildAppointmentHistoryItem('08/10/2024', '14:30', 'Completada', Colors.green),
                    _buildAppointmentHistoryItem('01/10/2024', '10:00', 'Cancelada', Colors.red),
                    _buildAppointmentHistoryItem('24/09/2024', '11:15', 'Completada', Colors.green),
                  ],
                ),
              ),
            ],
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

  Widget _buildAppointmentHistoryItem(String date, String time, String status, Color color) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: color, size: 20),
      title: Text('$date - $time'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
      SnackBar(
        content: Text('Agendar cita para ${patient.fullName}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            // Implementar navegación a agenda
          },
        ),
      ),
    );
  }

  void _addNoteToPatient(Patient patient) {
    String note = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nota - ${patient.fullName}'),
        content: TextField(
          onChanged: (value) => note = value,
          decoration: const InputDecoration(
            labelText: 'Nota médica',
            border: OutlineInputBorder(),
            hintText: 'Escriba sus observaciones...',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (note.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nota agregada al historial'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
