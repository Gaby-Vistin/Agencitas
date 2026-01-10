
//---------------------------------------------------------------
//             SERVICIO DE CONEXION PARA REGISTRO DE PACIENTES
//---------------------------------------------------------------
// Conexcion: 
//           Agencitas-API (routes/patients.dart) 
//           Agencitas (api_registro_paciente.dart)

//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;

// CLASE PRINCIPAL DE REGISTRO DE PACIENTES
class ApiRegistroPaciente {
  final String baseUrl = "http://localhost:3000/api/patients"; //RUTA BASE QUE API (routes/patients.dart , que esta en Agencitas API)
  
  // Verificar si la cédula existe
  Future<bool> checkIdentificationExists(String identification) async {
    final url = Uri.parse("$baseUrl/identification/$identification");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["exists"];
    }
    throw Exception("Error verificando cédula");
  }

  // Validar código de referido
  Future<bool> validateReferralCode(String code) async {
    final url = Uri.parse("$baseUrl/referrals/$code");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["valid"];
    }
    throw Exception("Error validando referido");
  }

  // Códigos de referencia por provincias
  Future<List<String>> getProvinceReferralCodes() async {
    final url = Uri.parse("$baseUrl/provinces/referral-codes");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    }
    throw Exception("Error cargando códigos");
  }


//-------------------------------
// METODO CRUD PARA PACIENTES
//-------------------------------

  // Crear paciente
  Future<int> createPatient(Map<String, dynamic> patient) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(patient),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)["id"];
    }
    throw Exception("Error guardando paciente");
  }

  // Obtener lista de pacientes
  Future<List<dynamic>> getPatients() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Error obteniendo pacientes");
  }

  // Actualizar paciente
  Future<void> updatePatient(int id, Map<String, dynamic> data) async {
      final url = Uri.parse("$baseUrl/$id");

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar paciente');
      }
  }

  // Eliminar paciente
  Future<bool> deletePatient(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

//-------------------------------
// METODO ESTADISTICAS
//-------------------------------
  //Debemos extraer los metodos creados en el backend (Agencitas-API) para poder usarlas aqui


  // Total de Pacientes: Se usa getTotalPatients() que viene desde la Agencitas-API en routes/patients.dart)
  Future<int> getTotalPatients() async {
    final url = Uri.parse("$baseUrl/total");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total'];
    }
    throw Exception('Error obteniendo total');
  }

  // Total de Pacientes Activos: Se usa getTotalPatientsActivos() que viene desde la Agencitas-API en routes/patients.dart)
  Future<int> getPatientsActivos() async {
    final url = Uri.parse("$baseUrl/totalActivos");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['totalActivos'];
    }
    throw Exception('Error obteniendo total Activos');
  }





}//fin de la clase

