
//---------------------------------------------------------------
//             SERVICIO DE CONEXION PARA DOCTORES 
//---------------------------------------------------------------
// Conexcion: 
//           Agencitas-API (routes/doctors.dart) 
//           Agencitas (api_doctores.dart)


//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;


// CLASE PRINMCIPAL DE DOCTORES
class ApiDoctores {
  // RUTA BASE DE LA API "conexion local/puerto/ ruta de peticiones (4) "
  final String baseUrl = "http://localhost:3000/api/doctors"; 
  
 /* /// Verificar si la licencia existe
  Future<bool> checkIdentificationExists(String identification) async {
    final url = Uri.parse("$baseUrl/identification/$identification");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["exists"];
    }
    throw Exception("Error verificando cédula");
  } */



//-------------------------------
// METODO CRUD PARA DOCTORES
//-------------------------------
  
  /// Obtener lista de doctores
  Future<List<dynamic>> getDoctors() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Error obteniendo doctores");
  }

  /// Crear nuevo doctor
  Future<void> createDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear profesional');
    }
  }
  
  /// Actualizar doctor
  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar profesional');
    }
  }

  /// Eliminar doctor
  Future<bool> deleteDoctor(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.delete(url);

    return response.statusCode == 200;
  }


//-------------------------------
// METODO ESTADISTICAS
//-------------------------------
  //Debemos extraer los metodos creados en el backend (Agencitas-API) para poder usarlas aqui

  // Total de doctoresS: Se usa getTotalPatients() que viene desde la Agencitas-API en routes/patients.dart)
  Future<int> getTotalDoctores() async {
    final url = Uri.parse("$baseUrl/total");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total'];
    }
    throw Exception('Error obteniendo total');
  }
  


}//fin de la clase

