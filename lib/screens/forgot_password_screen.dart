import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular envío de correo
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha enviado un enlace de recuperación a tu correo'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
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
          'Recuperar Contraseña',
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
                  // Icono
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    'Ingresa tu usuario y correo electrónico. Te enviaremos un enlace para restablecer tu contraseña.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (!_emailSent) ...[
                    // Campo Usuario
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        hintText: 'Ingresa tu usuario',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.person_outline),
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
                    const SizedBox(height: 16),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'correo@ejemplo.com',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese su correo';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón Enviar
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
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
                                'Enviar Enlace de Recuperación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ] else ...[
                    // Mensaje de éxito
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mark_email_read,
                            size: 60,
                            color: Colors.green[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '¡Correo Enviado!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Volver al Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Link para volver
                  if (!_emailSent)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0066CC),
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
