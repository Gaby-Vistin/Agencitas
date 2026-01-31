//---------------------------------------------------------------
//             SERVICIO DE CONEXION PARA USUARIOS 
//---------------------------------------------------------------
// Conexcion: 
//           Agencitas-API (routes/users.dart) 
//           Agencitas (api_users.dart)

//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;

// CLASE PRINCIPAL DE USUARIOS
class ApiUsers {
  // RUTA BASE DE LA API
  final String baseUrl = "http://localhost:3000/api/users"; 
  
//-------------------------------
// METODO CRUD PARA USUARIOS
//-------------------------------
  
  /// Obtener lista de usuarios
  Future<List<dynamic>> getUsers() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Error obteniendo usuarios");
  }

  /// Crear nuevo usuario
  Future<void> createUser(Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear usuario');
    }
  }
  
  /// Actualizar usuario
  Future<void> updateUser(String username, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$username");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario');
    }
  }

  /// Eliminar usuario
  Future<bool> deleteUser(String username) async {
    final url = Uri.parse("$baseUrl/$username");
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  /// Cambiar contraseña de usuario
  Future<void> changePassword(String username, String newPassword) async {
    final url = Uri.parse("$baseUrl/$username/password");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'password': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cambiar contraseña');
    }
  }

  /// Verificar si el username existe
  Future<bool> checkUsernameExists(String username) async {
    final url = Uri.parse("$baseUrl/check/$username");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["exists"];
    }
    throw Exception("Error verificando username");
  }

//-------------------------------
// METODO ESTADISTICAS
//-------------------------------
  
  /// Total de usuarios
  Future<int> getTotalUsers() async {
    final url = Uri.parse("$baseUrl/total");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total'];
    }
    throw Exception("Error obteniendo total de usuarios");
  }

  /// Usuarios activos
  Future<int> getActiveUsers() async {
    final url = Uri.parse("$baseUrl/active");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total'];
    }
    throw Exception("Error obteniendo usuarios activos");
  }
}
