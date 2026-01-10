//---------------------------------------------------------------
//             MENU PRINCIPAL - HOME SCREEN
//---------------------------------------------------------------

//--------------------------------------
// IMPORTACION DE LIBRERIAS
//--------------------------------------
//import 'package:agencitas/services/mysql_service.dart';


import 'package:flutter/material.dart'; //Flutter Framework
import '../widgets/logout_button.dart'; // Boton de Cerrar Sesion

// Importacion de servicios para conexion con la API
import 'package:agencitas/services/api_doctores.dart';
import 'package:agencitas/services/api_registro_paciente.dart';
import 'package:agencitas/services/appointment_service.dart';

// Importacion de pantallas
import 'patient_registration_screen.dart'; // Pantalla de Registro de Pacientes
import 'patient_list_screen.dart'; // Pantalla de Lista de Pacientes
import 'doctor_list_screen.dart'; // Pantalla de Lista de Doctores
import 'appointment_scheduling_screen.dart'; // Pantalla de Agendar Cita
import 'appointment_list_screen.dart'; // Pantalla de Lista de Citas


// CLASE PRINCIPAL - HOME SCREEN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //final MySQLDatabaseService _dbService = MySQLDatabaseService();

 // DELACARACION DE INSTANCIAS DE SERVICIOS (Agencitas/lib/services)
  //Pacientes
  final ApiRegistroPaciente api = ApiRegistroPaciente(); //Service (api_registro_paciente) 
  //Citas
  final AppointmentService apiCitas = AppointmentService(); //Servicio para citas (appointment_service.dart)
  //Doctores
  final ApiDoctores apiDoctores = ApiDoctores(); //Servicio (api_doctores.dart)

  
  //DECLARACION DE VARIABLES PARA ESTADISTICAS DE LAS METRICAS DEL DASHBOARD
    
    int _totalPatients = 0;//Total Pacientes
    int _appointments = 0;//Variable para contar el total de citas  
    int _activePatients = 0;//Varviables para pacientes activos
    int _doctorCount = 0;//Variable para total de doctores
    bool _isLoading = true;
  
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

//---------------------------------
// CARGAR LOS DATOS AL DASHBOARD
//---------------------------------

  Future<void> _loadDashboardData() async {
    try {
      //PACIENTES (metodo llamado de "api_registro_paciente.dart")
      final totalPatients = await api.getTotalPatients(); // Total de Pacientes
      final activePatients = await api.getPatientsActivos();// Total de pacientes activos
      //CITAS(metodo llamado de "appointment_service.dart")
      final totalAppointments = await apiCitas.getTotalCitas(); // Total de Citas
      //DOCTORES(metodo llamado de "api_doctores.dart")
      final totalDoctores = await apiDoctores.getTotalDoctores(); // Total de Doctores
    
      
      //final doctorCount = await _dbService.getDoctorCount();

      if (mounted) {
        setState(() {
          _totalPatients = totalPatients;
          _activePatients = activePatients;
          _appointments = totalAppointments;
          _doctorCount = totalDoctores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
  }
 
 // Widget para las tarjetas del dashboard
  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido
            children: [
              Icon(
                icon,
                size: 36, // Reducido de 48 a 36
                color: color,
              ),
              const SizedBox(height: 8), // Reducido de 12 a 8
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  // Cambiado de headlineMedium a headlineSmall
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2), // Reducido de 4 a 2
              Flexible(
                // Agregado Flexible para evitar overflow
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall, // Cambiado de bodyMedium a bodySmall
                  textAlign: TextAlign.center,
                  overflow: TextOverflow
                      .ellipsis, // Agregar ellipsis para texto largo
                  maxLines: 2, // Máximo 2 líneas
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget para los botones de acción
  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

//---------------------------------
// INTERFAZ DEL MENU PRINCIPAL
//---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencitas - Sistema de Citas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: const [LogoutButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Dashboard Statistics
              Text(
                'Resumen del Sistema',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Detectar si estamos en web y ajustar el layout
                    bool isWeb = constraints.maxWidth > 600;
                    int crossAxisCount = isWeb
                        ? 4
                        : 2; // 4 columnas en web, 2 en móvil
                    double childAspectRatio = isWeb
                        ? 1.3
                        : 1.0; // Más ancho en web

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: isWeb ? 20 : 12,
                      mainAxisSpacing: isWeb ? 20 : 12,
                      children: [

                        //muestra el total de pacientes registrados en el sistema
                        _buildDashboardCard(
                          title: 'Total Pacientes',
                          value: _totalPatients.toString(), //llama a la variable _totalPatients trae de la base muestra en texto
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PatientListScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDashboardCard(
                          title: 'Pacientes Activos',
                          value: _activePatients.toString(),
                          icon: Icons.person,
                          color: Colors.green,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PatientListScreen(
                                  showOnlyActive: true,
                                ),
                              ),
                            );
                          },
                        ),

                        _buildDashboardCard(
                          title: 'Citas Hoy',
                          value: _appointments.toString(),
                          icon: Icons.today,
                          color: Colors.orange,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>const AppointmentListScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDashboardCard(
                          title: 'Doctores',
                          value: _doctorCount.toString(),
                          icon: Icons.medical_services,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DoctorListScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20), // Reducido de 32 a 20

              // TITULO : ACCIONES PRINCIPALES DEL SISTEMA
              Text(
                'Acciones Principales',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              //Trageta de registrar paciente
              const SizedBox(height: 16),
              _buildActionButton(
                title: 'Registrar Paciente',
                subtitle: 'Agregar un nuevo paciente al sistema',
                icon: Icons.person_add,
                color: Colors.blue,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RegisterPatientPage(),
                    ),
                  );
                  _loadDashboardData(); // Refresh data
                },
              ),

              //Tarjeta de ver pacientes

              const SizedBox(height: 12),
              _buildActionButton(
              title: 'Ver Pacientes',
              subtitle: 'Consultar la lista de pacientes registrados',
              icon: Icons.people,
              color: Colors.teal,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PatientListScreen(), //pantalla de lista de pacientes (patient_list_screen.dart)
                  ),
                );
              },
            ),
             
             // Tarjeta de agendar cita
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Agendar Cita',
                subtitle: 'Programar una nueva cita médica',
                icon: Icons.calendar_today,
                color: Colors.green,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentSchedulingScreen(),
                    ),
                  );
                  _loadDashboardData(); // Refresh data
                },
              ),

              // Tarjeta de ver citas agendadas
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Ver Citas',
                subtitle: 'Consultar todas las citas programadas',
                icon: Icons.list_alt,
                color: Colors.orange,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentListScreen(),
                    ),
                  );
                },
              ),

              // Tarjeta ver lista de doctores
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'Lista de Doctores',
                subtitle: 'Ver información de todos los doctores',
                icon: Icons.medical_services,
                color: Colors.purple,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DoctorListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Information Card
              Card(
                color: Colors.amber.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Información Importante',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Los pacientes deben completar las citas en orden (1ra, 2da, 3ra etapa)',
                      ),
                      const Text(
                        '• Pacientes de provincia requieren código de referencia',
                      ),
                      const Text(
                        '• Después de 2 faltas, el paciente debe reiniciar el proceso',
                      ),
                      const Text(
                        '• Las citas se marcan automáticamente como "no presentado" después del horario',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
