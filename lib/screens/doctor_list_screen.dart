import 'package:agencitas/services/api_doctores.dart';
//import 'package:agencitas/services/mysql_service.dart';
import 'package:flutter/material.dart';
import '../models/doctor.dart' as doctor_models;
import '../widgets/logout_button.dart';

class DoctorListScreen extends StatefulWidget {
  final Function(doctor_models.Doctor)? onDoctorSelected;

  const DoctorListScreen({super.key, this.onDoctorSelected});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {

  // Instancia del servicio API
  final ApiDoctores api = ApiDoctores();

  List<doctor_models.Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final response = await api.getDoctors();

    final doctors = response
        .map<doctor_models.Doctor>(
            (json) => doctor_models.Doctor.fromJson(json))
        .toList();

    setState(() {
      _doctors = doctors;
      _isLoading = false;
    });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar doctores')),
        );
      }
    }
  }

  String _getScheduleText(doctor_models.Doctor doctor) {
    if (doctor.schedule.isEmpty) {
      return 'Sin horarios definidos';
    }

    Map<String, List<doctor_models.DoctorSchedule>> groupedSchedules = {};
    for (var schedule in doctor.schedule) {
      final timeRange = '${schedule.startTime} - ${schedule.endTime}';
      if (groupedSchedules.containsKey(timeRange)) {
        groupedSchedules[timeRange]!.add(schedule);
      } else {
        groupedSchedules[timeRange] = [schedule];
      }
    }

    List<String> scheduleTexts = [];
    groupedSchedules.forEach((timeRange, schedules) {
      final days = schedules.map((s) => s.dayOfWeek.displayName).join(', ');
      scheduleTexts.add('$days: $timeRange');
    });

    return scheduleTexts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Doctores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          LogoutButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay doctores disponibles',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: widget.onDoctorSelected != null
                              ? () => widget.onDoctorSelected!(doctor)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor.fullName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              doctor.specialty,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.onDoctorSelected != null)
                                      const Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Duración de cita: ${doctor.appointmentDuration} minutos',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        doctor.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      doctor.phone,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Horarios de atención:',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getScheduleText(doctor),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
