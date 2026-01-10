
// intyerfaz de los horarios de la citas programadas del doctor


import 'package:flutter/material.dart';

class DoctorSchedule extends StatefulWidget {
  final String doctorId;

  const DoctorSchedule({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  bool _isLoading = true;
  Map<String, List<TimeSlot>> _schedule = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de horarios del doctor
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _schedule = _generateSampleSchedule();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar horarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 

  //HORARIOS PREDEFINIDOS 
  Map<String, List<TimeSlot>> _generateSampleSchedule() {
    return {
      'Lunes': [
        TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Juan Pérez'),
        TimeSlot('09:00', '10:00', isBooked: false),
        TimeSlot('10:00', '11:00', isBooked: true, patientName: 'María García'),
        TimeSlot('11:00', '12:00', isBooked: false),
        TimeSlot('14:00', '15:00', isBooked: false),
        TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Carlos López'),
        TimeSlot('16:00', '17:00', isBooked: false),
      ],
      'Martes': [
        TimeSlot('08:00', '09:00', isBooked: false),
        TimeSlot('09:00', '10:00', isBooked: true, patientName: 'Ana Martínez'),
        TimeSlot('10:00', '11:00', isBooked: false),
        TimeSlot('11:00', '12:00', isBooked: false),
        TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Roberto Silva'),
        TimeSlot('15:00', '16:00', isBooked: false),
        TimeSlot('16:00', '17:00', isBooked: false),
      ],
      'Miércoles': [
        TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Laura Rodríguez'),
        TimeSlot('09:00', '10:00', isBooked: false),
        TimeSlot('10:00', '11:00', isBooked: false),
        TimeSlot('11:00', '12:00', isBooked: true, patientName: 'Diego Morales'),
        TimeSlot('14:00', '15:00', isBooked: false),
        TimeSlot('15:00', '16:00', isBooked: false),
        TimeSlot('16:00', '17:00', isBooked: true, patientName: 'Patricia Vega'),
      ],
      'Jueves': [
        TimeSlot('08:00', '09:00', isBooked: false),
        TimeSlot('09:00', '10:00', isBooked: false),
        TimeSlot('10:00', '11:00', isBooked: true, patientName: 'Miguel Santos'),
        TimeSlot('11:00', '12:00', isBooked: false),
        TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Carmen Díaz'),
        TimeSlot('15:00', '16:00', isBooked: false),
        TimeSlot('16:00', '17:00', isBooked: false),
      ],
      'Viernes': [
        TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Fernando Cruz'),
        TimeSlot('09:00', '10:00', isBooked: false),
        TimeSlot('10:00', '11:00', isBooked: false),
        TimeSlot('11:00', '12:00', isBooked: false),
        TimeSlot('14:00', '15:00', isBooked: false),
        TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Isabel Torres'),
        TimeSlot('16:00', '17:00', isBooked: false),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header con fecha seleccionada y resumen
          _buildScheduleHeader(),
          
          // Lista de días de la semana
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _schedule.entries.map((entry) {
                return _buildDaySchedule(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader() {
    // Calcular estadísticas de la semana
    int totalSlots = 0;
    int bookedSlots = 0;
    int availableSlots = 0;

    _schedule.forEach((day, slots) {
      totalSlots += slots.length;
      bookedSlots += slots.where((slot) => slot.isBooked).length;
      availableSlots += slots.where((slot) => !slot.isBooked).length;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[700]!,
            Colors.green[500]!,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi Horario Semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showCalendarPicker(),
                icon: const Icon(Icons.calendar_today, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Resumen de la semana
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Total', totalSlots, Icons.schedule, Colors.blue),
                _buildSummaryItem('Ocupados', bookedSlots, Icons.event_busy, Colors.red),
                _buildSummaryItem('Disponibles', availableSlots, Icons.event_available, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(String day, List<TimeSlot> slots) {
    final bookedCount = slots.where((slot) => slot.isBooked).length;
    final availableCount = slots.where((slot) => !slot.isBooked).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$bookedCount ocupados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$availableCount libres',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Grid de horarios
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) => _buildTimeSlotCard(slot)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    return GestureDetector(
      onTap: () => _handleSlotTap(slot),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: slot.isBooked 
              ? Colors.red.withOpacity(0.1) 
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: slot.isBooked 
                ? Colors.red.withOpacity(0.3) 
                : Colors.green.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  slot.isBooked ? Icons.event_busy : Icons.event_available,
                  size: 16,
                  color: slot.isBooked ? Colors.red[600] : Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${slot.startTime} - ${slot.endTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: slot.isBooked ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              ],
            ),
            if (slot.isBooked && slot.patientName != null) ...[
              const SizedBox(height: 4),
              Text(
                slot.patientName!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!slot.isBooked) ...[
              const SizedBox(height: 4),
              Text(
                'Disponible',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSlotTap(TimeSlot slot) {
    if (slot.isBooked) {
      _showAppointmentDetails(slot);
    } else {
      _showScheduleOptions(slot);
    }
  }

  void _showAppointmentDetails(TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Hora:', '${slot.startTime} - ${slot.endTime}'),
            _buildDetailRow('Paciente:', slot.patientName ?? 'No especificado'),
            _buildDetailRow('Estado:', 'Confirmada'),
            _buildDetailRow('Tipo:', 'Consulta médica'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAppointmentActions(slot);
            },
            child: const Text('Acciones'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAppointmentActions(TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar Cita'),
              onTap: () {
                Navigator.pop(context);
                _editAppointment(slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelar Cita'),
              onTap: () {
                Navigator.pop(context);
                _cancelAppointment(slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Reprogramar'),
              onTap: () {
                Navigator.pop(context);
                _rescheduleAppointment(slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Contactar Paciente'),
              onTap: () {
                Navigator.pop(context);
                _contactPatient(slot);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleOptions(TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Horario: ${slot.startTime} - ${slot.endTime}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('Agendar Paciente'),
              onTap: () {
                Navigator.pop(context);
                _schedulePatient(slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Bloquear Horario'),
              onTap: () {
                Navigator.pop(context);
                _blockTimeSlot(slot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Modificar Horario'),
              onTap: () {
                Navigator.pop(context);
                _modifyTimeSlot(slot);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
        // Aquí cargarías los horarios para la semana seleccionada
        _loadSchedule();
      }
    });
  }

  // Métodos de acciones (implementación básica)
  void _editAppointment(TimeSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar cita de ${slot.patientName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _cancelAppointment(TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Text('¿Está seguro que desea cancelar la cita de ${slot.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita cancelada'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(TimeSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reprogramar cita de ${slot.patientName}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _contactPatient(TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${slot.patientName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Llamar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Iniciando llamada...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Enviar mensaje'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo mensajes...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _schedulePatient(TimeSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendar paciente en ${slot.startTime} - ${slot.endTime}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _blockTimeSlot(TimeSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Horario ${slot.startTime} - ${slot.endTime} bloqueado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _modifyTimeSlot(TimeSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modificar horario ${slot.startTime} - ${slot.endTime}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String? patientName;

  TimeSlot(this.startTime, this.endTime, {this.isBooked = false, this.patientName});
}
