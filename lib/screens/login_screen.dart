import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user.dart';
import 'director/director_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'patient/patient_dashboard.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Credenciales por defecto (en una app real esto estaría en una base de datos)
  final Map<String, String> _validCredentials = {
    'admin': 'admin123',
    'doctor': 'doctor123',
    'enfermera': 'enfermera123',
    'recepcionista': 'recepcion123',
    'director': 'director123', // Agregado para el director
    'paciente': 'paciente123', // Agregado para el paciente
  };

  // Usuarios de prueba para el sistema del director
  final List<User> _demoUsers = [
    User(
      username: 'director',
      displayName: 'Juan Carlos Rodríguez',
      email: 'director@agencitas.com',
      role: UserRole.director,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    User(
      username: 'doctor',
      displayName: 'María Elena García',
      email: 'doctor@agencitas.com',
      role: UserRole.doctor,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    User(
      username: 'paciente',
      displayName: 'Carlos Antonio Pérez',
      email: 'paciente@agencitas.com',
      role: UserRole.patient,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular delay de autenticación
    await Future.delayed(const Duration(milliseconds: 300));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_validCredentials.containsKey(username) && 
        _validCredentials[username] == password) {
      
      // Verificar si es el director para redirigir al panel especial
      if (username == 'director') {
        // Buscar el usuario director
        final directorUser = _demoUsers.firstWhere(
          (user) => user.username == 'director',
          orElse: () => User(
            username: 'director',
            displayName: 'Director del Centro',
            email: 'director@agencitas.com',
            role: UserRole.director,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        
        // Establecer sesión
        SessionManager.login(directorUser);
        
        // Navegar al panel del director
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DirectorDashboard(director: directorUser),
            ),
          );
        }
      } else if (username == 'doctor') {
        // Buscar el usuario doctor
        final doctorUser = _demoUsers.firstWhere(
          (user) => user.username == 'doctor',
          orElse: () => User(
            username: 'doctor',
            displayName: 'María Elena García',
            email: 'doctor@agencitas.com',
            role: UserRole.doctor,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        
        // Establecer sesión
        SessionManager.login(doctorUser);
        
        // Navegar al panel del doctor
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(doctor: doctorUser),
            ),
          );
        }
      } else if (username == 'paciente') {
        // Buscar el usuario paciente
        final patientUser = _demoUsers.firstWhere(
          (user) => user.username == 'paciente',
          orElse: () => User(
            username: 'paciente',
            displayName: 'Carlos Antonio Pérez',
            email: 'paciente@agencitas.com',
            role: UserRole.patient,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        
        // Establecer sesión
        SessionManager.login(patientUser);
        
        // Navegar al panel del paciente
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PatientDashboard(patient: patientUser),
            ),
          );
        }
      } else {
        // Login exitoso para otros usuarios - ir al HomeScreen original
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } else {
      // Login fallido
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCredentialsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credenciales de Acceso'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuarios disponibles:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• admin / admin123'),
            Text('• director / director123'),
            Text('• doctor / doctor123'),
            Text('• paciente / paciente123'),
            Text('• enfermera / enfermera123'),
            Text('• recepcionista / recepcion123'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Regresar',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Header con Logo y Título vertical
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo MSP
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Letra "m"
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Letra "s"
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066CC),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    's',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Letra "p"
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE31E24),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'p',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Título
                      const Text(
                        'CERICITAS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  
                  // Campo Usuario
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Ingresa tu usuario',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese su usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Link ¿Olvidaste tu contraseña?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0066CC),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Botón Iniciar Sesión
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón de ayuda
                  TextButton.icon(
                    onPressed: _showCredentialsInfo,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Ver credenciales de prueba'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Texto de versión
                  Text(
                    'v1.0.0 - Ministerio de Salud Pública',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
