import '../models/patient.dart';
import '../models/doctor.dart' as doctor_models;
import '../models/appointment.dart';
import 'database_service.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final DatabaseService _dbService = DatabaseService();

  /// Validates if a patient can schedule an appointment
  Future<AppointmentValidationResult> validateAppointmentRequest({
    required Patient patient,
    required int doctorId,
    required DateTime appointmentDate,
    required doctor_models.TimeOfDay appointmentTime,
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

      // Lista de códigos de provincia válidos (códigos oficiales de Ecuador)
      const validProvinceCodes = {
        '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
        '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
        '21', '22', '24', '26'
      };

      // Si es un código de provincia válido, aceptarlo directamente
      if (patient.isFromProvince && validProvinceCodes.contains(referralCode)) {
        // Código de provincia válido, continuar con la validación
      } else {
        // Validar contra la base de datos para códigos regulares
        final code = await _dbService.getReferralCodeByCode(referralCode);
        if (code == null || !code.isValid) {
          return AppointmentValidationResult.error('Código de referencia inválido o expirado');
        }

        if (patient.isFromProvince && !code.isForProvince) {
          return AppointmentValidationResult.error(
            'Este código no es válido para pacientes de provincia',
          );
        }
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
    final appointments = await _dbService.getAllAppointments();
    final appointment = appointments.where((a) => a.id == appointmentId).isNotEmpty 
        ? appointments.where((a) => a.id == appointmentId).first 
        : null;
    
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
    final appointments = await _dbService.getAllAppointments();
    final appointment = appointments.where((a) => a.id == appointmentId).isNotEmpty 
        ? appointments.where((a) => a.id == appointmentId).first 
        : null;
    
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
    final appointments = await _dbService.getAllAppointments();
    final appointment = appointments.where((a) => a.id == appointmentId).isNotEmpty 
        ? appointments.where((a) => a.id == appointmentId).first 
        : null;
    
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
