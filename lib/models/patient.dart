class Patient {
  final int? id;
  final String name;
  final String lastName;
  final String identification;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String address;
  final String? referralCode;
  final bool isFromProvince;
  final int missedAppointments;
  final AppointmentStage currentStage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.lastName,
    required this.identification,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.address,
    this.referralCode,
    required this.isFromProvince,
    this.missedAppointments = 0,
    this.currentStage = AppointmentStage.first,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // ----------------------------------
  // CONVERTIR A JSON (para API REST)
  // ----------------------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "lastName": lastName,
      "identification": identification,
      "email": email,
      "phone": phone,
      "birthDate": birthDate.toIso8601String(),
      "address": address,
      "referralCode": referralCode,
      "isFromProvince": isFromProvince,
      "missedAppointments": missedAppointments,
      "currentStage": currentStage.index,
      "isActive": isActive,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  // ----------------------------------
  // CONVERTIR DESDE JSON (API REST)
  // ----------------------------------
  factory Patient.fromJson(Map<String, dynamic> map) {
    return Patient(
      id: map["id"],
      name: map["name"],
      lastName: map["lastName"],
      identification: map["identification"],
      email: map["email"],
      phone: map["phone"],
      birthDate: DateTime.parse(map["birthDate"]),
      address: map["address"],
      referralCode: map["referralCode"],
      isFromProvince: map["isFromProvince"] is int
          ? map["isFromProvince"] == 1
          : map["isFromProvince"] ?? false,
      missedAppointments: map["missedAppointments"] ?? 0,
      currentStage: AppointmentStage.values[map["currentStage"] ?? 0],
      isActive: map["isActive"] is int
          ? map["isActive"] == 1
          : map["isActive"] ?? true,
      createdAt:
          map["createdAt"] != null ? DateTime.parse(map["createdAt"]) : null,
      updatedAt:
          map["updatedAt"] != null ? DateTime.parse(map["updatedAt"]) : null,
    );
  }


  // ----------------------------------
  // JSON SOLO PARA COMPARAR Y PATCH
  // ----------------------------------
  Map<String, dynamic> toPatchJson() {
    return {
      "name": name,
      "lastName": lastName,
      "identification": identification,
      "email": email,
      "phone": phone,
      "birthDate": birthDate.toIso8601String().split('T').first,
      "address": address,
      "referralCode": referralCode,
      "isFromProvince": isFromProvince ? 1 : 0,
      "missedAppointments": missedAppointments,
      "currentStage": currentStage.index,
      "isActive": isActive ? 1 : 0,
    };
  }












  // ----------------------------------
  // COPYWITH
  // ----------------------------------
  Patient copyWith({
    int? id,
    String? name,
    String? lastName,
    String? identification,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? address,
    String? referralCode,
    bool? isFromProvince,
    int? missedAppointments,
    AppointmentStage? currentStage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      identification: identification ?? this.identification,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      referralCode: referralCode ?? this.referralCode,
      isFromProvince: isFromProvince ?? this.isFromProvince,
      missedAppointments: missedAppointments ?? this.missedAppointments,
      currentStage: currentStage ?? this.currentStage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ----------------------------------
  // GETTERS
  // ----------------------------------
  String get fullName => "$name $lastName";

  bool get canScheduleAppointment => isActive && missedAppointments < 2;

  bool get needsReferralCode => isFromProvince || referralCode != null;
}

// ----------------------------------
// ENUM DE ETAPAS DE CITA
// ----------------------------------
enum AppointmentStage {
  first,
  second,
  third,
}

extension AppointmentStageExtension on AppointmentStage {
  String get displayName {
    switch (this) {
      case AppointmentStage.first:
        return "Primera Cita";
      case AppointmentStage.second:
        return "Segunda Cita";
      case AppointmentStage.third:
        return "Tercera Cita";
    }
  }

  int get stageNumber {
    switch (this) {
      case AppointmentStage.first:
        return 1;
      case AppointmentStage.second:
        return 2;
      case AppointmentStage.third:
        return 3;
    }
  }


}

