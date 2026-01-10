/*import 'package:agencitas/services/mysql_service.dart';
import '../models/patient.dart';
//import '../models/doctor.dart' as doctor_models;
import '../models/appointment.dart';
import 'package:flutter/material.dart';


class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final MySQLDatabaseService _dbService = MySQLDatabaseService();

  /// Validates if a patient can schedule an appointment
  Future<AppointmentValidationResult> validateAppointmentRequest({
    required Patient patient,
    required int doctorId,
    required DateTime appointmentDate,

    //required doctor_models.TimeOfDay appointmentTime,
    required TimeOfDay appointmentTime,

    required AppointmentStage stage,
    String? referralCode,
  }) async {
    // Check if patient is active
    if (!patient.isActive) {
      return AppointmentValidationResult.error('El paciente no está activo en el sistema');
    }

    // Check if patient can schedule appointments (max 2 missed appointments)
    if (!patient.canScheduleAppointment) {
      return AppointmentValidationResult.error(
        'El paciente ha faltado a ${patient.missedAppointments} citas. '
        'Debe reiniciar el proceso desde la primera etapa.',
      );
    }

    // Validate stage progression
    if (stage.index != patient.currentStage.index) {
      return AppointmentValidationResult.error(
        'El paciente debe completar la ${patient.currentStage.displayName} '
        'antes de avanzar a la ${stage.displayName}',
      );
    }

     // Validate referral code for province patients
    if (patient.isFromProvince || referralCode != null) {
      if (referralCode == null || referralCode.isEmpty) {
        return AppointmentValidationResult.error(
          'Pacientes de provincia requieren código de referencia',
        );
      }

      final code = await _dbService.getReferralCode(referralCode);
      if (code == null) {
        return AppointmentValidationResult.error('Código de referencia inválido o expirado');
      }

      if (patient.isFromProvince && !code.isForProvince) {
        return AppointmentValidationResult.error(
          'Este código no es válido para pacientes de provincia',
        );
      }
    }

      



    // Check if doctor exists and is active
    final doctor = await _dbService.getDoctorById(doctorId);
    if (doctor == null || !doctor.isActive) {
      return AppointmentValidationResult.error('Doctor no disponible');
    }

    // Check if appointment date is in the future
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    );

    if (appointmentDateTime.isBefore(now)) {
      return AppointmentValidationResult.error(
        'No se puede agendar citas en el pasado',
      );
    }

    // Check if time slot is available
    final isAvailable = await _dbService.isTimeSlotAvailable(
      doctorId,
      appointmentDate,
      appointmentTime,
    );

    if (!isAvailable) {
      return AppointmentValidationResult.error('Horario no disponible');
    }

    // Check if doctor works on this day
    final dayOfWeek = doctor_models.DayOfWeek.values[appointmentDate.weekday - 1];
    final hasSchedule = doctor.schedule.any((s) => 
        s.dayOfWeek == dayOfWeek && 
        s.isActive &&
        !appointmentTime.isBefore(s.startTime) && 
        appointmentTime.isBefore(s.endTime));

    if (!hasSchedule) {
      return AppointmentValidationResult.error(
        'Doctor no disponible en este horario',
      );
    }

    return AppointmentValidationResult.success();
  }

  /// Schedules a new appointment
  Future<ScheduleAppointmentResult> scheduleAppointment({
    required Patient patient,
    required int doctorId,
    required DateTime appointmentDate,
    required doctor_models.TimeOfDay appointmentTime,
    required AppointmentStage stage,
    String? notes,
    String? referralCode,
  }) async {
    try {
      // Validate the appointment request
      final validation = await validateAppointmentRequest(
        patient: patient,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        stage: stage,
        referralCode: referralCode,
      );

      if (!validation.isValid) {
        return ScheduleAppointmentResult.error(validation.errorMessage!);
      }

      // Create the appointment
      final appointment = Appointment(
        patientId: patient.id!,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        stage: stage,
        status: AppointmentStatus.scheduled,
        notes: notes,
        referralCode: referralCode,
        isFromProvince: patient.isFromProvince,
        createdAt: DateTime.now(),
      );

      final appointmentId = await _dbService.insertAppointment(appointment);

      return ScheduleAppointmentResult.success(appointmentId);
    } catch (e) {
      return ScheduleAppointmentResult.error('Error al agendar cita: $e');
    }
  }

  /// Marks an appointment as completed and advances patient stage
  Future<void> completeAppointment(int appointmentId) async {
    final appointment = await _dbService.getAppointmentById(appointmentId);
    
    if (appointment == null) return;

    // Update appointment status
    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.completed,
      updatedAt: DateTime.now(),
    );
    await _dbService.updateAppointment(updatedAppointment);

    // Advance patient stage if not in final stage
    final patient = await _dbService.getPatientById(appointment.patientId);
    if (patient != null && appointment.stage != AppointmentStage.third) {
      final nextStage = AppointmentStage.values[appointment.stage.index + 1];
      final updatedPatient = patient.copyWith(
        currentStage: nextStage,
        updatedAt: DateTime.now(),
      );
      await _dbService.updatePatient(updatedPatient);
    }
  }

  /// Marks an appointment as no-show and updates patient missed count
  Future<void> markAppointmentAsNoShow(int appointmentId) async {
    final appointment = await _dbService.getAppointmentById(appointmentId);
    
    if (appointment == null) return;

    // Update appointment status
    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.noShow,
      updatedAt: DateTime.now(),
    );
    await _dbService.updateAppointment(updatedAppointment);

    // Update patient missed appointments count
    final patient = await _dbService.getPatientById(appointment.patientId);
    if (patient != null) {
      final newMissedCount = patient.missedAppointments + 1;
      final updatedPatient = patient.copyWith(
        missedAppointments: newMissedCount,
        // Reset to first stage and deactivate if missed 2 appointments
        currentStage: newMissedCount >= 2 ? AppointmentStage.first : patient.currentStage,
        isActive: newMissedCount < 2,
        updatedAt: DateTime.now(),
      );
      await _dbService.updatePatient(updatedPatient);

      // Cancel all future appointments if patient reached limit
      if (newMissedCount >= 2) {
        await _cancelAllFutureAppointments(
          patient.id!,
          'Paciente excedió límite de faltas (2 citas)',
        );
      }
    }
  }

  /// Cancels an appointment
  Future<void> cancelAppointment(int appointmentId, String reason) async {
    final appointment = await _dbService.getAppointmentById(appointmentId);
    
    if (appointment == null) return;

    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
      updatedAt: DateTime.now(),
    );
    await _dbService.updateAppointment(updatedAppointment);
  }


  /// Cancels all future appointments for a patient
  Future<void> _cancelAllFutureAppointments(int patientId, String reason) async {
    final patientAppointments = await _dbService.getAppointmentsByPatient(patientId);

    for (final appointment in patientAppointments) {
      if (appointment.status == AppointmentStatus.scheduled && 
          appointment.fullDateTime.isAfter(DateTime.now())) {
        await cancelAppointment(appointment.id!, reason);
      }
    }
  }

  /// Automatically processes missed appointments (should be called daily)
  Future<void> processAutomaticNoShows() async {
    final appointments = await _dbService.getAllAppointments();

    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.scheduled && 
          appointment.isPastDue) {
        await markAppointmentAsNoShow(appointment.id!);
      }
    }
  }

  /// Gets available time slots for a doctor on a specific date
  Future<List<doctor_models.TimeOfDay>> getAvailableTimeSlots(
    int doctorId,
    DateTime date,
  ) async {
    return await _dbService.getAvailableTimeSlots(doctorId, date);
  }

  /// Gets all appointments for a patient
  Future<List<Appointment>> getPatientAppointments(int patientId) async {
    return await _dbService.getAppointmentsByPatient(patientId);
  }

  /// Gets all appointments
  Future<List<Appointment>> getAllAppointments() async {
    return await _dbService.getAllAppointments();
  }
}

class AppointmentValidationResult {
  final bool isValid;
  final String? errorMessage;

  AppointmentValidationResult._(this.isValid, this.errorMessage);

  factory AppointmentValidationResult.success() => 
      AppointmentValidationResult._(true, null);

  factory AppointmentValidationResult.error(String message) => 
      AppointmentValidationResult._(false, message);
}

class ScheduleAppointmentResult {
  final bool isSuccess;
  final int? appointmentId;
  final String? errorMessage;

  ScheduleAppointmentResult._(this.isSuccess, this.appointmentId, this.errorMessage);

  factory ScheduleAppointmentResult.success(int appointmentId) => 
      ScheduleAppointmentResult._(true, appointmentId, null);

  factory ScheduleAppointmentResult.error(String message) => 
      ScheduleAppointmentResult._(false, null, message);
}
*/

//---------------------------------------------------------------
//             SERVICIO DE CONEXION PARA AGENDAMIENTO DE CITAS
//---------------------------------------------------------------
// Conexcion: 
//           Agencitas-API (routes/appointments.dart) 
//           Agencitas (appointment_service.dart)

//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/patient.dart';

class AppointmentService {
  
  static const String baseUrl = 'http://localhost:3000/api/appointments';
  
  // ----------------------------------
  // METODO PARA LISTAR TODAS LAS CITAS
  // ----------------------------------
  Future<List<Appointment>> getAllAppointments() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener citas');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Appointment.fromJson(e)).toList();
  }

  // ---------------------------
  // METODO PARA CREAR CITA
  // ---------------------------
  Future<void> scheduleAppointment({
    required Patient patient,
    required int doctorId,
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    
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
        'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
        'appointmentTime':
            '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}',
        'stage': stage,
        'notes': notes,
        'referralCode': referralCode,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al crear cita');
    }
  }

  // ---------------------------------
  // METODO PARA MARCA COMPLETAR CITA
  // ---------------------------------
  Future<void> completeAppointment(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/complete'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al completar la cita');
    }
  }

  // ---------------------------
  // METODO PARA MARCAR NO SHOW (ASISITIO)
  // ---------------------------
  Future<void> markAppointmentAsNoShow(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/noshow'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar no show');
    }
  }

  // ---------------------------
  // METODO PARA CANCELAR CITA
  // ---------------------------
  Future<void> cancelAppointment(int id, String reason) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cancelar la cita');
    }
  }
  
  // ---------------------------
  // METODO PARA ACTUALIZAR CITA
  // ---------------------------
  Future<void> updateAppointment({
  required int id,
  required DateTime appointmentDate,
  required TimeOfDay appointmentTime,
  required int stage,
  String? notes,
  String? referralCode,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
      'appointmentTime': '${appointmentTime.hour.toString().padLeft(2,'0')}:${appointmentTime.minute.toString().padLeft(2,'0')}',
      'stage': stage,
      'notes': notes,
      'referralCode': referralCode,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error actualizando cita');
  }
}
 
  // ---------------------------
  // METODO PARA ELIMINAR CITA
  // ---------------------------
  Future<void> deleteAppointment(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/$id'));
  if (response.statusCode != 200) {
    throw Exception('Error eliminando cita');
  }
}



 
  //Cargar horarios disponibles
  Future<List<TimeOfDay>> getAvailableTimeSlots(
  int doctorId,
  DateTime date,
) async {

  // Generar todos los horarios posibles
  const startHour = 6;
  const endHour = 17;
  const intervalMinutes = 30;

  final List<TimeOfDay> allSlots = [];

  for (int hour = startHour; hour < endHour; hour++) {
    allSlots.add(TimeOfDay(hour: hour, minute: 0));
    allSlots.add(TimeOfDay(hour: hour, minute: intervalMinutes));
  }

  // Obtener horarios ocupados del backend
  final occupiedSlots = await getOccupiedTimeSlots(doctorId, date);
  // Filtrar los ocupados
  final availableSlots = allSlots.where((slot) {
    return !occupiedSlots.any((occupied) =>
        occupied.hour == slot.hour &&
        occupied.minute == slot.minute);
  }).toList();

  return availableSlots;
}

  //Cargar horarios ocupados
  Future<List<TimeOfDay>> getOccupiedTimeSlots(
  int doctorId,
  DateTime date,
) async {
  final formattedDate = date.toIso8601String().split('T')[0];

  final response = await http.get(
    Uri.parse('$baseUrl/doctor/$doctorId/date/$formattedDate'),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al obtener horarios ocupados');
  }

  final List data = jsonDecode(response.body);

  return data.map((e) {
    final parts = e['appointmentTime'].split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }).toList();
}


  // ---------------------------
  // METODO PARA ESTADISTCIAS
  // ---------------------------
  
  // TOTAL DE CITAS : Se llama getTotalPatients() que viene desde la Agencitas-API en routes/patients.dart)
  Future<int> getTotalCitas() async {
    final url = Uri.parse("$baseUrl/total");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total'];
    }
    throw Exception('Error obteniendo total');
  }

  



}
