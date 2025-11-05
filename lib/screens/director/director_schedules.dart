import 'package:flutter/material.dart';

class DirectorSchedules extends StatefulWidget {
  const DirectorSchedules({Key? key}) : super(key: key);

  @override
  State<DirectorSchedules> createState() => _DirectorSchedulesState();
}

class _DirectorSchedulesState extends State<DirectorSchedules> {
  bool _isLoading = true;
  List<DoctorScheduleData> _doctorSchedules = [];
  String _selectedDay = 'Lunes';
  final List<String> _weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de horarios de doctores
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _doctorSchedules = _generateSampleSchedules();
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

  List<DoctorScheduleData> _generateSampleSchedules() {
    return [
      DoctorScheduleData(
        doctorName: 'Dr. María García',
        specialty: 'Cardiología',
        schedules: {
          'Lunes': [
            TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Juan Pérez'),
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: true, patientName: 'Ana López'),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Carlos Silva'),
            TimeSlot('15:00', '16:00', isBooked: false),
            TimeSlot('16:00', '17:00', isBooked: true, patientName: 'Laura Díaz'),
          ],
          'Martes': [
            TimeSlot('08:00', '09:00', isBooked: false),
            TimeSlot('09:00', '10:00', isBooked: true, patientName: 'Miguel Torres'),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: true, patientName: 'Carmen Ruiz'),
            TimeSlot('14:00', '15:00', isBooked: false),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Roberto Vega'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
          'Miércoles': [
            TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Patricia Santos'),
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: true, patientName: 'Fernando Cruz'),
            TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Isabel Morales'),
            TimeSlot('15:00', '16:00', isBooked: false),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
          'Jueves': [
            TimeSlot('08:00', '09:00', isBooked: false),
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: true, patientName: 'Diego Herrera'),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Sofía Ramírez'),
            TimeSlot('15:00', '16:00', isBooked: false),
            TimeSlot('16:00', '17:00', isBooked: true, patientName: 'Andrés Castillo'),
          ],
          'Viernes': [
            TimeSlot('08:00', '09:00', isBooked: true, patientName: 'Valentina Rojas'),
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: false),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Nicolás Mendoza'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
        },
      ),
      DoctorScheduleData(
        doctorName: 'Dr. Carlos Rodríguez',
        specialty: 'Neurología',
        schedules: {
          'Lunes': [
            TimeSlot('08:30', '09:30', isBooked: true, patientName: 'Elena Vargas'),
            TimeSlot('09:30', '10:30', isBooked: false),
            TimeSlot('10:30', '11:30', isBooked: true, patientName: 'Mauricio Jiménez'),
            TimeSlot('11:30', '12:30', isBooked: false),
            TimeSlot('14:30', '15:30', isBooked: true, patientName: 'Claudia Restrepo'),
            TimeSlot('15:30', '16:30', isBooked: false),
          ],
          'Martes': [
            TimeSlot('08:30', '09:30', isBooked: false),
            TimeSlot('09:30', '10:30', isBooked: true, patientName: 'Alejandro Peña'),
            TimeSlot('10:30', '11:30', isBooked: false),
            TimeSlot('11:30', '12:30', isBooked: true, patientName: 'Gabriela Ortiz'),
            TimeSlot('14:30', '15:30', isBooked: false),
            TimeSlot('15:30', '16:30', isBooked: true, patientName: 'Sebastián Flores'),
          ],
          'Miércoles': [
            TimeSlot('08:30', '09:30', isBooked: true, patientName: 'Mariana Delgado'),
            TimeSlot('09:30', '10:30', isBooked: false),
            TimeSlot('10:30', '11:30', isBooked: false),
            TimeSlot('11:30', '12:30', isBooked: true, patientName: 'Emilio Castro'),
            TimeSlot('14:30', '15:30', isBooked: true, patientName: 'Natalia Aguilar'),
            TimeSlot('15:30', '16:30', isBooked: false),
          ],
          'Jueves': [
            TimeSlot('08:30', '09:30', isBooked: false),
            TimeSlot('09:30', '10:30', isBooked: false),
            TimeSlot('10:30', '11:30', isBooked: true, patientName: 'Rodrigo Parra'),
            TimeSlot('11:30', '12:30', isBooked: false),
            TimeSlot('14:30', '15:30', isBooked: true, patientName: 'Lucía Guerrero'),
            TimeSlot('15:30', '16:30', isBooked: false),
          ],
          'Viernes': [
            TimeSlot('08:30', '09:30', isBooked: true, patientName: 'Camilo Rincón'),
            TimeSlot('09:30', '10:30', isBooked: false),
            TimeSlot('10:30', '11:30', isBooked: false),
            TimeSlot('11:30', '12:30', isBooked: false),
            TimeSlot('14:30', '15:30', isBooked: false),
            TimeSlot('15:30', '16:30', isBooked: true, patientName: 'Valeria Suárez'),
          ],
        },
      ),
      DoctorScheduleData(
        doctorName: 'Dra. Ana Martínez',
        specialty: 'Pediatría',
        schedules: {
          'Lunes': [
            TimeSlot('09:00', '10:00', isBooked: true, patientName: 'Santiago López'),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: true, patientName: 'Catalina Moreno'),
            TimeSlot('14:00', '15:00', isBooked: false),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Mateo Herrera'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
          'Martes': [
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: true, patientName: 'Isabella Gómez'),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Samuel Rivera'),
            TimeSlot('15:00', '16:00', isBooked: false),
            TimeSlot('16:00', '17:00', isBooked: true, patientName: 'Emma Vargas'),
          ],
          'Miércoles': [
            TimeSlot('09:00', '10:00', isBooked: true, patientName: 'Julián Medina'),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: true, patientName: 'Salomé Quintero'),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Tomás Navarro'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
          'Jueves': [
            TimeSlot('09:00', '10:00', isBooked: false),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: true, patientName: 'Antonella Campos'),
            TimeSlot('14:00', '15:00', isBooked: false),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Maximiliano Ruiz'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
          'Viernes': [
            TimeSlot('09:00', '10:00', isBooked: true, patientName: 'Violeta Pineda'),
            TimeSlot('10:00', '11:00', isBooked: false),
            TimeSlot('11:00', '12:00', isBooked: false),
            TimeSlot('14:00', '15:00', isBooked: false),
            TimeSlot('15:00', '16:00', isBooked: true, patientName: 'Benjamín Cortés'),
            TimeSlot('16:00', '17:00', isBooked: false),
          ],
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header con selector de día
          _buildDaySelector(),
          
          // Lista de horarios por doctor
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSchedules,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _doctorSchedules.length,
                itemBuilder: (context, index) {
                  return _buildDoctorScheduleCard(_doctorSchedules[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showScheduleOptions,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Opciones de horario',
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Horarios de Médicos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showWeekView(),
                icon: const Icon(Icons.calendar_view_week, color: Colors.white),
                tooltip: 'Vista semanal',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _weekDays.map((day) => _buildDayChip(day)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = day == _selectedDay;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDay = day;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.green[700] : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorScheduleCard(DoctorScheduleData doctorData) {
    final daySchedule = doctorData.schedules[_selectedDay] ?? [];
    final bookedSlots = daySchedule.where((slot) => slot.isBooked).length;
    final totalSlots = daySchedule.length;
    final occupancyRate = totalSlots > 0 ? (bookedSlots / totalSlots) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del doctor
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    doctorData.doctorName.split(' ')[1][0], // Primera letra del apellido
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorData.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctorData.specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador de ocupación
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getOccupancyColor(occupancyRate).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(occupancyRate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getOccupancyColor(occupancyRate),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Resumen del día
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total',
                    totalSlots.toString(),
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Ocupados',
                    bookedSlots.toString(),
                    Icons.event_busy,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Libres',
                    (totalSlots - bookedSlots).toString(),
                    Icons.event_available,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            if (daySchedule.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Horarios del día
              Text(
                'Horarios - $_selectedDay',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: daySchedule.map((slot) => _buildTimeSlotChip(slot)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildTimeSlotChip(TimeSlot slot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: slot.isBooked 
            ? Colors.red.withOpacity(0.1) 
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: slot.isBooked 
              ? Colors.red.withOpacity(0.3) 
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            slot.isBooked ? Icons.person : Icons.schedule,
            size: 12,
            color: slot.isBooked ? Colors.red[600] : Colors.green[600],
          ),
          const SizedBox(width: 4),
          Text(
            '${slot.startTime}-${slot.endTime}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: slot.isBooked ? Colors.red[700] : Colors.green[700],
            ),
          ),
          if (slot.isBooked && slot.patientName != null) ...[
            const SizedBox(width: 4),
            Container(
              constraints: const BoxConstraints(maxWidth: 60),
              child: Text(
                slot.patientName!,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getOccupancyColor(double rate) {
    if (rate >= 0.8) return Colors.red;
    if (rate >= 0.6) return Colors.orange;
    if (rate >= 0.4) return Colors.yellow[700]!;
    return Colors.green;
  }

  void _showWeekView() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vista Semanal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildWeeklyScheduleTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.green.shade50),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Doctor', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ..._weekDays.map((day) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
          ],
        ),
        // Filas de doctores
        ..._doctorSchedules.map((doctor) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.doctorName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ..._weekDays.map((day) {
              final daySchedule = doctor.schedules[day] ?? [];
              final bookedCount = daySchedule.where((slot) => slot.isBooked).length;
              final totalCount = daySchedule.length;
              
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('$bookedCount/$totalCount'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalCount > 0 ? bookedCount / totalCount : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getOccupancyColor(totalCount > 0 ? bookedCount / totalCount : 0),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        )),
      ],
    );
  }

  void _showScheduleOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de Horario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Crear Nuevo Horario'),
              onTap: () {
                Navigator.pop(context);
                _createNewSchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Modificar Horarios'),
              onTap: () {
                Navigator.pop(context);
                _modifySchedules();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.orange),
              title: const Text('Copiar Horario'),
              onTap: () {
                Navigator.pop(context);
                _copySchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.purple),
              title: const Text('Análisis de Ocupación'),
              onTap: () {
                Navigator.pop(context);
                _showOccupancyAnalysis();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createNewSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Crear nuevo horario'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _modifySchedules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Modificar horarios existentes'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copySchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Copiar horario entre doctores'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showOccupancyAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Análisis detallado de ocupación'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

class DoctorScheduleData {
  final String doctorName;
  final String specialty;
  final Map<String, List<TimeSlot>> schedules;

  DoctorScheduleData({
    required this.doctorName,
    required this.specialty,
    required this.schedules,
  });
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String? patientName;

  TimeSlot(this.startTime, this.endTime, {this.isBooked = false, this.patientName});
}