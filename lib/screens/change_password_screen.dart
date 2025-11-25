import 'package:flutter/material.dart';
import '../models/user.dart';

class ChangePasswordScreen extends StatefulWidget {
  final User user;

  const ChangePasswordScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Contraseñas actuales (simuladas - en producción estarían en base de datos)
  final Map<String, String> _currentPasswords = {
    'admin': 'admin123',
    'doctor': 'doctor123',
    'enfermera': 'enfermera123',
    'recepcionista': 'recepcion123',
    'director': 'director123',
    'paciente': 'paciente123',
  };

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular proceso de cambio de contraseña
    await Future.delayed(const Duration(milliseconds: 500));

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // Verificar contraseña actual
    if (_currentPasswords[widget.user.username] != currentPassword) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña actual es incorrecta'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Actualizar contraseña (en producción, actualizar en base de datos)
    _currentPasswords[widget.user.username] = newPassword;

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Contraseña Actualizada!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu contraseña ha sido cambiada exitosamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a pantalla anterior
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
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
        title: const Text(
          'Cambiar Contraseña',
          style: TextStyle(color: Colors.black87),
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
                  // Icono y título
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Actualiza tu Contraseña',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Usuario: ${widget.user.displayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Campo Contraseña Actual
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: !_isCurrentPasswordVisible,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      hintText: 'Ingresa tu contraseña actual',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
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
                        return 'Por favor ingrese su contraseña actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Nueva Contraseña
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_isNewPasswordVisible,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      hintText: 'Ingresa tu nueva contraseña',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
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
                        return 'Por favor ingrese su nueva contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'La nueva contraseña debe ser diferente a la actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Confirmar Contraseña
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                      hintText: 'Confirma tu nueva contraseña',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                        return 'Por favor confirme su nueva contraseña';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Requisitos de contraseña
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requisitos de contraseña:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Mínimo 6 caracteres\n• Diferente a la contraseña actual',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Cambiar Contraseña
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
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
                              'Cambiar Contraseña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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
