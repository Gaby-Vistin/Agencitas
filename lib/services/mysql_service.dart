

//import 'dart:convert';
import 'package:agencitas/models/user.dart';
//import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';
import '../models/patient.dart';
import '../models/doctor.dart' as doctor_models;
import '../models/appointment.dart';
//import 'package:http/http.dart' as http;

class MySQLDatabaseService {
  // Se implementa el patrón singleton para asegurar una única instancia
  static final MySQLDatabaseService _instance = MySQLDatabaseService._internal();
  factory MySQLDatabaseService() => _instance;
  MySQLDatabaseService._internal();

  // Se mantiene una única conexión a la base de datos
  static MySQLConnection? _connection;



  // ==================== Database Configuration ====================
  /*static const _host = 'gateway01.us-east-1.prod.aws.tidbcloud.com';
  static const _port = 4000;
  static const _user = 'h3NPkNWYTaaTzXC.root';
  static const _password = 'AlQdL1PhzouzQ8BZ';
  static const _db = 'test';
  static const _secure = true;*/
   

  // Conexion mediante la API REST para web
  static const _host = 'localhost'; // o 'localhost'
  static const _port = 3308;
  static const _user = 'root';
  static const _password = 'root'; // Pon aquí tu contraseña real!
  static const _db = 'citas_medicas'; // Nombre de la base de datos
  static const _secure = false; //

  // Obtiene la conexión a la base de datos, inicializándola si es necesario
  Future<MySQLConnection> get connection async {
    if (_connection != null && _connection!.connected) return _connection!;
    _connection = await _initConnection();
    return _connection!;
  }

  Future<MySQLConnection> _initConnection() async {
    try {
      // Se intenta conectar a la base de datos especificada
      final conn = await MySQLConnection.createConnection(
        host: _host,
        port: _port,
        userName: _user,
        password: _password,
        databaseName: _db,
        secure: _secure
      );
      await conn.connect();
      return conn;
    } catch (e) {
      print('Error al conectarse a la base de datos $_db: $e');
      print('Intentando crear la base de datos...');
      try {
        final conn = await MySQLConnection.createConnection(
          host: _host,
          port: _port,
          userName: _user,
          password: _password,
          secure: _secure
        );
        await conn.connect();
        await conn.execute('CREATE DATABASE IF NOT EXISTS $_db');
        await conn.close();
        print('Base de datos creada/verificada. Reconectando...');
        
        final newConn = await MySQLConnection.createConnection(
          host: _host,
          port: _port,
          userName: _user,
          password: _password,
          databaseName: _db,
          secure: _secure
        );
        await newConn.connect();
        return newConn;
      } catch (e2) {
         print('Error crítico al conectar a MySQL: $e2');
         rethrow;
      }
    }
  }
  
  
  // ==================== Database Initialization ====================

  Future<void> initializeDatabase() async {
    try {
      final conn = await connection;
      
      // Tabla de usuarios
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(255) NOT NULL UNIQUE,
          displayName VARCHAR(255),
          role INT NOT NULL,
          email VARCHAR(255),
          password VARCHAR(255) NOT NULL,
          isActive BOOLEAN DEFAULT TRUE,
          createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Tabla de pacientes
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS patients (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          lastName VARCHAR(255) NOT NULL,
          identification VARCHAR(50) UNIQUE NOT NULL,
          email VARCHAR(255),
          phone VARCHAR(50),
          birthDate DATE,
          address TEXT,
          referralCode VARCHAR(50),
          isFromProvince BOOLEAN DEFAULT FALSE,
          missedAppointments INT DEFAULT 0,
          currentStage INT DEFAULT 0,
          isActive BOOLEAN DEFAULT TRUE,
          createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
          updatedAt DATETIME ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // Tabla de doctores
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS doctors (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          lastName VARCHAR(255) NOT NULL,
          specialty VARCHAR(255),
          license VARCHAR(100),
          email VARCHAR(255),
          phone VARCHAR(50),
          appointmentDuration INT DEFAULT 30,
          isActive BOOLEAN DEFAULT TRUE,
          createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
          updatedAt DATETIME ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // Tabla de horarios de doctores
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS doctor_schedules (
          id INT AUTO_INCREMENT PRIMARY KEY,
          doctorId INT NOT NULL,
          dayOfWeek INT NOT NULL,
          startTime VARCHAR(5) NOT NULL,
          endTime VARCHAR(5) NOT NULL,
          isActive BOOLEAN DEFAULT TRUE,
          FOREIGN KEY (doctorId) REFERENCES doctors(id) ON DELETE CASCADE
        )
      ''');

      // Tabla de códigos de referencia
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS referral_codes (
          id INT AUTO_INCREMENT PRIMARY KEY,
          code VARCHAR(50) UNIQUE NOT NULL,
          description VARCHAR(255),
          isForProvince BOOLEAN DEFAULT FALSE,
          isActive BOOLEAN DEFAULT TRUE,
          expiryDate DATETIME,
          createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
          updatedAt DATETIME ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // Tabla de citas
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS appointments (
          id INT AUTO_INCREMENT PRIMARY KEY,
          patientId INT NOT NULL,
          doctorId INT NOT NULL,
          appointmentDate DATE NOT NULL,
          appointmentTime TIME NOT NULL,
          status INT DEFAULT 0,
          stage INT DEFAULT 0,
          therapyStatus INT DEFAULT 0,
          notes TEXT,
          referralCode VARCHAR(50),
          isFromProvince BOOLEAN DEFAULT FALSE,
          cancelledAt DATETIME,
          cancellationReason TEXT,
          createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
          updatedAt DATETIME ON UPDATE CURRENT_TIMESTAMP,
          FOREIGN KEY (patientId) REFERENCES patients(id),
          FOREIGN KEY (doctorId) REFERENCES doctors(id)
        )
      ''');

      await _initializeSeedData(conn);

      print('Tablas de la base de datos inicializadas con éxito');
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  // ==================== Database Seeding ====================

  Future<void> _initializeSeedData(MySQLConnection conn) async {
    // Se verifica individualmente si existe al menos un usuario de cada rol

    // 1. Rol Director
    final directorCheck = await conn.execute('SELECT COUNT(*) as count FROM users WHERE role = :role', {'role': UserRole.director.index});
    if (_parseInt(directorCheck.rows.first.assoc()['count']) == 0) {
      print('Insertando usuario Director por defecto...');
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'director',
        'displayName': 'Juan Carlos Rodríguez',
        'role': UserRole.director.index,
        'email': 'director@agencitas.com',
        'password': 'director123',
        'isActive': 1
      });
    }

    // 2. Rol Doctor
    final doctorCheck = await conn.execute('SELECT COUNT(*) as count FROM users WHERE role = :role', {'role': UserRole.doctor.index});
    if (_parseInt(doctorCheck.rows.first.assoc()['count']) == 0) {
      print('Insertando usuario Doctor por defecto...');
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'doctor',
        'displayName': 'María Elena García',
        'role': UserRole.doctor.index,
        'email': 'doctor@agencitas.com',
        'password': 'doctor123',
        'isActive': 1
      });
    }

    // 3. Rol Enfermera (Incluye Admin y Enfermera)
    final nurseCheck = await conn.execute('SELECT COUNT(*) as count FROM users WHERE role = :role', {'role': UserRole.nurse.index});
    if (_parseInt(nurseCheck.rows.first.assoc()['count']) == 0) {
      print('Insertando usuarios Admin y Enfermera por defecto...');
      // Usuario Administrador
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'admin',
        'displayName': 'Admin User',
        'role': UserRole.nurse.index,
        'email': 'admin@agencitas.com',
        'password': 'admin123',
        'isActive': 1
      });
      
      // Usuario Enfermera
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'enfermera',
        'displayName': 'Ana López',
        'role': UserRole.nurse.index,
        'email': 'enfermera@agencitas.com',
        'password': 'enfermera123',
        'isActive': 1
      });
    }

    // 4. Rol Recepcionista
    final receptionistCheck = await conn.execute('SELECT COUNT(*) as count FROM users WHERE role = :role', {'role': UserRole.receptionist.index});
    if (_parseInt(receptionistCheck.rows.first.assoc()['count']) == 0) {
      print('Insertando usuario Recepcionista por defecto...');
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'recepcionista',
        'displayName': 'Laura Fernández',
        'role': UserRole.receptionist.index,
        'email': 'recepcion@agencitas.com',
        'password': 'recepcion123',
        'isActive': 1
      });
    }

    // 5. Rol Paciente
    final patientCheck = await conn.execute('SELECT COUNT(*) as count FROM users WHERE role = :role', {'role': UserRole.patient.index});
    if (_parseInt(patientCheck.rows.first.assoc()['count']) == 0) {
      print('Insertando usuario Paciente por defecto...');
      await conn.execute('''
        INSERT INTO users (username, displayName, role, email, password, isActive)
        VALUES (:username, :displayName, :role, :email, :password, :isActive)
      ''', {
        'username': 'paciente',
        'displayName': 'Carlos Antonio Pérez',
        'role': UserRole.patient.index,
        'email': 'paciente@agencitas.com',
        'password': 'paciente123',
        'isActive': 1
      });
    }

    // Se verifica si existen doctores, si no, se insertan los doctores iniciales junto con sus horarios y códigos de referencia
    final doctorsCheck = await conn.execute('SELECT COUNT(*) as count FROM doctors');
    final doctorCount = _parseInt(doctorsCheck.rows.first.assoc()['count']);
    
    if (doctorCount == 0) {
      print('Seeding database with initial doctors, schedules, and referral codes...');
      
      // Doctor 1: Luis Hernández
      final res1 = await conn.execute('''
        INSERT INTO doctors (name, lastName, specialty, license, email, phone, appointmentDuration, isActive, createdAt)
        VALUES (:name, :lastName, :specialty, :license, :email, :phone, :appointmentDuration, :isActive, NOW())
      ''', {
        'name': 'Luis',
        'lastName': 'Hernández',
        'specialty': 'Fisioterapia',
        'license': 'FISIO001',
        'email': 'luis.hernandez@agencitas.com',
        'phone': '0999123456',
        'appointmentDuration': 45,
        'isActive': 1
      });
      final id1 = res1.lastInsertID.toInt();

      // Horarios para el Doctor 1 (Lun-Vie 08:00-17:00)
      for (int day = 0; day < 5; day++) {
         await conn.execute('''
           INSERT INTO doctor_schedules (doctorId, dayOfWeek, startTime, endTime, isActive)
           VALUES (:doctorId, :dayOfWeek, :startTime, :endTime, :isActive)
         ''', {
           'doctorId': id1,
           'dayOfWeek': day,
           'startTime': '08:00',
           'endTime': '17:00',
           'isActive': 1
         });
      }

      // Doctor 2: María Rodríguez
      final res2 = await conn.execute('''
        INSERT INTO doctors (name, lastName, specialty, license, email, phone, appointmentDuration, isActive, createdAt)
        VALUES (:name, :lastName, :specialty, :license, :email, :phone, :appointmentDuration, :isActive, NOW())
      ''', {
        'name': 'María',
        'lastName': 'Rodríguez',
        'specialty': 'Fisioterapia',
        'license': 'FISIO002',
        'email': 'maria.rodriguez@agencitas.com',
        'phone': '0999234567',
        'appointmentDuration': 45,
        'isActive': 1
      });
      final id2 = res2.lastInsertID.toInt();

      // Horarios para el Doctor 2 (Lun, Mie, Vie 09:00-16:00)
      for (int day in [0, 2, 4]) {
         await conn.execute('''
           INSERT INTO doctor_schedules (doctorId, dayOfWeek, startTime, endTime, isActive)
           VALUES (:doctorId, :dayOfWeek, :startTime, :endTime, :isActive)
         ''', {
           'doctorId': id2,
           'dayOfWeek': day,
           'startTime': '09:00',
           'endTime': '16:00',
           'isActive': 1
         });
      }

      // Doctor 3: Carlos Mendoza
      final res3 = await conn.execute('''
        INSERT INTO doctors (name, lastName, specialty, license, email, phone, appointmentDuration, isActive, createdAt)
        VALUES (:name, :lastName, :specialty, :license, :email, :phone, :appointmentDuration, :isActive, NOW())
      ''', {
        'name': 'Carlos',
        'lastName': 'Mendoza',
        'specialty': 'Fisioterapia',
        'license': 'FISIO003',
        'email': 'carlos.mendoza@agencitas.com',
        'phone': '0999345678',
        'appointmentDuration': 45,
        'isActive': 1
      });
      final id3 = res3.lastInsertID.toInt();

      // Horarios para el Doctor 3 (Mar, Jue 08:00-15:00)
      for (int day in [1, 3]) {
         await conn.execute('''
           INSERT INTO doctor_schedules (doctorId, dayOfWeek, startTime, endTime, isActive)
           VALUES (:doctorId, :dayOfWeek, :startTime, :endTime, :isActive)
         ''', {
           'doctorId': id3,
           'dayOfWeek': day,
           'startTime': '08:00',
           'endTime': '15:00',
           'isActive': 1
         });
      }

      // Códigos de referencia
      await conn.execute('''
        INSERT INTO referral_codes (code, description, isForProvince, isActive, createdAt)
        VALUES (:code, :description, :isForProvince, :isActive, NOW())
      ''', {
        'code': 'PROV001',
        'description': 'Código para pacientes de provincia',
        'isForProvince': 1,
        'isActive': 1
      });

      await conn.execute('''
        INSERT INTO referral_codes (code, description, isForProvince, isActive, createdAt)
        VALUES (:code, :description, :isForProvince, :isActive, NOW())
      ''', {
        'code': 'REF001',
        'description': 'Código de referencia general',
        'isForProvince': 0,
        'isActive': 1
      });
      
      print('Initial doctors, schedules, and referral codes inserted successfully.');
    }

    // Se verifica si existen códigos de provincias, si no, se insertan
    final provincesCheck = await conn.execute("SELECT COUNT(*) as count FROM referral_codes WHERE isForProvince = 1 AND code != 'PROV001'");
    final provinceCount = _parseInt(provincesCheck.rows.first.assoc()['count']);

    if (provinceCount == 0) {
      print('Seeding database with province referral codes...');
      
      final provinces = [
        {'name': 'Azuay', 'code': '01'},
        {'name': 'Bolívar', 'code': '02'},
        {'name': 'Cañar', 'code': '03'},
        {'name': 'Carchi', 'code': '04'},
        {'name': 'Cotopaxi', 'code': '05'},
        {'name': 'Chimborazo', 'code': '06'},
        {'name': 'El Oro', 'code': '07'},
        {'name': 'Esmeraldas', 'code': '08'},
        {'name': 'Guayas', 'code': '09'},
        {'name': 'Imbabura', 'code': '10'},
        {'name': 'Loja', 'code': '11'},
        {'name': 'Los Ríos', 'code': '12'},
        {'name': 'Manabí', 'code': '13'},
        {'name': 'Morona Santiago', 'code': '14'},
        {'name': 'Napo', 'code': '15'},
        {'name': 'Pastaza', 'code': '16'},
        {'name': 'Pichincha', 'code': '17'},
        {'name': 'Tungurahua', 'code': '18'},
        {'name': 'Zamora Chinchipe', 'code': '19'},
        {'name': 'Galápagos', 'code': '20'},
        {'name': 'Sucumbíos', 'code': '21'},
        {'name': 'Orellana', 'code': '22'},
        {'name': 'Santo Domingo de los Tsáchilas', 'code': '24'},
        {'name': 'Santa Elena', 'code': '26'},
      ];

      for (var province in provinces) {
        await conn.execute('''
          INSERT INTO referral_codes (code, description, isForProvince, isActive, createdAt)
          VALUES (:code, :description, :isForProvince, :isActive, NOW())
        ''', {
          'code': province['code'],
          'description': province['name'],
          'isForProvince': 1,
          'isActive': 1
        });
      }
      print('Province referral codes inserted successfully.');
    }

    // Verificar si existen pacientes
    final patientsCheck = await conn.execute('SELECT COUNT(*) as count FROM patients');
    final patientCount = _parseInt(patientsCheck.rows.first.assoc()['count']);

    if (patientCount == 0) {
      print('Seeding database with initial patients and appointments...');
      
      // Patient 1
      var resP1 = await conn.execute('''
        INSERT INTO patients (name, lastName, identification, email, phone, birthDate, address, referralCode, isFromProvince, isActive, createdAt)
        VALUES (:name, :lastName, :identification, :email, :phone, :birthDate, :address, :referralCode, :isFromProvince, :isActive, NOW())
      ''', {
        'name': 'Carlos', 'lastName': 'Pérez', 'identification': '0900000001',
        'email': 'carlos.perez@test.com', 'phone': '0990000001', 'birthDate': '1990-01-01',
        'address': 'Av. Principal 123', 'referralCode': 'REF001', 'isFromProvince': 0, 'isActive': 1
      });
      final p1Id = resP1.lastInsertID.toInt();

      // Patient 2
      var resP2 = await conn.execute('''
        INSERT INTO patients (name, lastName, identification, email, phone, birthDate, address, referralCode, isFromProvince, isActive, createdAt)
        VALUES (:name, :lastName, :identification, :email, :phone, :birthDate, :address, :referralCode, :isFromProvince, :isActive, NOW())
      ''', {
        'name': 'Ana', 'lastName': 'López', 'identification': '0100000002',
        'email': 'ana.lopez@test.com', 'phone': '0990000002', 'birthDate': '1992-05-15',
        'address': 'Calle Larga 456', 'referralCode': 'PROV001', 'isFromProvince': 1, 'isActive': 1
      });
      final p2Id = resP2.lastInsertID.toInt();

      // Appointments
      // Get a valid doctor ID (assuming doctor seeding ran before)
      final docCheck = await conn.execute('SELECT id FROM doctors LIMIT 1');
      if (docCheck.rows.isNotEmpty) {
        final docId = _parseInt(docCheck.rows.first.assoc()['id']);
        final today = DateTime.now();
        
        // Appointment 1: Scheduled today
        await conn.execute('''
          INSERT INTO appointments (patientId, doctorId, appointmentDate, appointmentTime, status, stage, therapyStatus, notes, referralCode, isFromProvince, createdAt)
          VALUES (:patientId, :doctorId, :appointmentDate, :appointmentTime, :status, :stage, :therapyStatus, :notes, :referralCode, :isFromProvince, NOW())
        ''', {
          'patientId': p1Id, 'doctorId': docId, 
          'appointmentDate': today.toIso8601String().split('T')[0],
          'appointmentTime': '10:00:00',
          'status': AppointmentStatus.scheduled.index,
          'stage': AppointmentStage.first.index,
          'therapyStatus': TherapyStatus.notStarted.index,
          'notes': 'Primera consulta',
          'referralCode': 'REF001',
          'isFromProvince': 0
        });

        // Appointment 2: Completed yesterday
        final yesterday = today.subtract(const Duration(days: 1));
        await conn.execute('''
          INSERT INTO appointments (patientId, doctorId, appointmentDate, appointmentTime, status, stage, therapyStatus, notes, referralCode, isFromProvince, createdAt)
          VALUES (:patientId, :doctorId, :appointmentDate, :appointmentTime, :status, :stage, :therapyStatus, :notes, :referralCode, :isFromProvince, NOW())
        ''', {
          'patientId': p2Id, 'doctorId': docId, 
          'appointmentDate': yesterday.toIso8601String().split('T')[0],
          'appointmentTime': '15:00:00',
          'status': AppointmentStatus.completed.index,
          'stage': AppointmentStage.second.index,
          'therapyStatus': TherapyStatus.inProgress.index,
          'notes': 'Seguimiento mensual',
          'referralCode': 'PROV001',
          'isFromProvince': 1
        });
      }
      print('Initial patients and appointments inserted successfully.');
    }
  }

  // ==================== Helper for parsing ====================
  
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final str = value.toString().toLowerCase();
    return str == '1' || str == 'true';
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
  
  DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // ==================== User Management ====================
Future<User?> login(String username, String password) async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM users WHERE username = :username AND password = :password AND isActive = 1',
      {'username': username, 'password': password}
    );

    if (results.rows.isEmpty) return null;
    return _userFromRow(results.rows.first);
  }

  User _userFromRow(ResultSetRow row) {
    final data = row.assoc();
    return User(
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      role: UserRole.values[_parseInt(data['role'])],
      email: data['email'] ?? '',
      isActive: _parseBool(data['isActive']),
      createdAt: _parseDateTime(data['createdAt']),
    );
  }
 

  // ==================== CRUD Patients ====================

  Future<int> insertPatient(Patient patient) async {
    final conn = await connection;
    var result = await conn.execute('''
      INSERT INTO patients (name, lastName, identification, email, phone, birthDate, 
                           address, referralCode, isFromProvince, missedAppointments, 
                           currentStage, isActive, createdAt)
      VALUES (:name, :lastName, :identification, :email, :phone, :birthDate, 
              :address, :referralCode, :isFromProvince, :missedAppointments, 
              :currentStage, :isActive, :createdAt)
    ''', {
      'name': patient.name,
      'lastName': patient.lastName,
      'identification': patient.identification,
      'email': patient.email,
      'phone': patient.phone,
      'birthDate': patient.birthDate.toIso8601String().split('T')[0],
      'address': patient.address,
      'referralCode': patient.referralCode,
      'isFromProvince': patient.isFromProvince ? 1 : 0,
      'missedAppointments': patient.missedAppointments,
      'currentStage': patient.currentStage.index,
      'isActive': patient.isActive ? 1 : 0,
      'createdAt': patient.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    });
    return result.lastInsertID.toInt();
  }

  Future<List<Patient>> getAllPatients() async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM patients WHERE isActive = TRUE ORDER BY lastName, name'
    );
    
    return results.rows.map((row) => _patientFromRow(row)).toList();
  }

  Future<Patient?> getPatientById(int id) async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM patients WHERE id = :id', {'id': id}
    );
    
    if (results.rows.isEmpty) return null;
    return _patientFromRow(results.rows.first);
  }

  Future<Patient?> getPatientByIdentification(String identification) async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM patients WHERE identification = :identification', 
      {'identification': identification}
    );
    
    if (results.rows.isEmpty) return null;
    return _patientFromRow(results.rows.first);
  }

  Future<void> updatePatient(Patient patient) async {
    final conn = await connection;
    await conn.execute('''
      UPDATE patients SET 
        name = :name, lastName = :lastName, identification = :identification, 
        email = :email, phone = :phone, birthDate = :birthDate, 
        address = :address, referralCode = :referralCode, 
        isFromProvince = :isFromProvince, missedAppointments = :missedAppointments, 
        currentStage = :currentStage, isActive = :isActive, updatedAt = NOW()
      WHERE id = :id
    ''', {
      'name': patient.name,
      'lastName': patient.lastName,
      'identification': patient.identification,
      'email': patient.email,
      'phone': patient.phone,
      'birthDate': patient.birthDate.toIso8601String().split('T')[0],
      'address': patient.address,
      'referralCode': patient.referralCode,
      'isFromProvince': patient.isFromProvince ? 1 : 0,
      'missedAppointments': patient.missedAppointments,
      'currentStage': patient.currentStage.index,
      'isActive': patient.isActive ? 1 : 0,
      'id': patient.id,
    });
  }

  Future<void> deletePatient(int id) async {
    final conn = await connection;
    await conn.execute(
      'UPDATE patients SET isActive = FALSE, updatedAt = NOW() WHERE id = :id', 
      {'id': id}
    );
  }

  Patient _patientFromRow(ResultSetRow row) {
    final data = row.assoc();
    return Patient(
      id: _parseInt(data['id']),
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      identification: data['identification'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      birthDate: _parseDateTime(data['birthDate']),
      address: data['address'] ?? '',
      referralCode: data['referralCode'],
      isFromProvince: _parseBool(data['isFromProvince']),
      missedAppointments: _parseInt(data['missedAppointments']),
      currentStage: AppointmentStage.values[_parseInt(data['currentStage'])],
      isActive: _parseBool(data['isActive']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
    );
  }

  // ==================== CRUD Doctors ====================

  Future<List<doctor_models.Doctor>> getAllDoctors() async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM doctors WHERE isActive = TRUE ORDER BY lastName, name'
    );
    
    List<doctor_models.Doctor> doctors = [];
    for (var row in results.rows) {
      var doctor = await _doctorFromRow(row);
      doctors.add(doctor);
    }
    return doctors;
  }

  Future<doctor_models.Doctor?> getDoctorById(int id) async {
    final conn = await connection;
    var results = await conn.execute('SELECT * FROM doctors WHERE id = :id', {'id': id});
    
    if (results.rows.isEmpty) return null;
    return await _doctorFromRow(results.rows.first);
  }

  Future<int> insertDoctor(doctor_models.Doctor doctor) async {
     final conn = await connection;
     var result = await conn.execute('''
      INSERT INTO doctors (name, lastName, specialty, license, email, phone, 
                           appointmentDuration, isActive, createdAt)
      VALUES (:name, :lastName, :specialty, :license, :email, :phone, 
              :appointmentDuration, :isActive, :createdAt)
    ''', {
      'name': doctor.name,
      'lastName': doctor.lastName,
      'specialty': doctor.specialty,
      'license': doctor.license,
      'email': doctor.email,
      'phone': doctor.phone,
      'appointmentDuration': doctor.appointmentDuration,
      'isActive': doctor.isActive ? 1 : 0,
      'createdAt': doctor.createdAt.toIso8601String(),
    });
    
    int doctorId = result.lastInsertID.toInt();
    
    // Insert schedules
    for (var schedule in doctor.schedule) {
      await insertDoctorSchedule(schedule, doctorId);
    }
    
    return doctorId;
  }

  Future<void> insertDoctorSchedule(doctor_models.DoctorSchedule schedule, int doctorId) async {
    final conn = await connection;
    await conn.execute('''
      INSERT INTO doctor_schedules (doctorId, dayOfWeek, startTime, endTime, isActive)
      VALUES (:doctorId, :dayOfWeek, :startTime, :endTime, :isActive)
    ''', {
      'doctorId': doctorId,
      'dayOfWeek': schedule.dayOfWeek.index,
      'startTime': '${schedule.startTime.hour}:${schedule.startTime.minute}',
      'endTime': '${schedule.endTime.hour}:${schedule.endTime.minute}',
      'isActive': schedule.isActive ? 1 : 0,
    });
  }

  Future<List<doctor_models.DoctorSchedule>> getDoctorSchedules(int doctorId) async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM doctor_schedules WHERE doctorId = :doctorId AND isActive = TRUE',
      {'doctorId': doctorId}
    );
    
    return results.rows.map((row) {
      final data = row.assoc();
      final startTimeParts = data['startTime'].toString().split(':');
      final endTimeParts = data['endTime'].toString().split(':');
      
      return doctor_models.DoctorSchedule(
        id: _parseInt(data['id']),
        doctorId: _parseInt(data['doctorId']),
        dayOfWeek: doctor_models.DayOfWeek.values[_parseInt(data['dayOfWeek'])],
        startTime: doctor_models.TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1]),
        ),
        endTime: doctor_models.TimeOfDay(
          hour: int.parse(endTimeParts[0]),
          minute: int.parse(endTimeParts[1]),
        ),
        isActive: _parseBool(data['isActive']),
      );
    }).toList();
  }

  Future<doctor_models.Doctor> _doctorFromRow(ResultSetRow row) async {
    final data = row.assoc();
    final id = _parseInt(data['id']);
    final schedules = await getDoctorSchedules(id);
    
    return doctor_models.Doctor(
      id: id,
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      specialty: data['specialty'] ?? '',
      license: data['license'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      appointmentDuration: _parseInt(data['appointmentDuration']),
      isActive: _parseBool(data['isActive']),
      schedule: schedules,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
    );
  }

  // ==================== CRUD Appointments ====================

  Future<int> insertAppointment(Appointment appointment) async {
    final conn = await connection;
    var result = await conn.execute('''
      INSERT INTO appointments (patientId, doctorId, appointmentDate, appointmentTime,
                               status, stage, therapyStatus, notes, referralCode, 
                               isFromProvince, createdAt)
      VALUES (:patientId, :doctorId, :appointmentDate, :appointmentTime,
              :status, :stage, :therapyStatus, :notes, :referralCode, 
              :isFromProvince, :createdAt)
    ''', {
      'patientId': appointment.patientId,
      'doctorId': appointment.doctorId,
      'appointmentDate': appointment.appointmentDate.toIso8601String().split('T')[0],
      'appointmentTime': '${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute}:00',
      'status': appointment.status.index,
      'stage': appointment.stage.index,
      'therapyStatus': appointment.therapyStatus.index,
      'notes': appointment.notes,
      'referralCode': appointment.referralCode,
      'isFromProvince': appointment.isFromProvince ? 1 : 0,
      'createdAt': appointment.createdAt.toIso8601String(),
    });
    return result.lastInsertID.toInt();
  }

  Future<Appointment?> getAppointmentById(int id) async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT a.*, 
             p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      WHERE a.id = :id
    ''', {'id': id});
    
    if (results.rows.isEmpty) return null;
    return _appointmentFromRow(results.rows.first);
  }

  Future<List<Appointment>> getAllAppointments() async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT a.*, 
             p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      ORDER BY a.appointmentDate DESC, a.appointmentTime DESC
    ''');
    
    return results.rows.map((row) => _appointmentFromRow(row)).toList();
  }

  Future<List<Appointment>> getAppointmentsByPatient(int patientId) async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT a.*, 
             p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      WHERE a.patientId = :patientId
      ORDER BY a.appointmentDate DESC
    ''', {'patientId': patientId});
    
    return results.rows.map((row) => _appointmentFromRow(row)).toList();
  }

  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId) async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT a.*, 
             p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      WHERE a.doctorId = :doctorId
      ORDER BY a.appointmentDate DESC
    ''', {'doctorId': doctorId});
    
    return results.rows.map((row) => _appointmentFromRow(row)).toList();
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT a.*, 
             p.name as patient_name, p.lastName as patient_lastName,
             d.name as doctor_name, d.lastName as doctor_lastName, d.specialty
      FROM appointments a
      JOIN patients p ON a.patientId = p.id
      JOIN doctors d ON a.doctorId = d.id
      WHERE DATE(a.appointmentDate) = :date
      ORDER BY a.appointmentTime
    ''', {'date': date.toIso8601String().split('T')[0]});
    
    return results.rows.map((row) => _appointmentFromRow(row)).toList();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final conn = await connection;
    await conn.execute('''
      UPDATE appointments SET 
        status = :status, stage = :stage, therapyStatus = :therapyStatus, notes = :notes, 
        cancelledAt = :cancelledAt, cancellationReason = :cancellationReason, updatedAt = NOW()
      WHERE id = :id
    ''', {
      'status': appointment.status.index,
      'stage': appointment.stage.index,
      'therapyStatus': appointment.therapyStatus.index,
      'notes': appointment.notes,
      'cancelledAt': appointment.cancelledAt?.toIso8601String(),
      'cancellationReason': appointment.cancellationReason,
      'id': appointment.id,
    });
  }

  Appointment _appointmentFromRow(ResultSetRow row) {
    final data = row.assoc();
    final timeParts = data['appointmentTime'].toString().split(':');
    
    Patient? patient;
    if (data['patient_name'] != null) {
      patient = Patient(
        id: _parseInt(data['patientId']),
        name: data['patient_name']!,
        lastName: data['patient_lastName']!,
        identification: '', 
        email: '',
        phone: '',
        birthDate: DateTime.now(),
        address: '',
        isFromProvince: false,
        createdAt: DateTime.now(),
      );
    }

    doctor_models.Doctor? doctor;
    if (data['doctor_name'] != null) {
      doctor = doctor_models.Doctor(
        id: _parseInt(data['doctorId']),
        name: data['doctor_name']!,
        lastName: data['doctor_lastName']!,
        specialty: data['specialty'] ?? '',
        license: '',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
    }

    return Appointment(
      id: _parseInt(data['id']),
      patientId: _parseInt(data['patientId']),
      doctorId: _parseInt(data['doctorId']),
      appointmentDate: _parseDateTime(data['appointmentDate']),
      appointmentTime: doctor_models.TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      status: AppointmentStatus.values[_parseInt(data['status'])],
      stage: AppointmentStage.values[_parseInt(data['stage'])],
      therapyStatus: TherapyStatus.values[_parseInt(data['therapyStatus'])],
      notes: data['notes'],
      referralCode: data['referralCode'],
      isFromProvince: _parseBool(data['isFromProvince']),
      patient: patient,
      doctor: doctor,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
      cancelledAt: _parseNullableDateTime(data['cancelledAt']),
      cancellationReason: data['cancellationReason'],
    );
  }

  // ==================== Referral Codes ====================

  Future<ReferralCode?> getReferralCode(String code) async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM referral_codes WHERE code = :code AND isActive = TRUE',
      {'code': code}
    );
    
    if (results.rows.isEmpty) return null;
    return _referralCodeFromRow(results.rows.first);
  }

  Future<List<ReferralCode>> getAllReferralCodes() async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM referral_codes WHERE isActive = TRUE ORDER BY code'
    );
    
    return results.rows.map((row) => _referralCodeFromRow(row)).toList();
  }
  
  Future<int> insertReferralCode(ReferralCode code) async {
    final conn = await connection;
    var result = await conn.execute('''
      INSERT INTO referral_codes (code, description, isForProvince, isActive, expiryDate, createdAt)
      VALUES (:code, :description, :isForProvince, :isActive, :expiryDate, :createdAt)
    ''', {
      'code': code.code,
      'description': code.description,
      'isForProvince': code.isForProvince ? 1 : 0,
      'isActive': code.isActive ? 1 : 0,
      'expiryDate': code.expiryDate?.toIso8601String(),
      'createdAt': code.createdAt.toIso8601String(),
    });
    return result.lastInsertID.toInt();
  }

  Future<List<ReferralCode>> getProvinceReferralCodes() async {
    final conn = await connection;
    var results = await conn.execute(
      'SELECT * FROM referral_codes WHERE isForProvince = TRUE AND isActive = TRUE ORDER BY description'
    );
    
    return results.rows.map((row) => _referralCodeFromRow(row)).toList();
  }

  ReferralCode _referralCodeFromRow(ResultSetRow row) {
    final data = row.assoc();
    return ReferralCode(
      id: _parseInt(data['id']),
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      isForProvince: _parseBool(data['isForProvince']),
      isActive: _parseBool(data['isActive']),
      expiryDate: _parseNullableDateTime(data['expiryDate']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
    );
  }
  
  Future<void> updateDoctor(doctor_models.Doctor doctor) async {
    final conn = await connection;
    await conn.execute('''
      UPDATE doctors SET 
        name = :name, lastName = :lastName, specialty = :specialty, 
        license = :license, email = :email, phone = :phone, 
        appointmentDuration = :appointmentDuration, isActive = :isActive, 
        updatedAt = NOW()
      WHERE id = :id
    ''', {
      'name': doctor.name,
      'lastName': doctor.lastName,
      'specialty': doctor.specialty,
      'license': doctor.license,
      'email': doctor.email,
      'phone': doctor.phone,
      'appointmentDuration': doctor.appointmentDuration,
      'isActive': doctor.isActive ? 1 : 0,
      'id': doctor.id,
    });
  }

  Future<bool> resetPassword(String username, String email, String newPassword) async {
    final conn = await connection;
    
    // Verificar si el usuario existe
    var results = await conn.execute(
      'SELECT id FROM users WHERE username = :username AND email = :email AND isActive = 1',
      {'username': username, 'email': email}
    );

    if (results.rows.isEmpty) return false;

    // Actualizar contraseña
    await conn.execute(
      'UPDATE users SET password = :password WHERE username = :username',
      {'password': newPassword, 'username': username}
    );

    return true;
  }

  Future<bool> changePassword(String username, String currentPassword, String newPassword) async {
    final conn = await connection;

    // Verificar la contraseña actual
    var results = await conn.execute(
      'SELECT id FROM users WHERE username = :username AND password = :password AND isActive = 1',
      {'username': username, 'password': currentPassword}
    );

    if (results.rows.isEmpty) {
      return false; // Contraseña actual incorrecta
    }

    // Actualizar a la nueva contraseña
    await conn.execute(
      'UPDATE users SET password = :password WHERE username = :username',
      {'password': newPassword, 'username': username}
    );

    return true;
  }

  // ==================== Utilities ====================

  Future<bool> isTimeSlotAvailable(int doctorId, DateTime date, doctor_models.TimeOfDay time) async {
    final conn = await connection;
    var results = await conn.execute('''
      SELECT COUNT(*) as count FROM appointments
      WHERE doctorId = :doctorId AND appointmentDate = :date AND appointmentTime = :time AND status != :status
    ''', {
      'doctorId': doctorId, 
      'date': date.toIso8601String().split('T')[0], 
      'time': '${time.hour}:${time.minute}:00', 
      'status': AppointmentStatus.cancelled.index
    });
    
    // COUNT(*) returns a row with 'count' key
    return _parseInt(results.rows.first.assoc()['count']) == 0;
  }

  Future<List<doctor_models.TimeOfDay>> getAvailableTimeSlots(int doctorId, DateTime date) async {
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return [];

    final dayOfWeek = date.weekday;
    final schedule = doctor.schedule.where((s) => s.dayOfWeek.index + 1 == dayOfWeek).firstOrNull;
    if (schedule == null) return [];

    final List<doctor_models.TimeOfDay> slots = [];
    var currentTime = schedule.startTime;
    while (currentTime.toDateTime().isBefore(schedule.endTime.toDateTime())) {
      slots.add(currentTime);
      currentTime = currentTime.addMinutes(doctor.appointmentDuration);
    }

    final bookedSlots = await getAppointmentsByDate(date);
    final availableSlots = slots.where((slot) {
      return !bookedSlots.any((booked) =>
          booked.doctorId == doctorId &&
          booked.appointmentTime.hour == slot.hour &&
          booked.appointmentTime.minute == slot.minute &&
          booked.status != AppointmentStatus.cancelled);
    }).toList();

    return availableSlots;
  }
  
  Future<Map<String, dynamic>> getDashboardStats() async {
     return {
       'patients': await getPatientCount(),
       'doctors': await getDoctorCount(),
       'appointments': await getAppointmentCount(),
     };
  }
  
  
  // ==================== Statistics ====================
  //Tener el numero total de doctores
  Future<int> getDoctorCount() async {
    final conn = await connection;
    var result = await conn.execute('SELECT COUNT(*) as count FROM doctors WHERE isActive = TRUE');
    return _parseInt(result.rows.first.assoc()['count']);
  }
  
  //Obtener el total de pacientes activos
  Future<int> getPatientCount() async {
    final conn = await connection;
    var result = await conn.execute('SELECT COUNT(*) as count FROM patients WHERE isActive = TRUE');
    return _parseInt(result.rows.first.assoc()['count']);
  }
  

  //Obtener el total de citas no canceladas
  Future<int> getAppointmentCount() async {
    final conn = await connection;
    var result = await conn.execute('SELECT COUNT(*) as count FROM appointments WHERE status != :status', 
        {'status': AppointmentStatus.cancelled.index});
    return _parseInt(result.rows.first.assoc()['count']);
  }

  Future<Map<String, dynamic>> getDoctorStats(int doctorId) async {
    final conn = await connection;
    
    // 1. Total Patients (Distinct patients seen by this doctor)
    final patientsRes = await conn.execute(
      'SELECT COUNT(DISTINCT patientId) as count FROM appointments WHERE doctorId = :id',
      {'id': doctorId}
    );
    final totalPatients = _parseInt(patientsRes.rows.first.assoc()['count']);

    // 2. Today's Appointments
    final todayRes = await conn.execute(
      'SELECT COUNT(*) as count FROM appointments WHERE doctorId = :id AND DATE(appointmentDate) = CURDATE()',
      {'id': doctorId}
    );
    final todayAppointments = _parseInt(todayRes.rows.first.assoc()['count']);

    // 3. Weekly Appointments
    final weeklyRes = await conn.execute(
      'SELECT COUNT(*) as count FROM appointments WHERE doctorId = :id AND YEARWEEK(appointmentDate, 1) = YEARWEEK(CURDATE(), 1)',
      {'id': doctorId}
    );
    final weeklyAppointments = _parseInt(weeklyRes.rows.first.assoc()['count']);

    // 4. Appointment Status Counts
    final statusRes = await conn.execute(
      'SELECT status, COUNT(*) as count FROM appointments WHERE doctorId = :id GROUP BY status',
      {'id': doctorId}
    );
    
    int completed = 0;
    int cancelled = 0;
    int scheduled = 0;

    for (var row in statusRes.rows) {
      final data = row.assoc();
      final status = AppointmentStatus.values[_parseInt(data['status'])];
      final count = _parseInt(data['count']);
      
      if (status == AppointmentStatus.completed) completed = count;
      if (status == AppointmentStatus.cancelled) cancelled = count;
      if (status == AppointmentStatus.scheduled) scheduled = count;
    }

    // 5. Therapy Status Counts
    final therapyRes = await conn.execute(
      'SELECT therapyStatus, COUNT(*) as count FROM appointments WHERE doctorId = :id GROUP BY therapyStatus',
      {'id': doctorId}
    );

    int notStarted = 0;
    int inProgress = 0;
    int therapyCompleted = 0;

    for (var row in therapyRes.rows) {
      final data = row.assoc();
      final status = TherapyStatus.values[_parseInt(data['therapyStatus'])];
      final count = _parseInt(data['count']);
      
      if (status == TherapyStatus.notStarted) notStarted = count;
      if (status == TherapyStatus.inProgress) inProgress = count;
      if (status == TherapyStatus.completed) therapyCompleted = count;
    }

    return {
      'totalPatients': totalPatients,
      'todayAppointments': todayAppointments,
      'weeklyAppointments': weeklyAppointments,
      'completedAppointments': completed,
      'cancelledAppointments': cancelled,
      'scheduledAppointments': scheduled,
      'therapiesNotStarted': notStarted,
      'therapiesInProgress': inProgress,
      'therapiesCompleted': therapyCompleted,
    };
  }

  Future<void> closeConnection() async {
    if (_connection != null) {
        await _connection!.close();
        _connection = null;
    }
  }
  
  
   
} //end MysqlService

extension TimeOfDayExtension on doctor_models.TimeOfDay {
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  doctor_models.TimeOfDay addMinutes(int minutes) {
    final dt = toDateTime().add(Duration(minutes: minutes));
    return doctor_models.TimeOfDay(hour: dt.hour, minute: dt.minute);
  }
}
