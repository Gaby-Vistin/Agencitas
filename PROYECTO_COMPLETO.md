# Sistema Agencitas - Gestión de Citas Médicas

## Resumen del Proyecto

Agencitas es una aplicación Flutter completa para la gestión de citas médicas que ha sido adaptada del código Java de gestión de liga de baloncesto proporcionado. El sistema incluye todas las funcionalidades requeridas:

## Funcionalidades Implementadas

### ✅ Gestión de Pacientes
- **Registro de pacientes** con validación completa de datos
- **Validación de códigos de referencia** para pacientes de provincia
- **Sistema de etapas** (Primera, Segunda, Tercera cita)
- **Control automático de faltas** - cancela automáticamente después de 2 faltas
- **Reinicio automático** al primer nivel cuando el paciente excede el límite

### ✅ Gestión de Doctores
- **Lista de doctores** con especialidades y horarios
- **Horarios personalizables** por día de la semana
- **Duración de citas configurable** por doctor
- **Información de contacto** completa

### ✅ Sistema de Citas
- **Programación inteligente** con validación de disponibilidad
- **Selección de horarios** basada en la agenda del doctor
- **Validación de códigos de referencia** para pacientes especiales
- **Estados de cita**: Programada, Completada, Cancelada, No se presentó
- **Notas opcionales** por cita

### ✅ Validaciones de Negocio
- **Progresión secuencial** de etapas (no se puede saltar etapas)
- **Límite de faltas**: máximo 2 faltas antes de reinicio
- **Códigos de provincia**: validación especial para pacientes de provincia
- **Horarios disponibles**: solo se pueden agendar citas en horarios libres
- **Fechas futuras**: no se pueden agendar citas en el pasado

### ✅ Características Especiales
- **Procesamiento automático** de citas vencidas (no-show)
- **Cancelación automática** de citas futuras cuando se excede el límite
- **Interfaz en español** con formato de fechas localizado
- **Diseño Material 3** con tema médico (verde)
- **Base de datos SQLite** para persistencia local

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/                      # Modelos de datos
│   ├── patient.dart            # Modelo de paciente con etapas
│   ├── doctor.dart             # Modelo de doctor y horarios
│   └── appointment.dart        # Modelo de citas y códigos de referencia
├── services/                    # Servicios de negocio
│   ├── database_service.dart   # Servicio de base de datos SQLite
│   └── appointment_service.dart # Lógica de negocio de citas
└── screens/                     # Pantallas de la aplicación
    ├── home_screen.dart        # Pantalla principal con menú
    ├── patient_registration_screen.dart  # Registro de pacientes
    ├── doctor_list_screen.dart # Lista de doctores
    ├── appointment_scheduling_screen.dart # Programación de citas
    └── appointment_list_screen.dart # Lista de citas
```

## Adaptación del Código Java Original

El sistema ha sido completamente adaptado del código Java de gestión de liga de baloncesto:

### Equivalencias de Conceptos:
- **Equipos** → **Pacientes**
- **Partidos jugados/ganados/perdidos** → **Etapas de citas completadas**
- **No presentados** → **Faltas a citas**
- **Puntos y clasificación** → **Progresión por etapas**
- **Liga y gestión de partidos** → **Sistema de citas médicas**

### Lógica de Negocio Adaptada:
- **Límite de no presentados (2)** → **Límite de faltas (2 citas)**
- **Reinicio de puntos** → **Reinicio a primera etapa**
- **Validación de equipos** → **Validación de pacientes y códigos**
- **Interfaz Swing** → **Interfaz Flutter nativa**

## Datos de Ejemplo Incluidos

El sistema incluye datos de ejemplo listos para usar:

### Doctores:
1. **Dra. María González** - Medicina General (Lun-Vie 8:00-17:00)
2. **Dr. Carlos Rodríguez** - Cardiología (Lun/Mié/Vie 9:00-16:00)
3. **Dra. Ana Martínez** - Pediatría (Mar/Jue 8:00-15:00)

### Códigos de Referencia:
- **PROV001**: Código para pacientes de provincia
- **REF001**: Código de referencia general

## Tecnologías Utilizadas

- **Flutter 3.9.2+** - Framework de desarrollo
- **Dart** - Lenguaje de programación
- **SQLite** - Base de datos local
- **Provider** - Gestión de estado
- **Material 3** - Sistema de diseño
- **Intl** - Internacionalización y formato de fechas

## Instrucciones de Uso

1. **Instalar dependencias**: `flutter pub get`
2. **Ejecutar la aplicación**: `flutter run`
3. **Compilar para producción**: `flutter build apk --release`

## Flujo de Trabajo Típico

1. **Registrar paciente** con datos completos y código de referencia (si aplica)
2. **Seleccionar doctor** disponible según especialidad
3. **Programar cita** en horario disponible para la etapa correspondiente
4. **Gestionar citas** - marcar como completadas o registrar faltas
5. **Sistema automático** maneja la progresión de etapas y límites de faltas

## Características de Seguridad

- ✅ **Validación de entrada** en todos los formularios
- ✅ **Verificación de códigos** de referencia
- ✅ **Prevención de citas duplicadas** en el mismo horario
- ✅ **Control de acceso** por etapas de paciente
- ✅ **Logs automáticos** de cambios de estado

¡El sistema está completo y listo para usar! 🏥✨