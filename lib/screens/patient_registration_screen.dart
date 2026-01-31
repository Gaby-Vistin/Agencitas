import 'package:flutter/material.dart';
import 'package:agencitas/services/api_registro_paciente.dart';
import 'package:agencitas/models/patient.dart';

class RegisterPatientPage extends StatefulWidget {
  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}


// Estado del formulario de registro de paciente
class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Instancia del servicio API
  final ApiRegistroPaciente api = ApiRegistroPaciente();
  

  // Controladores de los campos del formulario
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _idCard = TextEditingController();
  final _email = TextEditingController();
  final _phoneConventional = TextEditingController();
  final _phoneMobile = TextEditingController();
  final _birthDate = TextEditingController();
  final _address = TextEditingController();

  bool _loading = false;
  InsuranceType _insuranceType = InsuranceType.none;
  Gender _gender = Gender.other;

   // Seleccionar fecha de nacimiento
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    //recoger la fecha seleccionada y formatearla
    if (picked != null) {
    setState(() {
      _birthDate.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    });
  }
  }
  
  // Registrar paciente
  Future<void> registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    
    // Verificar existencia de cédula y validez de código de referido
    try {
      final exists = await api.checkIdentificationExists(_idCard.text);
      if (exists) {
        showError("Esta cédula ya existe");
        setState(() => _loading = false);
        return;
      }
      
      setState(() => _loading = false);
      
      // Mostrar diálogo de confirmación ANTES de crear el paciente
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 32),
                SizedBox(width: 10),
                Text('Confirmar Registro'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Si la información ingresada es correcta, escoja Aceptar; caso contrario, Cancelar.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Paciente:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Nombre: ${_name.text} ${_lastName.text}'),
                      Text('Cédula: ${_idCard.text}'),
                      Text('Fecha de Nacimiento: ${_birthDate.text}'),
                      Text('Género: ${_getGenderText(_gender)}'),
                      if (_email.text.isNotEmpty) Text('Email: ${_email.text}'),
                      if (_phoneMobile.text.isNotEmpty) Text('Celular: ${_phoneMobile.text}'),
                      if (_phoneConventional.text.isNotEmpty) Text('Teléfono: ${_phoneConventional.text}'),
                      if (_address.text.isNotEmpty) Text('Dirección: ${_address.text}'),
                      Text('Tipo de Seguro: ${_getInsuranceTypeText(_insuranceType)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Retorna false
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Retorna true
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
      
      // Si el usuario canceló, salir sin hacer nada
      if (confirmed != true) return;
      
      // Si confirmó, crear el paciente con la fecha de aceptación
      setState(() => _loading = true);
       
      // Calcular edad y determinar si es niño para marcarlo como prioritario
      final birthDate = DateTime.parse(_birthDate.text);
      final age = DateTime.now().year - birthDate.year;
      final isChild = age < 18;
       
      final patient = Patient(
        name: _name.text,
        lastName: _lastName.text,
        identification: _idCard.text,
        email: _email.text.isNotEmpty ? _email.text : null,
        phoneConventional: _phoneConventional.text.isNotEmpty ? _phoneConventional.text : null,
        phoneMobile: _phoneMobile.text.isNotEmpty ? _phoneMobile.text : null,
        birthDate: birthDate,
        address: _address.text.isNotEmpty ? _address.text : null,
        insuranceType: _insuranceType,
        gender: _gender,
        isPriority: isChild, // Los niños son automáticamente prioritarios
        acceptedAt: DateTime.now(), // Fecha y hora de aceptación del registro
      );
       
      final newId = await api.createPatient(patient.toJson());
      
      setState(() => _loading = false);
      
      // Mostrar mensaje de éxito
      showSuccess("Paciente registrado exitosamente con ID: $newId");
      
      // Limpiar el formulario
      clearForm();

    } catch (e) {
      debugPrint(e.toString());
      showError("No se pudo registrar el paciente");
      setState(() => _loading = false);
    }
  }
  
  //Método para limpiar el formulario después del registro exitoso
  void clearForm() {
    _formKey.currentState?.reset();

    _name.clear();
    _lastName.clear();
    _idCard.clear();
    _email.clear();
    _phoneConventional.clear();
    _phoneMobile.clear();
    _birthDate.clear();
    _address.clear();

    setState(() {
      _insuranceType = InsuranceType.none;
      _gender = Gender.other;
    });
  }
  
  // Mostrar mensaje de error
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  // Mostrar mensaje de éxito
  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(msg)),
    );
  }

  // Construir la interfaz de usuario registrar paciente
  /*@override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Registrar Paciente")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(labelText: "Nombres",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                      
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _lastName,
                      decoration: InputDecoration(labelText: "Apellidos"),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _idCard,
                      decoration: InputDecoration(labelText: "Cédula"),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.length != 10 ? "Cédula inválida" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(labelText: "Correo"),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phone,
                      decoration: InputDecoration(labelText: "Teléfono"),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _birthDate,
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: "Fecha nacimiento"),
                      onTap: pickDate,
                      validator: (v) =>
                          v!.isEmpty ? "Seleccione fecha" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _address,
                      decoration: InputDecoration(labelText: "Dirección"),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _isFromProvince,
                          onChanged: (v) => setState(() {
                            _isFromProvince = v!;
                          }),
                        ),
                        Text("Pertenece a provincia"),
                      ],
                    ),
                    if (_isFromProvince)
                      TextFormField(
                        controller: _referralCode,
                        decoration:
                            InputDecoration(labelText: "Código de referido"),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: registerPatient,
                      child: Text("Registrar"),
                    )
                  ],
                ),
              ),
            ),
    );
  }
*/
   @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Registrar Paciente'),
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // =========================
                // INFORMACIÓN PERSONAL
                // =========================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Nombres',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _lastName,
                          decoration: const InputDecoration(
                            labelText: 'Apellidos',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _idCard,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cédula',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (v) =>
                              v!.length != 10 ? 'Cédula inválida' : null,
                        ),

                        const SizedBox(height: 16),
                        
                        /*
                        InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Nacimiento',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake),
                            ),
                            child: Text(
                              _birthDate.text.isEmpty
                                  ? 'Seleccione fecha'
                                  : _birthDate.text,
                            ),
                          ),
                        ), */
                       TextFormField(
                        controller: _birthDate,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Nacimiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.cake),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Seleccione fecha' : null,
                        onTap: pickDate,
                      ),

                        const SizedBox(height: 16),

                        // Género
                        Text(
                          'Género',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Column(
                          children: [
                            RadioListTile<Gender>(
                              title: const Text('Hombre'),
                              value: Gender.male,
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<Gender>(
                              title: const Text('Mujer'),
                              value: Gender.female,
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<Gender>(
                              title: const Text('Otro'),
                              value: Gender.other,
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
   
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // INFORMACIÓN DE CONTACTO
                // =========================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneConventional,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono Convencional (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            hintText: 'Ej: 02-1234567',
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneMobile,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Celular (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone_android),
                            hintText: 'Ej: 0987654321',
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(
                            labelText: 'Dirección (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 16),

                        // Tipo de Seguro
                        Text(
                          'Tipo de Seguro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Column(
                          children: [
                            RadioListTile<InsuranceType>(
                              title: const Text('Público'),
                              value: InsuranceType.public,
                              groupValue: _insuranceType,
                              onChanged: (value) {
                                setState(() {
                                  _insuranceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<InsuranceType>(
                              title: const Text('Privado'),
                              value: InsuranceType.private,
                              groupValue: _insuranceType,
                              onChanged: (value) {
                                setState(() {
                                  _insuranceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<InsuranceType>(
                              title: const Text('Ninguno'),
                              value: InsuranceType.none,
                              groupValue: _insuranceType,
                              onChanged: (value) {
                                setState(() {
                                  _insuranceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =========================
                // BOTÓN REGISTRAR
                // =========================
                ElevatedButton.icon(
                  onPressed: registerPatient,
                  icon: const Icon(Icons.save),
                  label: const Text('Registrar Paciente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
  );
}



  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _idCard.dispose();
    _email.dispose();
    _phoneConventional.dispose();
    _phoneMobile.dispose();
    _birthDate.dispose();
    _address.dispose();
    super.dispose();
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

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Hombre';
      case Gender.female:
        return 'Mujer';
      case Gender.other:
        return 'Otro';
    }
  }

}
