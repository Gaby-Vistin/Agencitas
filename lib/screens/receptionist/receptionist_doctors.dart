import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../doctor_edit_screen.dart';

class ReceptionistDoctors extends StatefulWidget {
  const ReceptionistDoctors({Key? key}) : super(key: key);

  @override
  State<ReceptionistDoctors> createState() => _ReceptionistDoctorsState();
}

class _ReceptionistDoctorsState extends State<ReceptionistDoctors> {
  bool _isLoading = true;
  List<Doctor> _doctors = [];
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

    await Future.delayed(const Duration(milliseconds: 300));

    // Doctores de ejemplo (Fisioterapia)
    setState(() {
      _doctors = [
        Doctor(
          id: 1,
          name: 'María',
          lastName: 'González',
          specialty: 'Fisioterapia',
          license: 'MSP-FIS-001',
          email: 'maria.gonzalez@cericitas.com',
          phone: '0991234567',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Doctor(
          id: 2,
          name: 'Carlos',
          lastName: 'Rodríguez',
          specialty: 'Fisioterapia',
          license: 'MSP-FIS-002',
          email: 'carlos.rodriguez@cericitas.com',
          phone: '0991234568',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Doctor(
          id: 3,
          name: 'Ana',
          lastName: 'Martínez',
          specialty: 'Fisioterapia',
          license: 'MSP-FIS-003',
          email: 'ana.martinez@cericitas.com',
          phone: '0991234569',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    return _doctors.where((doctor) {
      final fullName = '${doctor.name} ${doctor.lastName}'.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) ||
          doctor.email.toLowerCase().contains(query) ||
          doctor.phone.contains(query);
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
                hintText: 'Buscar médico por nombre, email o teléfono...',
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
                      'Total Médicos',
                      _doctors.length.toString(),
                      Icons.medical_services,
                      Colors.purple[700]!,
                    ),
                    _buildStatItem(
                      'Fisioterapia',
                      _doctors.length.toString(),
                      Icons.healing,
                      Colors.green[700]!,
                    ),
                  ],
                ),
              ),
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
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron médicos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
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

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewDoctorDetails(doctor),
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
                      doctor.name[0] + doctor.lastName[0],
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
                          'Dr. ${doctor.name} ${doctor.lastName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.specialty,
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
                    onPressed: () => _editDoctor(doctor),
                    tooltip: 'Editar médico',
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    doctor.phone,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewDoctorDetails(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dr. ${doctor.name} ${doctor.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Especialidad', doctor.specialty),
            _buildDetailRow('Email', doctor.email),
            _buildDetailRow('Teléfono', doctor.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editDoctor(doctor);
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editDoctor(Doctor doctor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorEditScreen(doctor: doctor)),
    );

    if (result == true) {
      _loadDoctors();
    }
  }
}
