import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart';

class DirectorTherapyStatus extends StatefulWidget {
  const DirectorTherapyStatus({Key? key}) : super(key: key);

  @override
  State<DirectorTherapyStatus> createState() => _DirectorTherapyStatusState();
}

class _DirectorTherapyStatusState extends State<DirectorTherapyStatus> {
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  List<Patient> _patients = [];
  List<Doctor> _doctors = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulación de carga de datos
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _appointments = []; // Cargar desde la base de datos
        _patients = []; // Cargar desde la base de datos
        _doctors = []; // Cargar desde la base de datos
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'all') {
      return _appointments;
    }
    
    TherapyStatus filterStatus;
    switch (_selectedFilter) {
      case 'notStarted':
        filterStatus = TherapyStatus.notStarted;
        break;
      case 'inProgress':
        filterStatus = TherapyStatus.inProgress;
        break;
      case 'completed':
        filterStatus = TherapyStatus.completed;
        break;
      default:
        return _appointments;
    }
    
    return _appointments.where((appointment) => appointment.therapyStatus == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header con semáforo principal
          _buildTherapyStatusHeader(),
          
          // Filtros
          _buildFilterSection(),
          
          // Lista de terapias
          Expanded(
            child: _buildTherapyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyStatusHeader() {
    final notStartedCount = _appointments.where((a) => a.therapyStatus == TherapyStatus.notStarted).length;
    final inProgressCount = _appointments.where((a) => a.therapyStatus == TherapyStatus.inProgress).length;
    final completedCount = _appointments.where((a) => a.therapyStatus == TherapyStatus.completed).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[800]!,
            Colors.blue[600]!,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Semáforo de Terapias',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Semáforo visual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrafficLight(
                  TherapyStatus.notStarted,
                  notStartedCount,
                  'Sin Iniciar',
                ),
                Container(
                  height: 80,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildTrafficLight(
                  TherapyStatus.inProgress,
                  inProgressCount,
                  'En Progreso',
                ),
                Container(
                  height: 80,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildTrafficLight(
                  TherapyStatus.completed,
                  completedCount,
                  'Completadas',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: ${_appointments.length} terapias',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLight(TherapyStatus status, int count, String label) {
    final isSelected = (_selectedFilter == 'notStarted' && status == TherapyStatus.notStarted) ||
                     (_selectedFilter == 'inProgress' && status == TherapyStatus.inProgress) ||
                     (_selectedFilter == 'completed' && status == TherapyStatus.completed);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilter == status.toString().split('.').last) {
            _selectedFilter = 'all';
          } else {
            _selectedFilter = status.toString().split('.').last;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? status.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: status.color, width: 2) : null,
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: status.color.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? status.color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Filtros:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Todas', Icons.list),
                  const SizedBox(width: 8),
                  _buildFilterChip('notStarted', 'Sin Iniciar', Icons.play_circle_outline),
                  const SizedBox(width: 8),
                  _buildFilterChip('inProgress', 'En Progreso', Icons.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'Completadas', Icons.check_circle),
                ],
              ),
            ),
          ),
          Text(
            '${_filteredAppointments.length} resultados',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[700],
      side: BorderSide(
        color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildTherapyList() {
    if (_filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.traffic,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay terapias para mostrar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all' 
                  ? 'No hay terapias registradas'
                  : 'No hay terapias con este estado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _filteredAppointments[index];
          return _buildTherapyCard(appointment);
        },
      ),
    );
  }

  Widget _buildTherapyCard(Appointment appointment) {
    final patient = _patients.firstWhere(
      (p) => p.id == appointment.patientId,
      orElse: () => Patient(
        id: 0,
        name: 'Paciente',
        lastName: 'Desconocido',
        identification: '00000000',
        birthDate: DateTime.now(),
        isFromProvince: false,
        createdAt: DateTime.now(),
      ),
    );

    final doctor = _doctors.firstWhere(
      (d) => d.id == appointment.doctorId,
      orElse: () => Doctor(
        id: 0,
        name: 'Doctor',
        lastName: 'Desconocido',
        specialty: '',
        license: '',
        phone: '',
        email: '',
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Indicador de estado principal
                Container(
                  width: 12,
                  height: 60,
                  decoration: BoxDecoration(
                    color: appointment.therapyStatus.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del paciente y doctor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dr. ${doctor.fullName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'ID: ${patient.identification}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Estado visual grande
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: appointment.therapyStatus.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: appointment.therapyStatus.color,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    appointment.therapyStatus.icon,
                    color: appointment.therapyStatus.color,
                    size: 30,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de la cita
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment.therapyStatus.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appointment.therapyStatus.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    appointment.therapyStatus.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: appointment.therapyStatus.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Acciones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTherapyDetails(appointment, patient, doctor),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Detalles'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _changeTherapyStatus(appointment),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Cambiar Estado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appointment.therapyStatus.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTherapyDetails(Appointment appointment, Patient patient, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Terapia'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Paciente', patient.fullName),
              _buildDetailItem('Identificación', patient.identification),
              _buildDetailItem('Médico', doctor.fullName),
              _buildDetailItem('Especialidad', doctor.specialty),
              _buildDetailItem('Fecha', 
                '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}'),
              _buildDetailItem('Hora', 
                '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}'),
              _buildDetailItem('Estado de Cita', _getAppointmentStatusText(appointment.status)),
              _buildDetailItem('Estado de Terapia', appointment.therapyStatus.displayName),
              if (appointment.notes?.isNotEmpty == true)
                _buildDetailItem('Notas', appointment.notes!),
              if (appointment.referralCode?.isNotEmpty == true)
                _buildDetailItem('Código de Remisión', appointment.referralCode!),
            ],
          ),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.noShow:
        return 'No se presentó';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  void _changeTherapyStatus(Appointment appointment) {
    TherapyStatus? newStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado de Terapia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TherapyStatus.values.map((status) {
            return RadioListTile<TherapyStatus>(
              title: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status.icon,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(status.displayName),
                ],
              ),
              value: status,
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value;
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: newStatus != null ? () {
              Navigator.pop(context);
              _updateTherapyStatus(appointment, newStatus!);
            } : null,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _updateTherapyStatus(Appointment appointment, TherapyStatus newStatus) {
    // Aquí actualizarías la base de datos
    setState(() {
      // Simular actualización
      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        // En una implementación real, crearías una nueva instancia
        // _appointments[index] = appointment.copyWith(therapyStatus: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado de terapia actualizado a: ${newStatus.displayName}'),
        backgroundColor: newStatus.color,
      ),
    );
  }
}
