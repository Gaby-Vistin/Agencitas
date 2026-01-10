/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
//import '../models/doctor.dart' as doctor_models;

class AppointmentService {
  static const String baseUrl = 'http://localhost:3000/api/appointments';

  // --------------------------------
  // CREAR CITA
  // --------------------------------
  Future<ApiResult> scheduleAppointment({
  required Patient patient,
  required int doctorId,
  required DateTime appointmentDate,
  required TimeOfDay appointmentTime, // ✅ CORRECTO
  required int stage,
  String? notes,
  String? referralCode,
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'patientId': patient.id,
      'doctorId': doctorId,
      'appointmentDate':
          DateFormat('yyyy-MM-dd').format(appointmentDate),
      'appointmentTime':
          '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}',
      'stage': stage,
      'notes': notes,
      'referralCode': referralCode,
      'isFromProvince': patient.isFromProvince,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return ApiResult.success();
  } else {
    return ApiResult.error(
      data['error'] ?? 'Error al crear cita',
    );
  }
}


  // --------------------------------
  // LISTAR CITAS
  // --------------------------------
  Future<List<Appointment>> getAppointments() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener citas');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Appointment.fromJson(e)).toList();
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

  ApiResult._({required this.isSuccess, this.errorMessage});

  factory ApiResult.success() => ApiResult._(isSuccess: true);

  factory ApiResult.error(String message) =>
      ApiResult._(isSuccess: false, errorMessage: message);
}
*/