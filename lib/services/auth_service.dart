//---------------------------------------------------------------
//         PARA LA AUTENTICACION DE USUARIOS
//---------------------------------------------------------------

// Conexcion: 
//           Agencitas-API (routes/users.dart) 
//           Agencitas (auth_service.dart)


//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------
import 'dart:convert'; //Para codificar y decodificar JSON
import 'package:agencitas/models/user.dart'; //Modelo de Usuario
import 'package:agencitas/services/mysql_service.dart'; //Servicio de MySQL para conexion nativa
import 'package:flutter/foundation.dart'; //Para detectar plataforma (kIsWeb)
import 'package:http/http.dart' as http; //Para hacer peticiones HTTP


class AuthService {
  static Future<User?> login(String username, String password) async {
    if (kIsWeb) {
      //  Web: usar API REST
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/auth/login'), //Se conecta al servisdor:auto.js (Node.js)
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data); 
          
          if (data['success'] == true) {

            final userMap = data['user'];
            return User(
              id: userMap['id'] as int?,
              username: userMap['username'] ?? '',
              displayName: userMap['displayName'] ?? '',
              role: UserRole.values[userMap['role'] as int],
              email: userMap['email'] ?? '',
              isActive: userMap['isActive'] as bool,
              createdAt: DateTime.parse(userMap['createdAt'] as String),
            );
          }


          
        }
        return null;
      } catch (e) {
        print('Error en login web: $e');
        rethrow;
      }
    } else {
      // Nativo: usar conexión directa a MySQL
      try {
        return await MySQLDatabaseService().login(username, password);
      } catch (e) {
        print('Error en login nativo: $e');
        rethrow;
      }
    }
  }
}