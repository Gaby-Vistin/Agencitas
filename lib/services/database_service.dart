import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/patient.dart';
import '../models/doctor.dart' as doctor_models;
import '../models/appointment.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static Database? _webDatabase; // Base de datos específica para web
  static SharedPreferences? _prefs;
  
  // Flag para saber si estamos en web
  bool get _isWeb => kIsWeb;
  
  // Variables para almacenamiento en memoria para web
  static List<Patient> _webPatients = [];
  static List<Appointment> _webAppointments = [];
  static int _nextPatientId = 1;
  static int _nextAppointmentId = 1;

  Future<Database> get database async {
    if (_isWeb) {
      // En web, mantenemos una sola instancia en memoria
      if (_webDatabase != null) return _webDatabase!;
      _prefs ??= await SharedPreferences.getInstance();
      _webDatabase = await openDatabase(':memory:', version: 1, onCreate: _createDatabase);
      // Forzar inserción de datos de muestra para web
      await _ensureSampleDataForWeb();
      return _webDatabase!;
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _ensureSampleDataForWeb() async {
    if (_webDatabase != null) {
      try {
        // Verificar si ya hay doctores
        final existingDoctors = await _webDatabase!.query('doctors');
        if (existingDoctors.isEmpty) {
          print('Insertando datos de muestra para web...'); // Debug
          await _insertSampleData(_webDatabase!);
        }
      } catch (e) {
        print('Error al verificar/insertar datos de muestra: $e'); // Debug
      }
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'agencitas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Patients table
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastName TEXT NOT NULL,
        identification TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        birthDate INTEGER NOT NULL,
        address TEXT NOT NULL,
        referralCode TEXT,
        isFromProvince INTEGER NOT NULL DEFAULT 0,
        missedAppointments INTEGER NOT NULL DEFAULT 0,
        currentStage INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Doctors table
    await db.execute('''
      CREATE TABLE doctors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastName TEXT NOT NULL,
        specialty TEXT NOT NULL,
        license TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        appointmentDuration INTEGER NOT NULL DEFAULT 30,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Doctor schedules table
    await db.execute('''
      CREATE TABLE doctor_schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorId INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(doctorId) REFERENCES doctors(id)
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        appointmentDate INTEGER NOT NULL,
        appointmentTime TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        stage INTEGER NOT NULL,
        notes TEXT,
        referralCode TEXT,
        isFromProvince INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER,
        cancelledAt INTEGER,
        cancellationReason TEXT,
        FOREIGN KEY(patientId) REFERENCES patients(id),
        FOREIGN KEY(doctorId) REFERENCES doctors(id)
      )
    ''');

    // Referral codes table
    await db.execute('''
      CREATE TABLE referral_codes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        description TEXT NOT NULL,
        isForProvince INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        expiryDate INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_patients_identification ON patients(identification)');
    await db.execute('CREATE INDEX idx_appointments_date ON appointments(appointmentDate)');
    await db.execute('CREATE INDEX idx_appointments_patient ON appointments(patientId)');
    await db.execute('CREATE INDEX idx_appointments_doctor ON appointments(doctorId)');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert sample doctors - SOLO FISIOTERAPIA
    await db.insert('doctors', {
      'name': 'Luis',
      'lastName': 'Hernández',
      'specialty': 'Fisioterapia',
      'license': 'FISIO001',
      'email': 'luis.hernandez@agencitas.com',
      'phone': '0999123456',
      'appointmentDuration': 45,
      'isActive': 1,
      'createdAt': now,
    });

    await db.insert('doctors', {
      'name': 'María',
      'lastName': 'Rodríguez',
      'specialty': 'Fisioterapia',
      'license': 'FISIO002',
      'email': 'maria.rodriguez@agencitas.com',
      'phone': '0999234567',
      'appointmentDuration': 45,
      'isActive': 1,
      'createdAt': now,
    });

    await db.insert('doctors', {
      'name': 'Carlos',
      'lastName': 'Mendoza',
      'specialty': 'Fisioterapia',
      'license': 'FISIO003',
      'email': 'carlos.mendoza@agencitas.com',
      'phone': '0999345678',
      'appointmentDuration': 45,
      'isActive': 1,
      'createdAt': now,
    });

    // Insert sample doctor schedules
    // Dr. María González - Monday to Friday 8:00-17:00
    for (int day = 0; day < 5; day++) {
      await db.insert('doctor_schedules', {
        'doctorId': 1,
        'dayOfWeek': day,
        'startTime': '08:00',
        'endTime': '17:00',
        'isActive': 1,
      });
    }

    // Dr. Carlos Rodríguez - Monday, Wednesday, Friday 9:00-16:00
    for (int day in [0, 2, 4]) {
      await db.insert('doctor_schedules', {
        'doctorId': 2,
        'dayOfWeek': day,
        'startTime': '09:00',
        'endTime': '16:00',
        'isActive': 1,
      });
    }

    // Dr. Ana Martínez - Tuesday, Thursday 8:00-15:00
    for (int day in [1, 3]) {
      await db.insert('doctor_schedules', {
        'doctorId': 3,
        'dayOfWeek': day,
        'startTime': '08:00',
        'endTime': '15:00',
        'isActive': 1,
      });
    }

    // Insert sample referral codes
    await db.insert('referral_codes', {
      'code': 'PROV001',
      'description': 'Código para pacientes de provincia',
      'isForProvince': 1,
      'isActive': 1,
      'createdAt': now,
    });

    await db.insert('referral_codes', {
      'code': 'REF001',
      'description': 'Código de referencia general',
      'isForProvince': 0,
      'isActive': 1,
      'createdAt': now,
    });
  }

  // Patient CRUD operations
  Future<int> insertPatient(Patient patient) async {
    if (_isWeb) {
      if (_webPatients.isEmpty) {
        _initializeWebPatients();
      }
      final newPatient = patient.copyWith(id: _nextPatientId);
      _webPatients.add(newPatient);
      _nextPatientId++;
      return newPatient.id!;
    }
    
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getAllPatients() async {
    if (_isWeb) {
      // Para web, si no hay pacientes, inicializar con datos de ejemplo
      if (_webPatients.isEmpty) {
        _initializeWebPatients();
      }
      return _webPatients.where((p) => p.isActive).toList();
    }
    
    final db = await database;
    final maps = await db.query('patients', where: 'isActive = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  void _initializeWebPatients() {
    final now = DateTime.now();
    _webPatients = [
      Patient(
        id: 1,
        name: 'Juan',
        lastName: 'Pérez',
        identification: '1234567890',
        email: 'juan.perez@email.com',
        phone: '0999123456',
        birthDate: DateTime(1985, 5, 15),
        address: 'Av. Principal 123, Quito',
        isFromProvince: false,
        createdAt: now,
      ),
      Patient(
        id: 2,
        name: 'María',
        lastName: 'González',
        identification: '0987654321',
        email: 'maria.gonzalez@email.com',
        phone: '0999234567',
        birthDate: DateTime(1990, 8, 20),
        address: 'Calle Secundaria 456, Guayaquil',
        isFromProvince: true,
        referralCode: '09',
        createdAt: now,
      ),
      Patient(
        id: 3,
        name: 'Carlos',
        lastName: 'Rodríguez',
        identification: '1122334455',
        email: 'carlos.rodriguez@email.com',
        phone: '0999345678',
        birthDate: DateTime(1988, 12, 10),
        address: 'Plaza Central 789, Cuenca',
        isFromProvince: true,
        referralCode: '01',
        createdAt: now,
      ),
    ];
    _nextPatientId = 4;
  }

  void _initializeWebAppointments() {
    final now = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    
    _webAppointments = [
      Appointment(
        id: 1,
        patientId: 1,
        doctorId: 1,
        appointmentDate: tomorrow,
        appointmentTime: const doctor_models.TimeOfDay(hour: 9, minute: 0),
        stage: AppointmentStage.first,
        status: AppointmentStatus.scheduled,
        notes: 'Primera consulta',
        createdAt: now,
      ),
      Appointment(
        id: 2,
        patientId: 2,
        doctorId: 2,
        appointmentDate: nextWeek,
        appointmentTime: const doctor_models.TimeOfDay(hour: 10, minute: 30),
        stage: AppointmentStage.first,
        status: AppointmentStatus.scheduled,
        notes: 'Consulta de seguimiento',
        referralCode: '09',
        isFromProvince: true,
        createdAt: now,
      ),
      Appointment(
        id: 3,
        patientId: 3,
        doctorId: 3,
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        appointmentTime: const doctor_models.TimeOfDay(hour: 14, minute: 0),
        stage: AppointmentStage.second,
        status: AppointmentStatus.completed,
        notes: 'Consulta completada',
        referralCode: '01',
        isFromProvince: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
    _nextAppointmentId = 4;
  }

  Future<Patient?> getPatientById(int id) async {
    if (_isWeb) {
      if (_webPatients.isEmpty) {
        _initializeWebPatients();
      }
      try {
        return _webPatients.firstWhere((p) => p.id == id);
      } catch (e) {
        return null;
      }
    }
    
    final db = await database;
    final maps = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<Patient?> getPatientByIdentification(String identification) async {
    if (_isWeb) {
      if (_webPatients.isEmpty) {
        _initializeWebPatients();
      }
      try {
        return _webPatients.firstWhere((p) => p.identification == identification);
      } catch (e) {
        return null;
      }
    }
    
    final db = await database;
    final maps = await db.query('patients', where: 'identification = ?', whereArgs: [identification]);
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updatePatient(Patient patient) async {
    if (_isWeb) {
      final index = _webPatients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _webPatients[index] = patient;
      }
      return;
    }
    
    final db = await database;
    await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // Doctor CRUD operations
  Future<List<doctor_models.Doctor>> getAllDoctors() async {
    if (_isWeb) {
      // Para web, retornamos doctores hardcodeados
      return _getWebDoctors();
    }
    
    try {
      final db = await database;
      final maps = await db.query('doctors', where: 'isActive = ?', whereArgs: [1]);
      print('Doctores encontrados en BD: ${maps.length}'); // Debug
      List<doctor_models.Doctor> doctors = [];
      
      for (var map in maps) {
        try {
          final schedules = await getDoctorSchedules(map['id'] as int);
          doctors.add(doctor_models.Doctor.fromMap(map).copyWith(schedule: schedules));
        } catch (e) {
          print('Error al procesar doctor ${map['id']}: $e'); // Debug
        }
      }
      
      print('Doctores procesados correctamente: ${doctors.length}'); // Debug
      return doctors;
    } catch (e) {
      print('Error en getAllDoctors: $e'); // Debug
      rethrow;
    }
  }

  List<doctor_models.Doctor> _getWebDoctors() {
    final now = DateTime.now();
    return [
      doctor_models.Doctor(
        id: 1,
        name: 'Luis',
        lastName: 'Hernández',
        specialty: 'Fisioterapia',
        license: 'FISIO001',
        email: 'luis.hernandez@cericitas.com',
        phone: '0999123456',
        appointmentDuration: 45,
        isActive: true,
        createdAt: now,
        schedule: [
          doctor_models.DoctorSchedule(
            doctorId: 1,
            dayOfWeek: doctor_models.DayOfWeek.monday,
            startTime: const doctor_models.TimeOfDay(hour: 8, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 17, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 1,
            dayOfWeek: doctor_models.DayOfWeek.tuesday,
            startTime: const doctor_models.TimeOfDay(hour: 8, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 17, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 1,
            dayOfWeek: doctor_models.DayOfWeek.wednesday,
            startTime: const doctor_models.TimeOfDay(hour: 8, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 17, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 1,
            dayOfWeek: doctor_models.DayOfWeek.thursday,
            startTime: const doctor_models.TimeOfDay(hour: 8, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 17, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 1,
            dayOfWeek: doctor_models.DayOfWeek.friday,
            startTime: const doctor_models.TimeOfDay(hour: 8, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 17, minute: 0),
            isActive: true,
          ),
        ],
      ),
      doctor_models.Doctor(
        id: 2,
        name: 'María',
        lastName: 'Rodríguez',
        specialty: 'Fisioterapia',
        license: 'FISIO002',
        email: 'maria.rodriguez@cericitas.com',
        phone: '0999234567',
        appointmentDuration: 45,
        isActive: true,
        createdAt: now,
        schedule: [
          doctor_models.DoctorSchedule(
            doctorId: 2,
            dayOfWeek: doctor_models.DayOfWeek.monday,
            startTime: const doctor_models.TimeOfDay(hour: 9, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 16, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 2,
            dayOfWeek: doctor_models.DayOfWeek.wednesday,
            startTime: const doctor_models.TimeOfDay(hour: 9, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 16, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 2,
            dayOfWeek: doctor_models.DayOfWeek.friday,
            startTime: const doctor_models.TimeOfDay(hour: 9, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 16, minute: 0),
            isActive: true,
          ),
        ],
      ),
      doctor_models.Doctor(
        id: 3,
        name: 'Carlos',
        lastName: 'Mendoza',
        specialty: 'Fisioterapia',
        license: 'FISIO003',
        email: 'carlos.mendoza@cericitas.com',
        phone: '0999345678',
        appointmentDuration: 45,
        isActive: true,
        createdAt: now,
        schedule: [
          doctor_models.DoctorSchedule(
            doctorId: 3,
            dayOfWeek: doctor_models.DayOfWeek.tuesday,
            startTime: const doctor_models.TimeOfDay(hour: 10, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 18, minute: 0),
            isActive: true,
          ),
          doctor_models.DoctorSchedule(
            doctorId: 3,
            dayOfWeek: doctor_models.DayOfWeek.thursday,
            startTime: const doctor_models.TimeOfDay(hour: 10, minute: 0),
            endTime: const doctor_models.TimeOfDay(hour: 18, minute: 0),
            isActive: true,
          ),
        ],
      ),
    ];
  }

  Future<doctor_models.Doctor?> getDoctorById(int id) async {
    if (_isWeb) {
      try {
        return _getWebDoctors().firstWhere((d) => d.id == id);
      } catch (e) {
        return null;
      }
    }
    
    final db = await database;
    final maps = await db.query('doctors', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final schedules = await getDoctorSchedules(id);
      return doctor_models.Doctor.fromMap(maps.first).copyWith(schedule: schedules);
    }
    return null;
  }

  Future<List<doctor_models.DoctorSchedule>> getDoctorSchedules(int doctorId) async {
    final db = await database;
    final maps = await db.query(
      'doctor_schedules',
      where: 'doctorId = ? AND isActive = ?',
      whereArgs: [doctorId, 1],
    );
    return List.generate(maps.length, (i) => doctor_models.DoctorSchedule.fromMap(maps[i]));
  }

  // Appointment CRUD operations
  Future<int> insertAppointment(Appointment appointment) async {
    if (_isWeb) {
      final newAppointment = appointment.copyWith(id: _nextAppointmentId);
      _webAppointments.add(newAppointment);
      _nextAppointmentId++;
      return newAppointment.id!;
    }
    
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAllAppointments() async {
    if (_isWeb) {
      // Para web, si no hay citas, inicializar con datos de ejemplo
      if (_webAppointments.isEmpty) {
        _initializeWebAppointments();
      }
      
      List<Appointment> appointmentsWithDetails = [];
      for (var appointment in _webAppointments) {
        final patient = _webPatients.firstWhere((p) => p.id == appointment.patientId);
        final doctors = _getWebDoctors();
        final doctor = doctors.firstWhere((d) => d.id == appointment.doctorId);
        
        appointmentsWithDetails.add(appointment.copyWith(
          patient: patient,
          doctor: doctor,
        ));
      }
      
      appointmentsWithDetails.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      return appointmentsWithDetails;
    }
    
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT a.*, p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      ORDER BY a.appointmentDate DESC, a.appointmentTime DESC
    ''');
    
    List<Appointment> appointments = [];
    for (var map in maps) {
      final appointment = Appointment.fromMap(map);
      final patient = Patient(
        id: map['patientId'] as int,
        name: map['patient_name'] as String,
        lastName: map['patient_lastName'] as String,
        identification: '',
        email: '',
        phone: '',
        birthDate: DateTime.now(),
        address: '',
        isFromProvince: false,
        createdAt: DateTime.now(),
      );
      final doctor = doctor_models.Doctor(
        id: map['doctorId'] as int,
        name: map['doctor_name'] as String,
        lastName: map['doctor_lastName'] as String,
        specialty: map['specialty'] as String,
        license: '',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
      appointments.add(appointment.copyWith(patient: patient, doctor: doctor));
    }
    
    return appointments;
  }

  Future<List<Appointment>> getAppointmentsByPatient(int patientId) async {
    if (_isWeb) {
      if (_webAppointments.isEmpty) {
        _initializeWebAppointments();
      }
      return _webAppointments.where((a) => a.patientId == patientId).toList()
        ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    }
    
    final db = await database;
    final maps = await db.query(
      'appointments',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'appointmentDate DESC',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId, DateTime date) async {
    if (_isWeb) {
      if (_webAppointments.isEmpty) {
        _initializeWebAppointments();
      }
      return _webAppointments.where((a) => 
        a.doctorId == doctorId && 
        a.appointmentDate.year == date.year &&
        a.appointmentDate.month == date.month &&
        a.appointmentDate.day == date.day &&
        a.status == AppointmentStatus.scheduled
      ).toList()
        ..sort((a, b) => a.appointmentTime.hour.compareTo(b.appointmentTime.hour));
    }
    
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final maps = await db.query(
      'appointments',
      where: 'doctorId = ? AND appointmentDate >= ? AND appointmentDate <= ? AND status = ?',
      whereArgs: [doctorId, startOfDay, endOfDay, AppointmentStatus.scheduled.index],
      orderBy: 'appointmentTime',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<void> updateAppointment(Appointment appointment) async {
    if (_isWeb) {
      final index = _webAppointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        _webAppointments[index] = appointment;
      }
      return;
    }
    
    final db = await database;
    await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  // Referral code operations
  Future<List<ReferralCode>> getAllReferralCodes() async {
    final db = await database;
    final maps = await db.query('referral_codes', where: 'isActive = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) => ReferralCode.fromMap(maps[i]));
  }

  Future<ReferralCode?> getReferralCodeByCode(String code) async {
    if (_isWeb) {
      // Para web, validar códigos de provincia directamente
      const validProvinceCodes = {
        '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
        '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
        '21', '22', '24', '26'
      };
      
      if (validProvinceCodes.contains(code)) {
        return ReferralCode(
          id: 1,
          code: code,
          description: 'Código de provincia $code',
          isForProvince: true,
          isActive: true,
          createdAt: DateTime.now(),
        );
      }
      return null;
    }
    
    final db = await database;
    final maps = await db.query('referral_codes', where: 'code = ?', whereArgs: [code]);
    if (maps.isNotEmpty) {
      return ReferralCode.fromMap(maps.first);
    }
    return null;
  }

  // Utility methods
  Future<bool> isTimeSlotAvailable(int doctorId, DateTime date, doctor_models.TimeOfDay time) async {
    final appointments = await getAppointmentsByDoctor(doctorId, date);
    return !appointments.any((apt) => apt.appointmentTime == time);
  }

  Future<List<doctor_models.TimeOfDay>> getAvailableTimeSlots(
      int doctorId, DateTime date) async {
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return [];

    final dayOfWeek = doctor_models.DayOfWeek.values[date.weekday - 1];
    final schedule = doctor.schedule.where((s) => s.dayOfWeek == dayOfWeek).isNotEmpty 
        ? doctor.schedule.where((s) => s.dayOfWeek == dayOfWeek).first 
        : null;
    if (schedule == null) return [];

    final bookedAppointments = await getAppointmentsByDoctor(doctorId, date);
    final bookedTimes = bookedAppointments.map((apt) => apt.appointmentTime).toList();

    List<doctor_models.TimeOfDay> availableSlots = [];
    var currentTime = schedule.startTime;
    
    while (currentTime.isBefore(schedule.endTime)) {
      if (!bookedTimes.contains(currentTime)) {
        availableSlots.add(currentTime);
      }
      // Add appointment duration to current time
      final totalMinutes = currentTime.hour * 60 + currentTime.minute + doctor.appointmentDuration;
      currentTime = doctor_models.TimeOfDay(
        hour: totalMinutes ~/ 60,
        minute: totalMinutes % 60,
      );
    }
    
    return availableSlots;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}