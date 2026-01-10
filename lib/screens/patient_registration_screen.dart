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
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  final _address = TextEditingController();
  final _referralCode = TextEditingController();

  bool _isFromProvince = false;
  bool _loading = false;

  List<String> codes = [];
  
  // Cargar códigos de referido al iniciar
  @override
  void initState() {
    super.initState();
    loadCodes();
  }
  
  // Cargar códigos de referido desde la API
  Future<void> loadCodes() async {
    try {
      codes = await api.getProvinceReferralCodes();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

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

      if (_isFromProvince && _referralCode.text.isNotEmpty) {
        final valid = await api.validateReferralCode(_referralCode.text);
        if (!valid) {
          showError("Código de referido inválido");
          setState(() => _loading = false);
          return;
        }
      }
       
      
      final patient = Patient(
        name: _name.text,
        lastName: _lastName.text,
        identification: _idCard.text,
        email: _email.text,
        phone: _phone.text,
        birthDate: DateTime.parse(_birthDate.text),
        address: _address.text,
        referralCode: _referralCode.text.isNotEmpty ? _referralCode.text : null,
        isFromProvince: _isFromProvince,
        //createdAt: DateTime.now(),
      );
       
      //Cuadro de diálogo de confirmación de registro de paciente 
      final newId = await api.createPatient(patient.toJson());
      showSuccess("Paciente registrado con ID: $newId");

          //Metodo para limpiar el formulario después del registro exitoso
            void clearForm() {
            _formKey.currentState?.reset();

            _name.clear();
            _lastName.clear();
            _idCard.clear();
            _email.clear();
            _phone.clear();
            _birthDate.clear();
            _address.clear();
            _referralCode.clear();

            setState(() {
              _isFromProvince = false;
            });
          }
            clearForm();

    } catch (e) {
      debugPrint(e.toString());
      showError("No se pudo registrar el paciente");
    }

    setState(() => _loading = false);
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
                            labelText: 'Correo Electrónico',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // INFORMACIÓN ADICIONAL
                // =========================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                          subtitle: const Text(
                              'Requiere código de referencia especial'),
                          value: _isFromProvince,
                          onChanged: (v) {
                            setState(() {
                              _isFromProvince = v!;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity.leading,
                        ),

                        if (_isFromProvince)
                          TextFormField(
                            controller: _referralCode,
                            decoration: const InputDecoration(
                              labelText: 'Código de Referido',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.qr_code),
                            ),
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
    _phone.dispose();
    _birthDate.dispose();
    _address.dispose();
    _referralCode.dispose();
    super.dispose();
  }


}
