import 'package:flutter/material.dart';

class ReceptionistPatients extends StatefulWidget {
  const ReceptionistPatients({Key? key}) : super(key: key);

  @override
  State<ReceptionistPatients> createState() => _ReceptionistPatientsState();
}

class _ReceptionistPatientsState extends State<ReceptionistPatients> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 80,
              color: Colors.purple[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Gestión de Pacientes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Módulo en desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
