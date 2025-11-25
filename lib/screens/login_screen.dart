import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user.dart';
import 'director/director_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'patient/patient_dashboard.dart';

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
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    
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
        child: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
      ),
    );
  }

  // Layout para pantallas anchas (inspirado en Banco Pichincha)
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Panel izquierdo - Información
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo MSP grande
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMSPLetter('m', const Color(0xFFFFD700), 22, 40),
                        const SizedBox(width: 4),
                        _buildMSPLetter('s', const Color(0xFF0066CC), 22, 40),
                        const SizedBox(width: 4),
                        _buildMSPLetter('p', const Color(0xFFE31E24), 22, 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verifica en tu navegador que estás\nen CERICITAS.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'https://agencitas.msp.gob.ec/login',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Ilustración simple
                Icon(
                  Icons.health_and_safety,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '01. Cuida tu usuario y contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '02. Antes de ingresar verifica que los últimos dígitos de tu cédula scan correctos.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel derecho - Formulario
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Layout para móviles
  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo MSP
            Container(
              width: 80,
              height: 80,
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
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMSPLetter('m', const Color(0xFFFFD700), 14, 26),
                    const SizedBox(width: 2),
                    _buildMSPLetter('s', const Color(0xFF0066CC), 14, 26),
                    const SizedBox(width: 2),
                    _buildMSPLetter('p', const Color(0xFFE31E24), 14, 26),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'CERICITAS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  // Formulario de login
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bienvenido a tu CERICITAS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          
          // Campo Usuario
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Usuario',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ingresa tu usuario',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showCredentialsInfo,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '¿Olvidaste tu usuario?',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0066CC),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Campo Contraseña
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contraseña',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showCredentialsInfo,
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
            ],
          ),
          const SizedBox(height: 32),
          
          // Botón Ingresar (estilo Banco Pichincha)
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Amarillo
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Opciones adicionales
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _showCredentialsInfo,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '¿Cuenta bloqueada? Desbloquéala aquí',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _showCredentialsInfo,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '¿Usuario nuevo? Regístrate ahora',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Texto de versión
          Text(
            'v1.0.0 - Ministerio de Salud Pública',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper para construir las letras del logo MSP
  Widget _buildMSPLetter(String letter, Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
