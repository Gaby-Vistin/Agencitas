// -------------------------------------
// Pantalla de Agendamiento de Citas
// -------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/doctor.dart' as doctor_models;
import '../services/appointment_service.dart';
import '../services/api_registro_paciente.dart';
import '../widgets/logout_button.dart';
import 'doctor_list_screen.dart';

class AppointmentSchedulingScreen extends StatefulWidget {
  final Patient? patient;

  const AppointmentSchedulingScreen({super.key, this.patient});

  @override
  State<AppointmentSchedulingScreen> createState() => _AppointmentSchedulingScreenState();
}

class _AppointmentSchedulingScreenState extends State<AppointmentSchedulingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  final AppointmentService _appointmentService = AppointmentService();
  final ApiRegistroPaciente _patientService = ApiRegistroPaciente();

  Patient? _selectedPatient;
  doctor_models.Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _selectedTime;
  PatientType? _selectedPatientType; // Tipo de paciente: niño o adulto
  
  List<Patient> _patients = [];
  List<TimeOfDay> _availableTimeSlots = [];

  bool _isLoading = false;
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.patient;
    _loadInitialData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final patientsJson = await _patientService.getPatients();
      final patients = patientsJson.map((json) => Patient.fromJson(json)).toList();

      if (!mounted) return;

      setState(() {
        _patients = patients.where((p) => p.canScheduleAppointment).toList();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDoctor == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
      _selectedTime = null;
    });

    try {
      final timeSlots = await _appointmentService.getAvailableTimeSlots(
        _selectedDoctor!.id!,
        _selectedDate,
      );
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = timeSlots.cast<TimeOfDay>();
          _isLoadingTimeSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTimeSlots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _selectDoctor() async {
    if (_selectedPatientType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero seleccione el tipo de terapia (Niño o Adulto)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final doctor_models.Doctor? selectedDoctor = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorListScreen(
          patientType: _selectedPatientType,
          onDoctorSelected: (doctor) {
            Navigator.of(context).pop(doctor);
          },
        ),
      ),
    );

    if (selectedDoctor != null) {
      setState(() {
        _selectedDoctor = selectedDoctor;
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _scheduleAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un paciente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPatientType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione el tipo de terapia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un profesional'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un horario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _appointmentService.scheduleAppointment(
        patient: _selectedPatient!,
        doctorId: _selectedDoctor!.id!,
        appointmentDate: _selectedDate,
        appointmentTime: _selectedTime!,  
        stage: _selectedPatient!.currentStage.index + 1,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita agendada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agendar cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          LogoutButton(),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (widget.patient != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedPatient!.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Etapa: ${_selectedPatient!.currentStage.displayName}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge de prioridad si el paciente es niño
                              if (_selectedPatient!.isPriority)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.star, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'PRIORITARIO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        InkWell(
                          onTap: () => _showPatientSearchDialog(),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Paciente',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                              suffixIcon: Icon(Icons.search),
                            ),
                            child: Text(
                              _selectedPatient != null
                                  ? '${_selectedPatient!.fullName} - ${_selectedPatient!.identification}'
                                  : 'Buscar por nombre o cédula',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedPatient != null ? Colors.black : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Patient Type Selection (Niño o Adulto)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Terapia',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seleccione si la terapia es para niño o adulto',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<PatientType>(
                              title: const Text('Niño'),
                              subtitle: const Text('< 18 años'),
                              value: PatientType.child,
                              groupValue: _selectedPatientType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPatientType = value;
                                  _selectedDoctor = null;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<PatientType>(
                              title: const Text('Adulto'),
                              subtitle: const Text('≥ 18 años'),
                              value: PatientType.adult,
                              groupValue: _selectedPatientType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPatientType = value;
                                  _selectedDoctor = null;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      
                      // Mostrar especialidades disponibles según el tipo seleccionado
                      if (_selectedPatientType != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Especialidades Disponibles',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_selectedPatientType == PatientType.child) ...[
                                _buildSpecialtyItem('Terapia Física Pediátrica'),
                                _buildSpecialtyItem('Hipoterapia'),
                                _buildSpecialtyItem('Terapia Lenguaje'),
                                _buildSpecialtyItem('Terapia Ocupacional Pediátrica'),
                              ] else ...[
                                _buildSpecialtyItem('Terapia Física Adultos (Electroterapia y Gimnasio Terapéutico)'),
                                _buildSpecialtyItem('Terapia Ocupacional Adultos'),
                              ],
                            ],
                          ),
                        ),
                      
                      // Mensaje de prioridad cuando se selecciona Niño
                      if (_selectedPatientType == PatientType.child)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.priority_high, color: Colors.orange.shade700, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Paciente Prioritario',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Los niños tienen prioridad en la asignación de citas',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Doctor Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profesional',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDoctor,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.medical_services),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedDoctor != null
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedDoctor!.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _selectedDoctor!.specialty,
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      )
                                    : const Text('Seleccionar Profesional'),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Date and Time Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha y Hora',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de la Cita',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(_selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDoctor != null) ...[
                        Text(
                          'Horarios Disponibles:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingTimeSlots)
                          const Center(child: CircularProgressIndicator())
                        else if (_availableTimeSlots.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'No hay horarios disponibles para esta fecha',
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTimeSlots.map((time) {
                              final isSelected = _selectedTime == time;
                              return FilterChip(
                                label: Text(time.format(context)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTime = selected ? time : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas de la Consulta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notas (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Button
              ElevatedButton(
                onPressed: _isLoading ? null : _scheduleAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Agendando...'),
                        ],
                      )
                    : const Text('Guardar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientSearchDialog() {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredPatients = _patients.where((patient) {
              if (searchQuery.isEmpty) return true;
              final query = searchQuery.toLowerCase();
              return patient.fullName.toLowerCase().contains(query) ||
                     patient.identification.contains(query);
            }).toList();

            return AlertDialog(
              title: const Text('Buscar Paciente'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre o cédula',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredPatients.isEmpty
                          ? const Center(child: Text('No se encontraron pacientes'))
                          : ListView.builder(
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(patient.name[0]),
                                  ),
                                  title: Text(patient.fullName),
                                  subtitle: Text('Cédula: ${patient.identification}'),
                                  trailing: Text(
                                    patient.currentStage.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedPatient = patient;
                                    });
                                    Navigator.pop(context);
                                  },
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
            );
          },
        );
      },
    );
  }

  // Widget para mostrar cada especialidad disponible
  Widget _buildSpecialtyItem(String specialty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              specialty,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }}