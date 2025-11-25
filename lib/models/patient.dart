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
  final DateTime createdAt;
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
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$name $lastName';

  bool get canScheduleAppointment {
    return isActive && missedAppointments < 2;
  }

  bool get needsReferralCode {
    return isFromProvince || referralCode != null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'identification': identification,
      'email': email,
      'phone': phone,
      'birthDate': birthDate.millisecondsSinceEpoch,
      'address': address,
      'referralCode': referralCode,
      'isFromProvince': isFromProvince ? 1 : 0,
      'missedAppointments': missedAppointments,
      'currentStage': currentStage.index,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      lastName: map['lastName'],
      identification: map['identification'],
      email: map['email'],
      phone: map['phone'],
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
      address: map['address'],
      referralCode: map['referralCode'],
      isFromProvince: map['isFromProvince'] == 1,
      missedAppointments: map['missedAppointments'] ?? 0,
      currentStage: AppointmentStage.values[map['currentStage'] ?? 0],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

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
}

enum AppointmentStage {
  first,
  second,
  third,
}

extension AppointmentStageExtension on AppointmentStage {
  String get displayName {
    switch (this) {
      case AppointmentStage.first:
        return 'Primera Cita';
      case AppointmentStage.second:
        return 'Segunda Cita';
      case AppointmentStage.third:
        return 'Tercera Cita';
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
