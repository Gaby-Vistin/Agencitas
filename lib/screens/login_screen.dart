// lib/screens/login_screen.dart
import 'package:agencitas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user.dart';
import 'director/director_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'patient/patient_dashboard.dart';
import 'receptionist/receptionist_dashboard.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Estado del LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = await AuthService.login(username, password);

      if (user != null) {
        // Asume que tienes una clase SessionManager que maneja el estado global
        SessionManager.login(user);

        if (mounted) {
          switch (user.role) {
            case UserRole.administrador:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => DirectorDashboard(director: user)),
              );
              break;
            case UserRole.director:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => DirectorDashboard(director: user)),
              );
              break;
            case UserRole.doctor:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => DoctorDashboard(doctor: user)),
              );
              break;
            case UserRole.patient:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => PatientDashboard(patient: user)),
              );
              break;
            case UserRole.receptionist:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ReceptionistDashboard(receptionist: user)),
              );
              break;
            default:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
          }
        }
      } else {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Muestra un cuadro de diálogo con las credenciales de prueba
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
            ///Text('• enfermera / enfermera123'),
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

 // clase bluid para construir la interfaz de usuario
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
                  // Header con Logo y Título
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(3)),
                                child: const Center(child: Text('m', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(color: const Color(0xFF0066CC), borderRadius: BorderRadius.circular(3)),
                                child: const Center(child: Text('s', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: 11,
                                height: 20,
                                decoration: BoxDecoration(color: const Color(0xFFE31E24), borderRadius: BorderRadius.circular(3)),
                                child: const Center(child: Text('p', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'CERICITAS',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Ingresa tu usuario',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600], size: 22),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13, color: Color(0xFF0066CC), decoration: TextDecoration.underline)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showCredentialsInfo,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Ver credenciales de prueba'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  Text('v1.0.0 - Ministerio de Salud Pública', style: TextStyle(fontSize: 12, color: Colors.grey[500]), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}