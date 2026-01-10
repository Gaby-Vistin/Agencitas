class Doctor {
  final int? id;
  final String name;
  final String lastName;
  final String specialty;
  final String license;
  final String email;
  final String phone;
  final List<DoctorSchedule> schedule;
  final int appointmentDuration; // in minutes
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Doctor({
    this.id,
    required this.name,
    required this.lastName,
    required this.specialty,
    required this.license,
    required this.email,
    required this.phone,
    this.schedule = const [],
    this.appointmentDuration = 30,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => 'Dr. $name $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'specialty': specialty,
      'license': license,
      'email': email,
      'phone': phone,
      'appointmentDuration': appointmentDuration,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      lastName: map['lastName'],
      specialty: map['specialty'],
      license: map['license'],
      email: map['email'],
      phone: map['phone'],
      appointmentDuration: map['appointmentDuration'] ?? 30,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }


  factory Doctor.fromJson(Map<String, dynamic> json) {
  return Doctor(
    id: json['id'],
    name: json['name'],
    lastName: json['lastName'],
    specialty: json['specialty'],
    license: json['license'],
    email: json['email'],
    phone: json['phone'],

    // Si tu API no maneja horarios aún
    schedule: const [],

    // Si tu API no envía duración
    appointmentDuration: json['appointmentDuration'] ?? 30,

    // MySQL devuelve 1 / 0
    isActive: json['isActive'] == 1 || json['isActive'] == true,

    // MySQL devuelve string → DateTime.parse
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),

    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );
}


  Doctor copyWith({
    int? id,
    String? name,
    String? lastName,
    String? specialty,
    String? license,
    String? email,
    String? phone,
    List<DoctorSchedule>? schedule,
    int? appointmentDuration,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      license: license ?? this.license,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      schedule: schedule ?? this.schedule,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DoctorSchedule {
  final int? id;
  final int doctorId;
  final DayOfWeek dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isActive;

  DoctorSchedule({
    this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek.index,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'isActive': isActive ? 1 : 0,
    };
  }

  factory DoctorSchedule.fromMap(Map<String, dynamic> map) {
    final startTimeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');
    
    return DoctorSchedule(
      id: map['id'],
      doctorId: map['doctorId'],
      dayOfWeek: DayOfWeek.values[map['dayOfWeek']],
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      isActive: map['isActive'] == 1,
    );
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Lunes';
      case DayOfWeek.tuesday:
        return 'Martes';
      case DayOfWeek.wednesday:
        return 'Miércoles';
      case DayOfWeek.thursday:
        return 'Jueves';
      case DayOfWeek.friday:
        return 'Viernes';
      case DayOfWeek.saturday:
        return 'Sábado';
      case DayOfWeek.sunday:
        return 'Domingo';
    }
  }

  int get weekday {
    return index + 1; // DateTime.weekday starts from 1 (Monday)
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
