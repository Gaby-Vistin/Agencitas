import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../widgets/logout_button.dart';
import 'patient_edit_screen.dart';

class PatientListScreen extends StatefulWidget {
  final bool showOnlyActive;
  
  const PatientListScreen({
    super.key,
    this.showOnlyActive = false,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _dbService.getAllPatients();
      setState(() {
        _patients = widget.showOnlyActive 
            ? patients.where((p) => p.isActive).toList()
            : patients;
        _filteredPatients = _patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pacientes: $e')),
        );
      }
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
               patient.lastName.toLowerCase().contains(query) ||
               patient.identification.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showOnlyActive ? 'Pacientes Activos' : 'Todos los Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: const [
          LogoutButton(),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar pacientes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Patients List
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
                              'No se encontraron pacientes',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatients,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: patient.isActive 
                                      ? Colors.green 
                                      : Colors.grey,
                                  child: Text(
                                    '${patient.name[0]}${patient.lastName[0]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${patient.name} ${patient.lastName}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Identificación: ${patient.identification}'),
                                    Text('Teléfono: ${patient.phone}'),
                                    if (!patient.isActive)
                                      const Text(
                                        'Inactivo',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      patient.isActive 
                                          ? Icons.check_circle 
                                          : Icons.cancel,
                                      color: patient.isActive 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                    Text(
                                      patient.isActive ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: patient.isActive 
                                            ? Colors.green 
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Aquí se puede agregar navegación a detalles del paciente
                                  _showPatientDetails(patient);
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${patient.name} ${patient.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identificación: ${patient.identification}'),
            const SizedBox(height: 8),
            Text('Teléfono: ${patient.phone}'),
            const SizedBox(height: 8),
            Text('Email: ${patient.email}'),
            const SizedBox(height: 8),
            Text('Fecha de nacimiento: ${patient.birthDate.day}/${patient.birthDate.month}/${patient.birthDate.year}'),
            const SizedBox(height: 8),
            Text('Dirección: ${patient.address}'),
            const SizedBox(height: 8),
            Text('Estado: ${patient.isActive ? 'Activo' : 'Inactivo'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PatientEditScreen(patient: patient),
                ),
              );
              if (result == true) {
                _loadPatients();
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
