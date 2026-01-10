import 'package:agencitas/services/mysql_service.dart';
import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../patient_edit_screen.dart';

class ReceptionistPatients extends StatefulWidget {
  const ReceptionistPatients({Key? key}) : super(key: key);

  @override
  State<ReceptionistPatients> createState() => _ReceptionistPatientsState();
}

class _ReceptionistPatientsState extends State<ReceptionistPatients> {
  final MySQLDatabaseService _dbService = MySQLDatabaseService();
  bool _isLoading = true;
  List<Patient> _patients = [];
  String _searchQuery = '';

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
      final patients = await _dbService.getAllPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _patients.where((patient) {
      final fullName = '${patient.name} ${patient.lastName}'.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) ||
          patient.identification.contains(query) ||
          patient.phone.contains(query);
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
            color: Colors.purple[50],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nombre, cédula o teléfono...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Estadísticas
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total Pacientes',
                      _patients.length.toString(),
                      Icons.people,
                      Colors.purple[700]!,
                    ),
                    _buildStatItem(
                      'Activos',
                      _patients.where((p) => p.isActive).length.toString(),
                      Icons.person,
                      Colors.green[700]!,
                    ),
                  ],
                ),
              ),
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
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron pacientes',
                              style: TextStyle(
                                fontSize: 16,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewPatientDetails(patient),
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
                      patient.name[0] + patient.lastName[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.name} ${patient.lastName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              patient.identification,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.purple[700]),
                    onPressed: () => _editPatient(patient),
                    tooltip: 'Editar paciente',
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    patient.phone,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_calculateAge(patient.birthDate)} años',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              if (!patient.isActive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Inactivo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  

  //CUADRO DE DIALOGO DEL PACIENTE
  void _viewPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${patient.name} ${patient.lastName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Cédula', patient.identification),
              _buildDetailRow('Teléfono', patient.phone),
              _buildDetailRow('Edad', '${_calculateAge(patient.birthDate)} años'),
              _buildDetailRow('Dirección', patient.address),
              _buildDetailRow('Estado', patient.isActive ? 'Activo' : 'Inactivo'),
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
              _editPatient(patient);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  void _editPatient(Patient patient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientEditScreen(patient: patient),
      ),
    );

    if (result == true) {
      _loadPatients();
    }
  }
}
