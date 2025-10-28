# Agencitas - Sistema de Gestión de Citas Médicas

Sistema integral de gestión de citas médicas desarrollado en Flutter, adaptado del sistema de liga de baloncesto en Java. Esta aplicación permite el registro de pacientes, programación de citas, y gestión completa del flujo de atención médica.

## 🎯 Características Principales

### Gestión de Pacientes
- **Registro de pacientes** con validación completa de datos
- **Soporte para códigos de referencia** (obligatorio para pacientes de provincia)
- **Sistema de etapas** (Primera, Segunda, Tercera cita)
- **Control de faltas**: Después de 2 faltas, el paciente debe reiniciar el proceso

### Gestión de Citas
- **Programación de citas** con selección de doctor y horario
- **Validación automática** de disponibilidad de horarios
- **Estados de cita**: Programada, Completada, Cancelada, No se presentó
- **Cancelación automática** cuando el paciente excede las faltas permitidas
- **Progresión automática** de etapas al completar citas

### Gestión de Doctores
- **Lista de doctores** con especialidades y horarios
- **Horarios configurables** por día de la semana
- **Duración personalizable** de citas (por defecto 30 minutos)

### Validaciones del Sistema
- **Pacientes de provincia**: Requieren código de referencia válido
- **Progresión secuencial**: Las citas deben completarse en orden (1ra → 2da → 3ra)
- **Control de faltas**: Máximo 2 faltas antes de reiniciar el proceso
- **Horarios de atención**: Validación de disponibilidad de doctores

## 🏗️ Arquitectura del Sistema

### Modelos de Datos
- **Patient**: Información del paciente, estado, etapa actual
- **Doctor**: Información del doctor, especialidad, horarios
- **Appointment**: Citas médicas con estado y validaciones
- **ReferralCode**: Códigos de referencia para validaciones especiales

### Servicios
- **DatabaseService**: Gestión de base de datos SQLite local
- **AppointmentService**: Lógica de negocio para citas y validaciones

### Pantallas
- **HomeScreen**: Dashboard principal con resumen del sistema
- **PatientRegistrationScreen**: Formulario de registro de pacientes
- **DoctorListScreen**: Lista de doctores disponibles
- **AppointmentSchedulingScreen**: Programación de citas
- **AppointmentListScreen**: Lista y gestión de citas

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (3.9.2 o superior)
- Dart SDK
- Android Studio o VS Code

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # Gestión de estado
  sqflite: ^2.3.3+1         # Base de datos local
  path: ^1.9.0              # Manejo de rutas
  intl: ^0.19.0             # Internacionalización
  email_validator: ^2.1.17  # Validación de emails
```

### Instalación
1. Clona el repositorio:
   ```bash
   git clone <repository-url>
   cd agencitas
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 💾 Base de Datos

El sistema utiliza SQLite para almacenamiento local con las siguientes tablas:

### Tabla `patients`
- Información completa del paciente
- Control de faltas y etapa actual
- Códigos de referencia y estado de provincia

### Tabla `doctors`
- Información del doctor y especialidad
- Duración de citas configurable

### Tabla `doctor_schedules`
- Horarios de atención por día de semana
- Horarios de inicio y fin por doctor

### Tabla `appointments`
- Citas programadas con estados
- Relación con pacientes y doctores
- Notas y códigos de referencia

### Tabla `referral_codes`
- Códigos de referencia válidos
- Diferenciación entre códigos locales y de provincia

## 🔧 Funcionalidades del Sistema

### Registro de Pacientes
- Formulario completo con validaciones
- Soporte para pacientes de provincia
- Validación de códigos de referencia
- Verificación de duplicados por identificación

### Programación de Citas
- Selección de paciente y doctor
- Calendario con fechas disponibles
- Horarios disponibles en tiempo real
- Validación de prerrequisitos de etapa

### Gestión de Faltas
- Marcado automático de "no se presentó"
- Contador de faltas por paciente
- Cancelación automática tras 2 faltas
- Reinicio del proceso desde primera etapa

### Progresión de Etapas
- Primera Cita → Segunda Cita → Tercera Cita
- Avance automático al completar citas
- Validación de secuencia obligatoria

## 🎨 Interfaz de Usuario

### Tema y Diseño
- Material Design 3
- Colores médicos (verde principal)
- Tarjetas y componentes redondeados
- Iconografía consistente

### Navegación
- Dashboard principal con resumen
- Navegación por pantallas específicas
- Botones de acción claramente identificados
- Feedback visual en todas las acciones

### Responsive Design
- Adaptado para diferentes tamaños de pantalla
- Formularios scrollables
- Grids responsivos para estadísticas

## 🔐 Validaciones y Reglas de Negocio

### Pacientes
- Identificación única obligatoria
- Email válido requerido
- Teléfono mínimo 10 dígitos
- Pacientes de provincia requieren código válido

### Citas
- No se pueden programar citas en el pasado
- Horarios deben estar dentro del horario del doctor
- Solo un paciente por horario por doctor
- Progresión secuencial de etapas obligatoria

### Códigos de Referencia
- Validación de existencia y vigencia
- Diferenciación entre códigos locales y provinciales
- Opcionales para pacientes locales, obligatorios para provincia

## 📱 Funcionalidades Móviles

### Almacenamiento Local
- Base de datos SQLite embebida
- Datos persistentes sin conexión a internet
- Backup automático de información

### Notificaciones (Futuro)
- Recordatorios de citas
- Alertas de citas perdidas
- Notificaciones de cambios de estado

## 🧪 Testing

### Tests Incluidos
- Test básico de widget principal
- Verificación de carga de pantalla principal
- Validación de elementos UI principales

### Ejecutar Tests
```bash
flutter test
```

## 🚀 Compilación

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📋 Datos de Ejemplo

El sistema incluye datos de ejemplo:

### Doctores Precargados
1. **Dr. María González** - Medicina General (Lun-Vie 8:00-17:00)
2. **Dr. Carlos Rodríguez** - Cardiología (Lun-Mié-Vie 9:00-16:00)
3. **Dr. Ana Martínez** - Pediatría (Mar-Jue 8:00-15:00)

### Códigos de Referencia
- **PROV001**: Para pacientes de provincia
- **REF001**: Código general de referencia

## 🔄 Flujo del Sistema

1. **Registro de Paciente**: Se registra un nuevo paciente con validaciones
2. **Primera Cita**: Se programa en etapa 1, se requiere presentarse
3. **Progresión**: Al completar la cita, avanza automáticamente a etapa 2
4. **Control de Faltas**: Si falta 2 veces, debe reiniciar desde etapa 1
5. **Completado**: Al completar las 3 etapas, el proceso termina

## 🛠️ Personalización

### Agregar Nuevos Doctores
Modifica `DatabaseService._insertSampleData()` para agregar doctores adicionales.

### Configurar Horarios
Los horarios se pueden personalizar en la tabla `doctor_schedules`.

### Códigos de Referencia
Agrega nuevos códigos en la tabla `referral_codes` con fechas de expiración opcionales.

## 📞 Soporte y Contribuciones

Este proyecto fue adaptado del sistema de liga de baloncesto en Java, transformándolo en un sistema completo de gestión de citas médicas con todas las validaciones y controles necesarios para un entorno médico profesional.

Para reportar problemas o sugerir mejoras, por favor crea un issue en el repositorio.
