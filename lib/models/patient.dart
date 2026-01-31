// ----------------------------------
// ENUM DE TIPO DE SEGURO
// ----------------------------------
enum InsuranceType {
  none,     // Sin seguro
  public,   // Seguro público
  private,  // Seguro privado
}

// ----------------------------------
// ENUM DE GÉNERO
// ----------------------------------
enum Gender {
  male,     // Hombre
  female,   // Mujer
  other,    // Otro
}

// ----------------------------------
// ENUM DE TIPO DE PACIENTE (para filtrar especialidades)
// ----------------------------------
enum PatientType {
  child,    // Niño (< 18 años)
  adult,    // Adulto (>= 18 años)
}

class Patient {
  final int? id;
  final String name;
  final String lastName;
  final String identification;
  final String? email;
  final String? phoneConventional;
  final String? phoneMobile;
  final DateTime birthDate;
  final String? address;
  final String? referralCode;
  final bool isFromProvince;
  final int missedAppointments;
  final AppointmentStage currentStage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final InsuranceType insuranceType;
  final Gender gender;
  final bool isPriority;

  Patient({
    this.id,
    required this.name,
    required this.lastName,
    required this.identification,
    this.email,
    this.phoneConventional,
    this.phoneMobile,
    required this.birthDate,
    this.address,
    this.referralCode,
    this.isFromProvince = false,
    this.missedAppointments = 0,
    this.currentStage = AppointmentStage.first,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.insuranceType = InsuranceType.none,
    this.gender = Gender.other,
    this.isPriority = false,
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
      "phoneConventional": phoneConventional,
      "phoneMobile": phoneMobile,
      "birthDate": birthDate.toIso8601String(),
      "address": address,
      "referralCode": referralCode,
      "isFromProvince": isFromProvince,
      "missedAppointments": missedAppointments,
      "currentStage": currentStage.index,
      "isActive": isActive,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "acceptedAt": acceptedAt?.toIso8601String(),
      "insuranceType": insuranceType.index,
      "gender": gender.index,
      "isPriority": isPriority ? 1 : 0,
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
      phoneConventional: map["phoneConventional"],
      phoneMobile: map["phoneMobile"],
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
      acceptedAt:
          map["acceptedAt"] != null ? DateTime.parse(map["acceptedAt"]) : null,
      insuranceType: InsuranceType.values[map["insuranceType"] ?? 0],
      gender: Gender.values[map["gender"] ?? 2],
      isPriority: map["isPriority"] is int
          ? map["isPriority"] == 1
          : map["isPriority"] ?? false,
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
      "phoneConventional": phoneConventional,
      "phoneMobile": phoneMobile,
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
    String? phoneConventional,
    String? phoneMobile,
    DateTime? birthDate,
    String? address,
    String? referralCode,
    bool? isFromProvince,
    int? missedAppointments,
    AppointmentStage? currentStage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    InsuranceType? insuranceType,
    Gender? gender,
    bool? isPriority,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      identification: identification ?? this.identification,
      email: email ?? this.email,
      phoneConventional: phoneConventional ?? this.phoneConventional,
      phoneMobile: phoneMobile ?? this.phoneMobile,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      referralCode: referralCode ?? this.referralCode,
      isFromProvince: isFromProvince ?? this.isFromProvince,
      missedAppointments: missedAppointments ?? this.missedAppointments,
      currentStage: currentStage ?? this.currentStage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      insuranceType: insuranceType ?? this.insuranceType,
      gender: gender ?? this.gender,
      isPriority: isPriority ?? this.isPriority,
    );
  }

  // ----------------------------------
  // GETTERS
  // ----------------------------------
  String get fullName => "$name $lastName";

  // Calcula la edad del paciente
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Determina si es niño (menor de 18 años)
  bool get isChild => age < 18;

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

