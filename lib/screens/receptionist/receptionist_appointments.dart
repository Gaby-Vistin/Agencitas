import 'package:flutter/material.dart';

class ReceptionistAppointments extends StatefulWidget {
  const ReceptionistAppointments({Key? key}) : super(key: key);

  @override
  State<ReceptionistAppointments> createState() => _ReceptionistAppointmentsState();
}

class _ReceptionistAppointmentsState extends State<ReceptionistAppointments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.purple[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Gestión de Citas',
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
