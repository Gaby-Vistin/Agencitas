import 'package:agencitas/models/appointment.dart';
import 'package:agencitas/services/api_registro_paciente.dart';
//import 'package:agencitas/services/mysql_service.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../models/patient.dart';
//import '../services/database_service.dart';
//import 'patient_registration_screen.dart';

class PatientEditScreen extends StatefulWidget {
  final Patient patient;

  const PatientEditScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _identificationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _referralCodeController;
  
  late DateTime _selectedBirthDate;
  late bool _isFromProvince;
  bool _isLoading = false;
  List<ReferralCode> _provinces = [];
  ReferralCode? _selectedProvince;

  // Instancia del servicio API
  final ApiRegistroPaciente api = ApiRegistroPaciente();
  

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos actuales del paciente
    _nameController = TextEditingController(text: widget.patient.name);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _identificationController = TextEditingController(text: widget.patient.identification);
    _emailController = TextEditingController(text: widget.patient.email);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _addressController = TextEditingController(text: widget.patient.address);
    _referralCodeController = TextEditingController(text: widget.patient.referralCode ?? '');
    _selectedBirthDate = widget.patient.birthDate;
    _isFromProvince = widget.patient.isFromProvince;
    
    //_loadProvinces();
  }
  /*
  Future<void> _loadProvinces() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provinces = await _dbService.getProvinceReferralCodes();
      setState(() {
        _provinces = provinces;
        
        // Buscar la provincia si tiene código de referencia
        if (widget.patient.referralCode != null && widget.patient.referralCode!.isNotEmpty) {
          try {
            _selectedProvince = _provinces.firstWhere(
              (p) => p.code == widget.patient.referralCode,
            );
          } catch (_) {
            // Si no se encuentra el código, no seleccionamos nada
            _selectedProvince = null;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar provincias: $e'),
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
 
  */

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
      helpText: 'Seleccionar Fecha de Nacimiento',
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
  
  //Función para actualizar la información del paciente
Future<void> _updatePatient() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final currentData = {
      "name": _nameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "identification": _identificationController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "referralCode": _referralCodeController.text.trim().isEmpty
          ? null
          : _referralCodeController.text.trim(),
      "birthDate":
          _selectedBirthDate.toIso8601String().split('T').first,
      "isFromProvince": _isFromProvince ? 1 : 0,
    };

    final originalData = widget.patient.toPatchJson();

    final changes = Map.fromEntries(
      currentData.entries.where(
        (e) => e.value != originalData[e.key],
      ),
    );

    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    await api.updatePatient(widget.patient.id!, changes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paciente actualizado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al actualizar paciente: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  //Diseño de la pantalla de edición de paciente
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Paciente'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
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
                        helperText: 'Convencional (7-9 dígitos) o Celular (10 dígitos)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es obligatorio';
                        }
                        final phoneLength = value.trim().replaceAll(RegExp(r'[^0-9]'), '').length;
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Paciente de Provincia'),
                      subtitle: const Text('Requiere código de referencia especial'),
                      value: _isFromProvince,
                      onChanged: (value) {
                        setState(() {
                          _isFromProvince = value ?? false;
                          if (!_isFromProvince) {
                            _selectedProvince = null;
                            _referralCodeController.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),
                    if (_isFromProvince)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<ReferralCode>(
                            initialValue: _selectedProvince,
                            decoration: const InputDecoration(
                              labelText: 'Provincia de Origen *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                              helperText: 'Seleccione su provincia',
                            ),
                            hint: const Text('Seleccionar Provincia'),
                            isExpanded: true,
                            items: _provinces.map((ReferralCode province) {
                              return DropdownMenuItem<ReferralCode>(
                                value: province,
                                child: Text(
                                  '${province.description} (${province.code})',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (ReferralCode? newValue) {
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
                                    'Código: ${_selectedProvince!.code}',
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
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _updatePatient,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
