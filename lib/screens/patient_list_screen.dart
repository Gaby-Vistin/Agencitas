// -----------------------------------------------
// SCREEN PARA MOSTARS EL LISTADO DE PACIENTES
// -----------------------------------------------

import 'package:agencitas/services/api_registro_paciente.dart';
//import 'package:agencitas/services/mysql_service.dart';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/user.dart';
//import '../services/database_service.dart';
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

  // Instancia del servicio API
  final ApiRegistroPaciente api = ApiRegistroPaciente();
  
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
  
  // Cargar lista de pacientes desde la API
  Future<void> _loadPatients() async {
    try {
      final response = await api.getPatients();

      final patients = response
          .map<Patient>((json) => Patient.fromJson(json))
          .toList();

      setState(() {
        _patients = widget.showOnlyActive
            ? patients.where((p) => p.isActive).toList()
            : patients;

        _filteredPatients = _patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pacientes')),
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
                                    if (patient.phoneMobile != null && patient.phoneMobile!.isNotEmpty)
                                      Text('Celular: ${patient.phoneMobile}'),
                                    if (patient.phoneConventional != null && patient.phoneConventional!.isNotEmpty)
                                      Text('Teléfono: ${patient.phoneConventional}'),
                                    if (patient.email != null && patient.email!.isNotEmpty)
                                      Text('Email: ${patient.email}'),
                                    if (patient.isPriority)
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 14, color: Colors.red[700]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Paciente Prioritario',
                                            style: TextStyle(
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
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
  

  // Mostrar detalles del paciente en un cuadro de diálogo
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
            if (patient.phoneMobile != null && patient.phoneMobile!.isNotEmpty) ...[
              Text('Celular: ${patient.phoneMobile}'),
              const SizedBox(height: 8),
            ],
            if (patient.phoneConventional != null && patient.phoneConventional!.isNotEmpty) ...[
              Text('Teléfono: ${patient.phoneConventional}'),
              const SizedBox(height: 8),
            ],
            if (patient.email != null && patient.email!.isNotEmpty) ...[
              Text('Email: ${patient.email}'),
              const SizedBox(height: 8),
            ],
            Text('Fecha de nacimiento: ${patient.birthDate.day}/${patient.birthDate.month}/${patient.birthDate.year}'),
            const SizedBox(height: 8),
            if (patient.address != null && patient.address!.isNotEmpty) ...[
              Text('Dirección: ${patient.address}'),
              const SizedBox(height: 8),
            ],
            Text('Estado: ${patient.isActive ? 'Activo' : 'Inactivo'}'),
            const SizedBox(height: 8),
            Text('Tipo de Seguro: ${_getInsuranceTypeText(patient.insuranceType)}',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[700])),
            if (patient.acceptedAt != null) ...[
              const SizedBox(height: 8),
              Text('Aceptó registro: ${patient.acceptedAt!.day}/${patient.acceptedAt!.month}/${patient.acceptedAt!.year} ${patient.acceptedAt!.hour}:${patient.acceptedAt!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
            ],
          ],
        ),

        // Botones de acción del cuadro de diálogo
        actions: [

          // Botón para cerrar el cuadro de diálogo
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),

          // Botón para editar paciente
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
          
          // Botón para eliminar paciente - Solo para director y administrador
          if (SessionManager.isAdminOrDirector())
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar diálogo de detalles primero
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: Text(
                      '¿Estás seguro de que deseas eliminar al paciente ${patient.name} ${patient.lastName}?\n\n'
                      'Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  try {
                    final success = await api.deletePatient(patient.id!);
                    
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paciente eliminado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadPatients(); // Recargar lista
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al eliminar paciente'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
        
        ],
      ),
    );
  }

  String _getInsuranceTypeText(InsuranceType type) {
    switch (type) {
      case InsuranceType.none:
        return 'Sin seguro';
      case InsuranceType.public:
        return 'Público';
      case InsuranceType.private:
        return 'Privado';
    }
  }
}
