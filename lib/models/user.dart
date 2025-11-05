enum UserRole {
  director,
  doctor,
  nurse,
  receptionist,
  patient;

  String get displayName {
    switch (this) {
      case UserRole.director:
        return 'Director';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Enfermera';
      case UserRole.receptionist:
        return 'Recepcionista';
      case UserRole.patient:
        return 'Paciente';
    }
  }

  String get description {
    switch (this) {
      case UserRole.director:
        return 'Acceso completo al sistema, estadísticas y gestión';
      case UserRole.doctor:
        return 'Gestión de pacientes y citas médicas';
      case UserRole.nurse:
        return 'Asistencia médica y seguimiento de pacientes';
      case UserRole.receptionist:
        return 'Registro de pacientes y agenda de citas';
      case UserRole.patient:
        return 'Gestión personal de citas y seguimiento médico';
    }
  }
}

class User {
  final String username;
  final String displayName;
  final UserRole role;
  final String email;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.username,
    required this.displayName,
    required this.role,
    required this.email,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'displayName': displayName,
      'role': role.index,
      'email': email,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      role: UserRole.values[map['role'] ?? 0],
      email: map['email'] ?? '',
      isActive: (map['isActive'] ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}

// Gestión de sesión
class SessionManager {
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static bool get isLoggedIn => _currentUser != null;
  
  static bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }
  
  static bool hasAnyRole(List<UserRole> roles) {
    return _currentUser != null && roles.contains(_currentUser!.role);
  }
  
  static void login(User user) {
    _currentUser = user;
  }
  
  static void logout() {
    _currentUser = null;
  }
}