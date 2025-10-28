# 📊 DIAGRAMA ESTRUCTURAL DEL SISTEMA AGENCITAS

## 🏗️ ARQUITECTURA GENERAL DEL SISTEMA

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SISTEMA AGENCITAS                                  │
│                   Sistema de Gestión de Citas Médicas                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
        ┌───────▼───────┐   ┌──────▼──────┐   ┌───────▼───────┐
        │  PRESENTACIÓN  │   │   NEGOCIO   │   │     DATOS     │
        │    (UI/UX)     │   │  (SERVICES) │   │  (STORAGE)    │
        └───────────────┘   └─────────────┘   └───────────────┘
```

## 📱 CAPA DE PRESENTACIÓN (UI/UX)

### 🖥️ Pantallas Principales

```
main.dart ──► WelcomeScreen ──► LoginScreen ──► HomeScreen
                                                    │
        ┌───────────────────────────────────────────┼───────────────────────────────────────────┐
        │                                           │                                           │
        ▼                                           ▼                                           ▼
PatientRegistrationScreen                  DoctorListScreen                        AppointmentSchedulingScreen
        │                                           │                                           │
        ▼                                           ▼                                           ▼
PatientListScreen                              [Doctor Details]                      AppointmentListScreen
```

### 🧩 Componentes Reutilizables

```
lib/widgets/
└── logout_button.dart ──► LogoutButton (Usado en todas las pantallas principales)
```

### 🎨 Estructura de Pantallas

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PANTALLAS DEL SISTEMA                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🏠 WelcomeScreen                    🔐 LoginScreen                        │
│  ├── Logo MSP                        ├── Form de Login                      │
│  ├── Título del Sistema              ├── Validación de Credenciales        │
│  └── Botón "Iniciar Sesión"          └── Navegación a HomeScreen           │
│                                                                             │
│  📊 HomeScreen (Dashboard)           👤 PatientRegistrationScreen          │
│  ├── Estadísticas del Sistema        ├── Formulario de Registro            │
│  ├── Resumen de Citas               ├── Validación de Datos               │
│  ├── Botones de Navegación          ├── Selección de Provincia            │
│  └── LogoutButton                   └── Creación de Paciente              │
│                                                                             │
│  📋 PatientListScreen               👩‍⚕️ DoctorListScreen                     │
│  ├── Lista de Pacientes             ├── Lista de Doctores                 │
│  ├── Búsqueda/Filtros              ├── Información de Especialidades     │
│  ├── Detalles del Paciente         ├── Horarios de Atención              │
│  └── LogoutButton                  └── LogoutButton                       │
│                                                                             │
│  📅 AppointmentSchedulingScreen     📝 AppointmentListScreen              │
│  ├── Selección de Paciente          ├── Lista de Citas                    │
│  ├── Selección de Doctor            ├── Filtros por Estado               │
│  ├── Selección de Fecha/Hora        ├── Gestión de Citas                 │
│  ├── Validaciones de Negocio        ├── Cambio de Estados                │
│  └── LogoutButton                   └── LogoutButton                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## ⚙️ CAPA DE NEGOCIO (SERVICES)

### 🔧 Servicios Principales

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SERVICIOS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🗄️ DatabaseService                  📋 AppointmentService                 │
│  ├── Gestión de Pacientes           ├── Lógica de Validaciones             │
│  ├── Gestión de Doctores            ├── Reglas de Negocio                  │
│  ├── Gestión de Citas               ├── Validación de Códigos              │
│  ├── Códigos de Referencia          ├── Gestión de Estados                 │
│  ├── Soporte Web/Móvil              ├── Disponibilidad de Horarios         │
│  └── CRUD Operations                 └── Progresión de Etapas               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🔄 Flujo de Servicios

```
AppointmentService ──► DatabaseService ──► SQLite/Web Storage
        │                      │                   │
        │                      │                   ▼
        │                      │            ┌─────────────┐
        │                      │            │  STORAGE    │
        │                      │            │  ┌────────┐ │
        │                      │            │  │ Mobile │ │
        │                      │            │  │SQLite  │ │
        │                      │            │  └────────┘ │
        │                      │            │  ┌────────┐ │
        │                      │            │  │  Web   │ │
        │                      │            │  │Memory  │ │
        │                      │            │  └────────┘ │
        │                      │            └─────────────┘
        │                      │
        ▼                      ▼
┌──────────────┐    ┌──────────────┐
│ Validaciones │    │   CRUD Ops   │
│ ├─ Códigos   │    │ ├─ Patients  │
│ ├─ Etapas    │    │ ├─ Doctors   │
│ ├─ Horarios  │    │ ├─ Apps      │
│ └─ Estados   │    │ └─ Codes     │
└──────────────┘    └──────────────┘
```

## 💾 CAPA DE DATOS (MODELS & STORAGE)

### 📊 Modelos de Datos

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            MODELOS DE DATOS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  👤 Patient                         👩‍⚕️ Doctor                              │
│  ├── id: int?                       ├── id: int?                           │
│  ├── name: String                   ├── name: String                       │
│  ├── lastName: String               ├── lastName: String                   │
│  ├── identification: String         ├── specialty: String                  │
│  ├── email: String                  ├── license: String                    │
│  ├── phone: String                  ├── email: String                      │
│  ├── birthDate: DateTime            ├── phone: String                      │
│  ├── address: String                ├── appointmentDuration: int           │
│  ├── referralCode: String?          ├── isActive: bool                     │
│  ├── isFromProvince: bool           ├── createdAt: DateTime                │
│  ├── missedAppointments: int        ├── schedule: List<DoctorSchedule>     │
│  ├── currentStage: AppointmentStage └── updatedAt: DateTime?               │
│  ├── isActive: bool                                                        │
│  └── createdAt: DateTime            🗓️ DoctorSchedule                       │
│                                     ├── doctorId: int                      │
│  📅 Appointment                     ├── dayOfWeek: DayOfWeek               │
│  ├── id: int?                       ├── startTime: TimeOfDay               │
│  ├── patientId: int                 ├── endTime: TimeOfDay                 │
│  ├── doctorId: int                  └── isActive: bool                     │
│  ├── appointmentDate: DateTime                                             │
│  ├── appointmentTime: TimeOfDay     🎫 ReferralCode                        │
│  ├── status: AppointmentStatus      ├── id: int?                           │
│  ├── stage: AppointmentStage        ├── code: String                       │
│  ├── notes: String?                 ├── description: String                │
│  ├── referralCode: String?          ├── isForProvince: bool                │
│  ├── isFromProvince: bool           ├── isActive: bool                     │
│  ├── createdAt: DateTime            ├── expiryDate: DateTime?              │
│  ├── patient: Patient?              └── createdAt: DateTime                │
│  └── doctor: Doctor?                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🔍 Enumeraciones

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ENUMERACIONES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📊 AppointmentStatus               🎯 AppointmentStage                     │
│  ├── scheduled                      ├── first                              │
│  ├── completed                      ├── second                             │
│  ├── cancelled                      ├── third                              │
│  ├── noShow                         └── final                              │
│  └── rescheduled                                                           │
│                                     📅 DayOfWeek                           │
│  ⏰ TimeOfDay                       ├── monday                             │
│  ├── hour: int                      ├── tuesday                            │
│  └── minute: int                    ├── wednesday                          │
│                                     ├── thursday                           │
│                                     ├── friday                             │
│                                     ├── saturday                           │
│                                     └── sunday                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 FLUJO DE DATOS Y NAVEGACIÓN

### 📈 Flujo Principal de Uso

```
1. INICIO DE SESIÓN
   WelcomeScreen ──► LoginScreen ──► Validación ──► HomeScreen

2. REGISTRO DE PACIENTE
   HomeScreen ──► PatientRegistrationScreen ──► DatabaseService ──► Validación ──► Guardado

3. AGENDAR CITA
   HomeScreen ──► AppointmentSchedulingScreen ──► Selección de Paciente/Doctor
                                               ──► AppointmentService ──► Validaciones
                                               ──► DatabaseService ──► Guardado

4. GESTIÓN DE CITAS
   HomeScreen ──► AppointmentListScreen ──► AppointmentService ──► Estado Updates

5. GESTIÓN DE DOCTORES
   HomeScreen ──► DoctorListScreen ──► DatabaseService ──► Lista de Doctores
```

### 🔐 Seguridad y Autenticación

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SISTEMA DE SEGURIDAD                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🔑 Credenciales Predefinidas:                                             │
│  ├── admin / admin123                                                      │
│  ├── doctor / doctor123                                                    │
│  ├── enfermera / enfermera123                                              │
│  └── recepcionista / recepcion123                                          │
│                                                                             │
│  🔒 LogoutButton (Presente en todas las pantallas principales):            │
│  ├── Confirmación de Cierre                                                │
│  ├── Limpieza del Stack de Navegación                                      │
│  └── Retorno a WelcomeScreen                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🌐 COMPATIBILIDAD MULTIPLATAFORMA

### 📱 Soporte de Plataformas

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        COMPATIBILIDAD MULTIPLATAFORMA                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📱 MÓVIL                           🌐 WEB                                 │
│  ├── Android                        ├── Chrome                             │
│  ├── iOS                            ├── Firefox                            │
│  └── SQLite Database                ├── Edge                               │
│                                     └── In-Memory Storage                  │
│  🖥️ DESKTOP                                                                │
│  ├── Windows                        🎨 DISEÑO RESPONSIVO                   │
│  ├── macOS                          ├── Material 3                         │
│  ├── Linux                          ├── Adaptive Layouts                   │
│  └── SQLite Database                ├── Grid/Column Responsive             │
│                                     └── Mobile-First Design                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🏪 Gestión de Datos por Plataforma

```
DatabaseService
    │
    ├── Mobile/Desktop: SQLite
    │   ├── Persistent Storage
    │   ├── Full CRUD Operations
    │   └── Relational Database
    │
    └── Web: In-Memory Storage
        ├── Hardcoded Sample Data
        ├── Session-Based Storage
        └── No Persistence
```

## 🗂️ ESTRUCTURA DE ARCHIVOS

```
agencitas/
├── lib/
│   ├── main.dart                              # 🚀 Punto de entrada
│   ├── models/                                # 📊 Modelos de datos
│   │   ├── patient.dart                       # 👤 Modelo de paciente
│   │   ├── doctor.dart                        # 👩‍⚕️ Modelo de doctor
│   │   └── appointment.dart                   # 📅 Modelo de citas
│   ├── services/                              # ⚙️ Lógica de negocio
│   │   ├── database_service.dart              # 🗄️ Servicio de BD
│   │   └── appointment_service.dart           # 📋 Servicio de citas
│   ├── screens/                               # 📱 Pantallas UI
│   │   ├── welcome_screen.dart                # 🏠 Bienvenida
│   │   ├── login_screen.dart                  # 🔐 Login
│   │   ├── home_screen.dart                   # 📊 Dashboard
│   │   ├── patient_registration_screen.dart   # 👤 Registro paciente
│   │   ├── patient_list_screen.dart           # 📋 Lista pacientes
│   │   ├── doctor_list_screen.dart            # 👩‍⚕️ Lista doctores
│   │   ├── appointment_scheduling_screen.dart # 📅 Agendar cita
│   │   └── appointment_list_screen.dart       # 📝 Lista citas
│   ├── widgets/                               # 🧩 Componentes
│   │   └── logout_button.dart                 # 🔒 Botón logout
│   └── l10n/                                  # 🌍 Localización
│       ├── app_localizations.dart             # 🔤 Localizaciones
│       ├── app_localizations_es.dart          # 🇪🇸 Español
│       └── app_localizations_en.dart          # 🇺🇸 Inglés
├── assets/images/                             # 🖼️ Recursos gráficos
├── android/                                   # 🤖 Configuración Android
├── ios/                                       # 🍎 Configuración iOS
├── web/                                       # 🌐 Configuración Web
├── windows/                                   # 🪟 Configuración Windows
├── macos/                                     # 🍎 Configuración macOS
├── linux/                                     # 🐧 Configuración Linux
├── test/                                      # 🧪 Tests
│   └── widget_test.dart                       # 📋 Test de widgets
├── pubspec.yaml                               # 📦 Dependencias
└── README.md                                  # 📖 Documentación
```

## 🔧 DEPENDENCIAS PRINCIPALES

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEPENDENCIAS CLAVE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📦 CORE DEPENDENCIES:                                                      │
│  ├── flutter: sdk                           # 🎯 Framework principal       │
│  ├── sqflite: ^2.3.3+1                     # 🗄️ Base de datos SQLite      │
│  ├── path: ^1.9.0                          # 📁 Manejo de rutas           │
│  ├── shared_preferences: ^2.2.3            # 💾 Almacenamiento local      │
│  └── flutter_localizations: sdk            # 🌍 Localización              │
│                                                                             │
│  🎨 UI/UX DEPENDENCIES:                                                     │
│  ├── intl: ^0.19.0                         # 📅 Internacionalización      │
│  ├── email_validator: ^2.1.17              # ✉️ Validación de emails       │
│  └── material: built-in                    # 🎨 Material Design 3          │
│                                                                             │
│  🧪 DEV DEPENDENCIES:                                                       │
│  ├── flutter_test: sdk                     # 🔬 Testing framework         │
│  ├── flutter_launcher_icons: ^0.13.1       # 📱 Iconos de aplicación      │
│  └── flutter_lints: ^4.0.0                 # 📋 Análisis de código        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📋 RESUMEN DE FUNCIONALIDADES

```
✅ FUNCIONALIDADES IMPLEMENTADAS:
├── 🔐 Sistema de autenticación con credenciales predefinidas
├── 👤 Registro completo de pacientes con validaciones
├── 👩‍⚕️ Gestión de doctores con horarios y especialidades
├── 📅 Agendado de citas con validaciones complejas
├── 📝 Lista y gestión de citas (estados, filtros)
├── 🌍 Soporte para provincias ecuatorianas
├── 📱 Compatibilidad multiplataforma (móvil, web, desktop)
├── 🎨 Diseño responsivo con Material 3
├── 🔒 Sistema de logout con confirmación
├── 📊 Dashboard con estadísticas del sistema
├── 🔍 Búsqueda y filtrado en listas
├── ✅ Validaciones de reglas de negocio médicas
└── 🌐 Internacionalización (español/inglés)
```

Este diagrama estructural muestra la arquitectura completa del sistema Agencitas, desde la capa de presentación hasta la persistencia de datos, incluyendo todos los flujos de navegación, modelos de datos, servicios de negocio y compatibilidad multiplataforma.