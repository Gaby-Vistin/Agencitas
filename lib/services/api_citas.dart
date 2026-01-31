import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AppointmentApiService {
  static const String baseUrl = 'http://localhost:3000/api/appointments';

  // --------------------------------
  // CREAR CITA
  // --------------------------------
  Future<ApiResult> scheduleAppointment({
    required int patientId,
    required int doctorId,
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    required String specialty,
    required String reason,
    String? notes,
    String? referralCode,
    bool isFromProvince = false,
    String? province,
  }) async {
    try {
      final body = {
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(appointmentDate),
        'appointmentTime':
            '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}',
        'specialty': specialty,
        'reason': reason,
        'status': 'scheduled',
        'stage': 1,
        'therapyStatus': 'notStarted',
        'notes': notes ?? '',
        'referralCode': referralCode ?? '',
        'isFromProvince': isFromProvince ? 1 : 0,
        'province': province ?? '',
      };
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data['id']);
      } else {
        final errorMsg = data['error'] ?? data['message'] ?? 'Error al crear cita';
        return ApiResult.error(errorMsg);
      }
    } catch (e) {
      return ApiResult.error('Error de conexión: $e');
    }
  }

  // --------------------------------
  // LISTAR CITAS
  // --------------------------------
  Future<List<dynamic>> getAppointments() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener citas');
    }

    return jsonDecode(response.body);
  }

  // --------------------------------
  // ELIMINAR CITA
  // --------------------------------
  Future<void> deleteAppointment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar cita');
    }
  }

  // --------------------------------
  // HORARIOS DISPONIBLES
  // --------------------------------
  Future<List<TimeOfDay>> getAvailableTimeSlots(
    int doctorId,
    DateTime date,
  ) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/available-times?doctorId=$doctorId&date=$formattedDate',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener horarios');
    }

    final List data = jsonDecode(response.body);

    return data.map((time) {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();
  }
}

// --------------------------------
// RESULTADO DE API
// --------------------------------
class ApiResult {
  final bool isSuccess;
  final String? errorMessage;
  final int? appointmentId;

  ApiResult._({required this.isSuccess, this.errorMessage, this.appointmentId});

  factory ApiResult.success(int? id) => ApiResult._(isSuccess: true, appointmentId: id);

  factory ApiResult.error(String message) =>
      ApiResult._(isSuccess: false, errorMessage: message);
}
