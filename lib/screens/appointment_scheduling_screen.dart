import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/doctor.dart' as doctor_models;
import '../services/database_service.dart';
import '../services/appointment_service.dart';
import '../widgets/logout_button.dart';
import 'doctor_list_screen.dart';

// Clase para representar una provincia
class Province {
  final String name;
  final String capital;
  final String code;

  const Province({
    required this.name,
    required this.capital,
    required this.code,
  });

  String get displayName => '$name: $capital';

  @override
  String toString() => displayName;
}

// Lista de provincias del Ecuador con códigos oficiales
const List<Province> ecuadorianProvinces = [
  Province(name: 'Azuay', capital: 'Cuenca', code: '01'),
  Province(name: 'Bolívar', capital: 'Guaranda', code: '02'),
  Province(name: 'Cañar', capital: 'Azogues', code: '03'),
  Province(name: 'Carchi', capital: 'Tulcán', code: '04'),
  Province(name: 'Cotopaxi', capital: 'Latacunga', code: '05'),
  Province(name: 'Chimborazo', capital: 'Riobamba', code: '06'),
  Province(name: 'El Oro', capital: 'Machala', code: '07'),
  Province(name: 'Esmeraldas', capital: 'Esmeraldas', code: '08'),
  Province(name: 'Guayas', capital: 'Guayaquil', code: '09'),
  Province(name: 'Imbabura', capital: 'Ibarra', code: '10'),
  Province(name: 'Loja', capital: 'Loja', code: '11'),
  Province(name: 'Los Ríos', capital: 'Babahoyo', code: '12'),
  Province(name: 'Manabí', capital: 'Portoviejo', code: '13'),
  Province(name: 'Morona Santiago', capital: 'Macas', code: '14'),
  Province(name: 'Napo', capital: 'Tena', code: '15'),
  Province(name: 'Pastaza', capital: 'Puyo', code: '16'),
  Province(name: 'Pichincha', capital: 'Quito', code: '17'),
  Province(name: 'Tungurahua', capital: 'Ambato', code: '18'),
  Province(name: 'Zamora Chinchipe', capital: 'Zamora', code: '19'),
  Province(name: 'Galápagos', capital: 'Puerto Baquerizo Moreno', code: '20'),
  Province(name: 'Sucumbíos', capital: 'Nueva Loja', code: '21'),
  Province(name: 'Orellana', capital: 'Francisco de Orellana', code: '22'),
  Province(name: 'Santo Domingo de los Tsáchilas', capital: 'Santo Domingo', code: '24'),
  Province(name: 'Santa Elena', capital: 'Santa Elena', code: '26'),
];

class AppointmentSchedulingScreen extends StatefulWidget {
  final Patient? patient;

  const AppointmentSchedulingScreen({super.key, this.patient});

  @override
  State<AppointmentSchedulingScreen> createState() => _AppointmentSchedulingScreenState();
}

class _AppointmentSchedulingScreenState extends State<AppointmentSchedulingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _referralCodeController = TextEditingController();
  
  final DatabaseService _dbService = DatabaseService();
  final AppointmentService _appointmentService = AppointmentService();

  Patient? _selectedPatient;
  doctor_models.Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  doctor_models.TimeOfDay? _selectedTime;
  Province? _selectedProvince; // Nueva variable para la provincia seleccionada
  
  List<Patient> _patients = [];
  List<doctor_models.TimeOfDay> _availableTimeSlots = [];
  bool _isLoading = false;
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.patient;
    _loadPatients();
    if (_selectedPatient?.referralCode != null) {
      _referralCodeController.text = _selectedPatient!.referralCode!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _dbService.getAllPatients();
      if (mounted) {
        setState(() {
          _patients = patients.where((p) => p.canScheduleAppointment).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          _availableTimeSlots = timeSlots;
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
    final doctor_models.Doctor? selectedDoctor = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorListScreen(
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

    // Validación específica para pacientes de provincia
    if (_selectedPatient!.isFromProvince && _selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar la provincia de origen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un doctor'),
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
      final result = await _appointmentService.scheduleAppointment(
        patient: _selectedPatient!,
        doctorId: _selectedDoctor!.id!,
        appointmentDate: _selectedDate,
        appointmentTime: _selectedTime!,
        stage: _selectedPatient!.currentStage,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        referralCode: _selectedPatient!.isFromProvince && _selectedProvince != null
            ? _selectedProvince!.code  // Usar directamente el código de la provincia seleccionada
            : (_referralCodeController.text.trim().isNotEmpty 
                ? _referralCodeController.text.trim() 
                : null),
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita agendada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // Reducido de 12 a 10
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12), // Reducido de 16 a 12
                      if (widget.patient != null)
                        Container(
                          padding: const EdgeInsets.all(10), // Reducido de 12 a 10
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
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<Patient>(
                          value: _selectedPatient,
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Paciente',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          menuMaxHeight: 200, // Limitar altura del menú
                          isExpanded: true, // Expandir para evitar overflow horizontal
                          items: _patients.map((patient) {
                            return DropdownMenuItem(
                              value: patient,
                              child: Text(
                                '${patient.fullName} - ${patient.currentStage.displayName}',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (patient) {
                            setState(() {
                              _selectedPatient = patient;
                              if (patient?.referralCode != null) {
                                _referralCodeController.text = patient!.referralCode!;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Seleccione un paciente';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
                ),
              const SizedBox(height: 12), // Reducido de 16 a 12

              // Doctor Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor',
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
                                    : const Text('Seleccionar Doctor'),
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
              const SizedBox(height: 12), // Reducido de 16 a 12

              // Date and Time Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
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
                                label: Text(time.toString()),
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
              const SizedBox(height: 12), // Reducido de 16 a 12

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Código de referencia para pacientes de provincia
                      if (_selectedPatient?.isFromProvince == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<Province>(
                              value: _selectedProvince,
                              decoration: const InputDecoration(
                                labelText: 'Provincia de Origen *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                helperText: 'Seleccione su provincia para generar el código',
                              ),
                              hint: const Text('Seleccionar Provincia'),
                              isExpanded: true, // Para evitar overflow
                              items: ecuadorianProvinces.map((Province province) {
                                return DropdownMenuItem<Province>(
                                  value: province,
                                  child: Text(
                                    '${province.name} (${province.code})',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (Province? newValue) {
                                setState(() {
                                  _selectedProvince = newValue;
                                  if (newValue != null) {
                                    _referralCodeController.text = newValue.code;
                                  } else {
                                    _referralCodeController.clear();
                                  }
                                });
                              },
                              validator: (value) {
                                if (_selectedPatient?.isFromProvince == true && value == null) {
                                  return 'Debe seleccionar una provincia';
                                }
                                return null;
                              },
                            ),
                            if (_selectedProvince != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Código generado: ${_selectedProvince!.code}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      else if (_selectedPatient?.referralCode != null)
                        TextFormField(
                          controller: _referralCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Código de Referencia',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code),
                            helperText: 'Ingrese su código de referencia',
                          ),
                        ),
                      
                      if ((_selectedPatient?.isFromProvince == true || _selectedPatient?.referralCode != null))
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
                    : const Text('Agendar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}