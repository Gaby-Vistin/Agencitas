import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

// Clase para representar una provincia
class Province {
  final String name;
  final String capital;
  final String code;

  Province({required this.name, required this.capital, required this.code});

  String get displayName => '$name - $capital';
}

// Lista de provincias del Ecuador con códigos oficiales
final List<Province> ecuadorianProvinces = [
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
  Province(
    name: 'Santo Domingo de los Tsáchilas',
    capital: 'Santo Domingo',
    code: '24',
  ),
  Province(name: 'Santa Elena', capital: 'Santa Elena', code: '26'),
];

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _identificationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _referralCodeController = TextEditingController();

  DateTime _selectedBirthDate = DateTime.now().subtract(
    const Duration(days: 365 * 18),
  );
  bool _isFromProvince = false;
  bool _isLoading = false;
  Province? _selectedProvince;

  final DatabaseService _dbService = DatabaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _identificationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if patient already exists
      final existingPatient = await _dbService.getPatientByIdentification(
        _identificationController.text.trim(),
      );

      if (existingPatient != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe un paciente con esta identificación'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validate referral code if provided or if from province
      if (_isFromProvince || _referralCodeController.text.trim().isNotEmpty) {
        final referralCode = _referralCodeController.text.trim();
        if (referralCode.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Pacientes de provincia requieren código de referencia',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Validar códigos de provincia generados automáticamente
        if (_isFromProvince && _selectedProvince != null) {
          // Los códigos de provincia generados automáticamente son válidos
          // No necesitamos validar contra la base de datos
        } else {
          // Para otros códigos, validar en la base de datos
          final code = await _dbService.getReferralCodeByCode(referralCode);
          if (code == null || !code.isValid) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código de referencia inválido o expirado'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          if (_isFromProvince && !code.isForProvince) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Este código no es válido para pacientes de provincia',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      // Create patient
      final patient = Patient(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        identification: _identificationController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _selectedBirthDate,
        address: _addressController.text.trim(),
        referralCode: _referralCodeController.text.trim().isNotEmpty
            ? _referralCodeController.text.trim()
            : null,
        isFromProvince: _isFromProvince,
        createdAt: DateTime.now(),
      );

      await _dbService.insertPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar paciente: $e'),
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
        title: const Text('Registro de Paciente'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El apellido es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _identificationController,
                        decoration: const InputDecoration(
                          labelText: 'Cédula/Identificación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La identificación es obligatoria';
                          }
                          if (value.trim().length < 10) {
                            return 'La identificación debe tener al menos 10 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectBirthDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Nacimiento',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake),
                          ),
                          child: Text(
                            '${_selectedBirthDate.day}/${_selectedBirthDate.month}/${_selectedBirthDate.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Contacto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El correo electrónico es obligatorio';
                          }
                          if (!EmailValidator.validate(value.trim())) {
                            return 'Ingrese un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          helperText:
                              'Convencional (7-9 dígitos) o Celular (10 dígitos)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El teléfono es obligatorio';
                          }
                          // Permitir teléfonos convencionales (7-9 dígitos) y celulares (10 dígitos)
                          final phoneLength = value
                              .trim()
                              .replaceAll(RegExp(r'[^0-9]'), '')
                              .length;
                          if (phoneLength < 7) {
                            return 'El teléfono debe tener al menos 7 dígitos';
                          }
                          if (phoneLength > 10) {
                            return 'El teléfono no puede tener más de 10 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La dirección es obligatoria';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Paciente de Provincia'),
                        subtitle: const Text(
                          'Requiere código de referencia especial',
                        ),
                        value: _isFromProvince,
                        onChanged: (value) {
                          setState(() {
                            _isFromProvince = value ?? false;
                            // Limpiar selección al cambiar de tipo
                            if (!_isFromProvince) {
                              _selectedProvince = null;
                              _referralCodeController.clear();
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16),
                      // Código de referencia - Dropdown para pacientes de provincia
                      if (_isFromProvince)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<Province>(
                              value: _selectedProvince,
                              decoration: const InputDecoration(
                                labelText: 'Provincia de Origen *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                helperText:
                                    'Seleccione su provincia para generar el código',
                              ),
                              hint: const Text('Seleccionar Provincia'),
                              isExpanded: true, // Para evitar overflow
                              items: ecuadorianProvinces.map((
                                Province province,
                              ) {
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
                                    _referralCodeController.text =
                                        newValue.code;
                                  } else {
                                    _referralCodeController.clear();
                                  }
                                });
                              },
                              validator: (value) {
                                if (_isFromProvince && value == null) {
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Código generado: ${_selectedProvince!.code}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      // Código de referencia opcional para pacientes locales
                      else
                        TextFormField(
                          controller: _referralCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Código de Referencia (Opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code),
                            helperText: 'Ingrese código si tiene uno',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerPatient,
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
                          Text('Registrando...'),
                        ],
                      )
                    : const Text('Registrar Paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
