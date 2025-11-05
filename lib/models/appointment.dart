import 'package:flutter/material.dart';
import 'patient.dart';
import 'doctor.dart' as doctor_models;

// Estado de la terapia para el semáforo
enum TherapyStatus {
  notStarted,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case TherapyStatus.notStarted:
        return 'No iniciada';
      case TherapyStatus.inProgress:
        return 'En progreso';
      case TherapyStatus.completed:
        return 'Finalizada';
    }
  }

  Color get color {
    switch (this) {
      case TherapyStatus.notStarted:
        return const Color(0xFFF44336); // Rojo
      case TherapyStatus.inProgress:
        return const Color(0xFFFF9800); // Amarillo/Naranja
      case TherapyStatus.completed:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  IconData get icon {
    switch (this) {
      case TherapyStatus.notStarted:
        return Icons.play_circle_outline;
      case TherapyStatus.inProgress:
        return Icons.pending;
      case TherapyStatus.completed:
        return Icons.check_circle;
    }
  }
}

class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final DateTime appointmentDate;
  final doctor_models.TimeOfDay appointmentTime;
  final AppointmentStatus status;
  final AppointmentStage stage;
  final TherapyStatus therapyStatus;
  final String? notes;
  final String? referralCode;
  final bool isFromProvince;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Relational data (not stored in DB directly)
  final Patient? patient;
  final doctor_models.Doctor? doctor;

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = AppointmentStatus.scheduled,
    required this.stage,
    this.therapyStatus = TherapyStatus.notStarted,
    this.notes,
    this.referralCode,
    this.isFromProvince = false,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.patient,
    this.doctor,
  });

  DateTime get fullDateTime {
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    );
  }

  bool get isPastDue {
    return fullDateTime.isBefore(DateTime.now()) && 
           status == AppointmentStatus.scheduled;
  }

  bool get canBeCancelled {
    return status == AppointmentStatus.scheduled && 
           fullDateTime.isAfter(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.millisecondsSinceEpoch,
      'appointmentTime': '${appointmentTime.hour}:${appointmentTime.minute}',
      'status': status.index,
      'stage': stage.index,
      'therapyStatus': therapyStatus.index,
      'notes': notes,
      'referralCode': referralCode,
      'isFromProvince': isFromProvince ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'cancellationReason': cancellationReason,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    final timeParts = map['appointmentTime'].split(':');
    
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      appointmentDate: DateTime.fromMillisecondsSinceEpoch(map['appointmentDate']),
      appointmentTime: doctor_models.TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      status: AppointmentStatus.values[map['status']],
      stage: AppointmentStage.values[map['stage']],
      therapyStatus: map['therapyStatus'] != null 
          ? TherapyStatus.values[map['therapyStatus']]
          : TherapyStatus.notStarted,
      notes: map['notes'],
      referralCode: map['referralCode'],
      isFromProvince: map['isFromProvince'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      cancelledAt: map['cancelledAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['cancelledAt'])
          : null,
      cancellationReason: map['cancellationReason'],
    );
  }

  Appointment copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    DateTime? appointmentDate,
    doctor_models.TimeOfDay? appointmentTime,
    AppointmentStatus? status,
    AppointmentStage? stage,
    String? notes,
    String? referralCode,
    bool? isFromProvince,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    Patient? patient,
    doctor_models.Doctor? doctor,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      referralCode: referralCode ?? this.referralCode,
      isFromProvince: isFromProvince ?? this.isFromProvince,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      patient: patient ?? this.patient,
      doctor: doctor ?? this.doctor,
    );
  }
}

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.noShow:
        return 'No se presentó';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return const Color(0xFF2196F3); // Blue
      case AppointmentStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case AppointmentStatus.cancelled:
        return const Color(0xFF9E9E9E); // Grey
      case AppointmentStatus.noShow:
        return const Color(0xFFF44336); // Red
      case AppointmentStatus.rescheduled:
        return const Color(0xFFFF9800); // Orange
    }
  }
}

class ReferralCode {
  final int? id;
  final String code;
  final String description;
  final bool isForProvince;
  final bool isActive;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReferralCode({
    this.id,
    required this.code,
    required this.description,
    this.isForProvince = false,
    this.isActive = true,
    this.expiryDate,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isValid {
    return isActive && !isExpired;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'isForProvince': isForProvince ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory ReferralCode.fromMap(Map<String, dynamic> map) {
    return ReferralCode(
      id: map['id'],
      code: map['code'],
      description: map['description'],
      isForProvince: map['isForProvince'] == 1,
      isActive: map['isActive'] == 1,
      expiryDate: map['expiryDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}