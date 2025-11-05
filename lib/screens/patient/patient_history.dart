import 'package:flutter/material.dart';
import '../../models/appointment.dart';

class PatientHistory extends StatefulWidget {
  final String patientId;

  const PatientHistory({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientHistory> createState() => _PatientHistoryState();
}

class _PatientHistoryState extends State<PatientHistory> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  List<MedicalRecord> _medicalHistory = [];
  List<TherapyProgress> _therapyProgress = [];
  List<TestResult> _testResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de historial médico
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _medicalHistory = _generateMedicalHistory();
        _therapyProgress = _generateTherapyProgress();
        _testResults = _generateTestResults();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar historial: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<MedicalRecord> _generateMedicalHistory() {
    final now = DateTime.now();
    return [
      MedicalRecord(
        id: '1',
        date: now.subtract(const Duration(days: 7)),
        doctorName: 'Dr. María García',
        specialty: 'Cardiología',
        diagnosis: 'Hipertensión arterial controlada',
        treatment: 'Continuación de medicamento antihipertensivo',
        notes: 'Paciente presenta mejoría. Presión arterial dentro de rangos normales.',
        prescriptions: ['Losartán 50mg - 1 vez al día', 'Control de sal en dieta'],
        nextAppointment: now.add(const Duration(days: 30)),
      ),
      MedicalRecord(
        id: '2',
        date: now.subtract(const Duration(days: 21)),
        doctorName: 'Dr. Carlos Rodríguez',
        specialty: 'Neurología',
        diagnosis: 'Cefalea tensional',
        treatment: 'Terapia de relajación y medicación',
        notes: 'Paciente reporta disminución significativa de episodios de dolor de cabeza.',
        prescriptions: ['Ibuprofeno 400mg - según necesidad', 'Ejercicios de relajación'],
        nextAppointment: now.add(const Duration(days: 14)),
      ),
      MedicalRecord(
        id: '3',
        date: now.subtract(const Duration(days: 45)),
        doctorName: 'Dra. Ana Martínez',
        specialty: 'Fisioterapia',
        diagnosis: 'Lesión en rodilla derecha',
        treatment: 'Sesiones de fisioterapia y ejercicios',
        notes: 'Recuperación progresiva. Movilidad mejorada en 70%.',
        prescriptions: ['Ejercicios de fortalecimiento', 'Aplicación de hielo 3 veces al día'],
        nextAppointment: now.add(const Duration(days: 7)),
      ),
    ];
  }

  List<TherapyProgress> _generateTherapyProgress() {
    return [
      TherapyProgress(
        id: '1',
        therapyName: 'Rehabilitación Cardiovascular',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        totalSessions: 12,
        completedSessions: 8,
        currentPhase: 'Fase 2: Ejercicios moderados',
        status: TherapyStatus.inProgress,
        goals: [
          TherapyGoal('Reducir presión arterial', true, 90),
          TherapyGoal('Mejorar resistencia cardiovascular', false, 60),
          TherapyGoal('Pérdida de peso (5kg)', false, 40),
        ],
        progress: [
          ProgressEntry(DateTime.now().subtract(const Duration(days: 7)), 'Excelente progreso en ejercicios'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 14)), 'Presión arterial estable'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 21)), 'Inicio de rutina de ejercicios'),
        ],
      ),
      TherapyProgress(
        id: '2',
        therapyName: 'Fisioterapia de Rodilla',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        totalSessions: 15,
        completedSessions: 12,
        currentPhase: 'Fase 3: Fortalecimiento avanzado',
        status: TherapyStatus.inProgress,
        goals: [
          TherapyGoal('Recuperar movilidad completa', false, 85),
          TherapyGoal('Eliminar dolor', true, 95),
          TherapyGoal('Fortalecer músculos', false, 70),
        ],
        progress: [
          ProgressEntry(DateTime.now().subtract(const Duration(days: 3)), 'Flexión de rodilla mejorada'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 10)), 'Dolor significativamente reducido'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 17)), 'Inicio de ejercicios de fortalecimiento'),
        ],
      ),
      TherapyProgress(
        id: '3',
        therapyName: 'Terapia para Cefaleas',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        totalSessions: 8,
        completedSessions: 8,
        currentPhase: 'Terapia completada',
        status: TherapyStatus.completed,
        goals: [
          TherapyGoal('Reducir frecuencia de cefaleas', true, 100),
          TherapyGoal('Aprender técnicas de manejo del estrés', true, 100),
          TherapyGoal('Mejorar calidad del sueño', true, 90),
        ],
        progress: [
          ProgressEntry(DateTime.now().subtract(const Duration(days: 1)), 'Terapia completada exitosamente'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 7)), 'Solo 1 episodio en la última semana'),
          ProgressEntry(DateTime.now().subtract(const Duration(days: 14)), 'Técnicas de relajación dominadas'),
        ],
      ),
    ];
  }

  List<TestResult> _generateTestResults() {
    final now = DateTime.now();
    return [
      TestResult(
        id: '1',
        testName: 'Análisis de Sangre Completo',
        date: now.subtract(const Duration(days: 5)),
        doctorName: 'Dr. María García',
        status: TestStatus.completed,
        results: {
          'Hemoglobina': TestValue('14.2 g/dL', 'Normal', TestValueStatus.normal),
          'Glucosa': TestValue('95 mg/dL', 'Normal', TestValueStatus.normal),
          'Colesterol Total': TestValue('180 mg/dL', 'Óptimo', TestValueStatus.good),
          'Triglicéridos': TestValue('120 mg/dL', 'Normal', TestValueStatus.normal),
          'Creatinina': TestValue('1.0 mg/dL', 'Normal', TestValueStatus.normal),
        },
        interpretation: 'Resultados dentro de rangos normales. Continuar con tratamiento actual.',
      ),
      TestResult(
        id: '2',
        testName: 'Electrocardiograma',
        date: now.subtract(const Duration(days: 14)),
        doctorName: 'Dr. María García',
        status: TestStatus.completed,
        results: {
          'Ritmo': TestValue('Sinusal', 'Normal', TestValueStatus.normal),
          'Frecuencia': TestValue('72 bpm', 'Normal', TestValueStatus.normal),
          'Intervalo PR': TestValue('0.16 seg', 'Normal', TestValueStatus.normal),
          'QRS': TestValue('0.08 seg', 'Normal', TestValueStatus.normal),
        },
        interpretation: 'ECG normal. No se observan alteraciones del ritmo cardíaco.',
      ),
      TestResult(
        id: '3',
        testName: 'Resonancia Magnética de Rodilla',
        date: now.subtract(const Duration(days: 40)),
        doctorName: 'Dra. Ana Martínez',
        status: TestStatus.completed,
        results: {
          'Menisco medial': TestValue('Desgarro menor', 'Anormal', TestValueStatus.abnormal),
          'Ligamentos': TestValue('Intactos', 'Normal', TestValueStatus.normal),
          'Cartílago': TestValue('Desgaste leve', 'Anormal', TestValueStatus.warning),
          'Derrame': TestValue('Mínimo', 'Leve', TestValueStatus.warning),
        },
        interpretation: 'Desgarro menor en menisco medial. Responde bien a fisioterapia conservadora.',
      ),
      TestResult(
        id: '4',
        testName: 'Análisis de Orina',
        date: now.subtract(const Duration(days: 10)),
        doctorName: 'Dr. María García',
        status: TestStatus.pending,
        results: {},
        interpretation: 'Resultados pendientes. Se notificará cuando estén disponibles.',
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
          // Header
          _buildHeader(),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.green[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.green[700],
            tabs: const [
              Tab(text: 'Historial Médico'),
              Tab(text: 'Progreso de Terapias'),
              Tab(text: 'Resultados de Exámenes'),
            ],
          ),
          
          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicalHistoryTab(),
                _buildTherapyProgressTab(),
                _buildTestResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi Historial Médico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registro completo de tu atención médica',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Resumen de estado
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Terapias Activas',
                  _therapyProgress.where((t) => t.status == TherapyStatus.inProgress).length.toString(),
                  Icons.healing,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Terapias Completadas',
                  _therapyProgress.where((t) => t.status == TherapyStatus.completed).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Exámenes Pendientes',
                  _testResults.where((t) => t.status == TestStatus.pending).length.toString(),
                  Icons.pending,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medicalHistory.length,
        itemBuilder: (context, index) {
          return _buildMedicalRecordCard(_medicalHistory[index]);
        },
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y doctor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      record.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  '${record.date.day}/${record.date.month}/${record.date.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Diagnóstico
            _buildInfoSection('Diagnóstico', record.diagnosis, Icons.medical_services, Colors.blue),
            
            // Tratamiento
            _buildInfoSection('Tratamiento', record.treatment, Icons.healing, Colors.green),
            
            // Notas
            if (record.notes.isNotEmpty)
              _buildInfoSection('Notas', record.notes, Icons.note, Colors.orange),
            
            // Prescripciones
            if (record.prescriptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.medication, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Prescripciones:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...record.prescriptions.map((prescription) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Text(
                  '• $prescription',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              )),
            ],
            
            // Próxima cita
            if (record.nextAppointment != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Próxima cita: ${record.nextAppointment!.day}/${record.nextAppointment!.month}/${record.nextAppointment!.year}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                '$title:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyProgressTab() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _therapyProgress.length,
        itemBuilder: (context, index) {
          return _buildTherapyProgressCard(_therapyProgress[index]);
        },
      ),
    );
  }

  Widget _buildTherapyProgressCard(TherapyProgress therapy) {
    final progressPercentage = (therapy.completedSessions / therapy.totalSessions);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    therapy.therapyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTherapyStatusColor(therapy.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTherapyStatusText(therapy.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getTherapyStatusColor(therapy.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progreso de sesiones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sesiones: ${therapy.completedSessions}/${therapy.totalSessions}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTherapyStatusColor(therapy.status),
              ),
            ),
            const SizedBox(height: 16),
            
            // Fase actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.track_changes, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      therapy.currentPhase,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Objetivos
            const Text(
              'Objetivos de la Terapia:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...therapy.goals.map((goal) => _buildGoalItem(goal)),
            
            const SizedBox(height: 16),
            
            // Progreso reciente
            const Text(
              'Progreso Reciente:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...therapy.progress.take(3).map((progress) => _buildProgressItem(progress)),
            
            // Botón ver más
            if (therapy.progress.length > 3)
              TextButton(
                onPressed: () => _showFullProgress(therapy),
                child: const Text('Ver historial completo'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(TherapyGoal goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            goal.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: goal.isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              goal.description,
              style: TextStyle(
                color: goal.isCompleted ? Colors.green[700] : Colors.grey[700],
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '${goal.progressPercentage}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: goal.isCompleted ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(ProgressEntry progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${progress.date.day}/${progress.date.month}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              progress.note,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultsTab() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testResults.length,
        itemBuilder: (context, index) {
          return _buildTestResultCard(_testResults[index]);
        },
      ),
    );
  }

  Widget _buildTestResultCard(TestResult testResult) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testResult.testName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        testResult.doctorName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTestStatusColor(testResult.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTestStatusText(testResult.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getTestStatusColor(testResult.status),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${testResult.date.day}/${testResult.date.month}/${testResult.date.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (testResult.results.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Resultados:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...testResult.results.entries.map((entry) => 
                _buildTestValueItem(entry.key, entry.value)
              ),
            ],
            
            if (testResult.interpretation.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600], size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Interpretación:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testResult.interpretation,
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestValueItem(String testName, TestValue value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              testName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getTestValueStatusColor(value.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.interpretation,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTestValueStatusColor(value.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTherapyStatusColor(TherapyStatus status) {
    switch (status) {
      case TherapyStatus.notStarted:
        return Colors.red;
      case TherapyStatus.inProgress:
        return Colors.orange;
      case TherapyStatus.completed:
        return Colors.green;
    }
  }

  String _getTherapyStatusText(TherapyStatus status) {
    switch (status) {
      case TherapyStatus.notStarted:
        return 'No iniciada';
      case TherapyStatus.inProgress:
        return 'En progreso';
      case TherapyStatus.completed:
        return 'Completada';
    }
  }

  Color _getTestStatusColor(TestStatus status) {
    switch (status) {
      case TestStatus.pending:
        return Colors.orange;
      case TestStatus.completed:
        return Colors.green;
      case TestStatus.cancelled:
        return Colors.red;
    }
  }

  String _getTestStatusText(TestStatus status) {
    switch (status) {
      case TestStatus.pending:
        return 'Pendiente';
      case TestStatus.completed:
        return 'Completado';
      case TestStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color _getTestValueStatusColor(TestValueStatus status) {
    switch (status) {
      case TestValueStatus.normal:
        return Colors.green;
      case TestValueStatus.warning:
        return Colors.orange;
      case TestValueStatus.abnormal:
        return Colors.red;
      case TestValueStatus.good:
        return Colors.blue;
    }
  }

  void _showFullProgress(TherapyProgress therapy) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial: ${therapy.therapyName}',
                    style: const TextStyle(
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
                child: ListView.builder(
                  itemCount: therapy.progress.length,
                  itemBuilder: (context, index) {
                    return _buildProgressItem(therapy.progress[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelos de datos para el historial
class MedicalRecord {
  final String id;
  final DateTime date;
  final String doctorName;
  final String specialty;
  final String diagnosis;
  final String treatment;
  final String notes;
  final List<String> prescriptions;
  final DateTime? nextAppointment;

  MedicalRecord({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.specialty,
    required this.diagnosis,
    required this.treatment,
    required this.notes,
    required this.prescriptions,
    this.nextAppointment,
  });
}

class TherapyProgress {
  final String id;
  final String therapyName;
  final DateTime startDate;
  final int totalSessions;
  final int completedSessions;
  final String currentPhase;
  final TherapyStatus status;
  final List<TherapyGoal> goals;
  final List<ProgressEntry> progress;

  TherapyProgress({
    required this.id,
    required this.therapyName,
    required this.startDate,
    required this.totalSessions,
    required this.completedSessions,
    required this.currentPhase,
    required this.status,
    required this.goals,
    required this.progress,
  });
}

class TherapyGoal {
  final String description;
  final bool isCompleted;
  final int progressPercentage;

  TherapyGoal(this.description, this.isCompleted, this.progressPercentage);
}

class ProgressEntry {
  final DateTime date;
  final String note;

  ProgressEntry(this.date, this.note);
}

enum TestStatus {
  pending,
  completed,
  cancelled,
}

class TestResult {
  final String id;
  final String testName;
  final DateTime date;
  final String doctorName;
  final TestStatus status;
  final Map<String, TestValue> results;
  final String interpretation;

  TestResult({
    required this.id,
    required this.testName,
    required this.date,
    required this.doctorName,
    required this.status,
    required this.results,
    required this.interpretation,
  });
}

class TestValue {
  final String value;
  final String interpretation;
  final TestValueStatus status;

  TestValue(this.value, this.interpretation, this.status);
}

enum TestValueStatus {
  normal,
  warning,
  abnormal,
  good,
}