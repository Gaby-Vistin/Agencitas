-- ====================================================================
-- Script para agregar el campo IS_PRIORITY a la tabla patients
-- Base de datos: citas_medicas
-- Tabla: patients
-- Fecha: 28 de enero de 2026
-- ====================================================================

USE citas_medicas;

-- Agregar columna isPriority (0=No prioritario, 1=Prioritario)
-- Por defecto: 0 (No prioritario)
-- Los niños (menores de 18 años) deben marcarse como prioritarios
ALTER TABLE patients 
ADD COLUMN isPriority TINYINT DEFAULT 0 
COMMENT '0=No prioritario, 1=Prioritario (niños < 18 años)';

-- Actualizar pacientes existentes: marcar como prioritarios los menores de 18 años
UPDATE patients 
SET isPriority = 1 
WHERE TIMESTAMPDIFF(YEAR, birthDate, CURDATE()) < 18;

-- Verificar la estructura de la tabla
DESCRIBE patients;

-- Ver algunos registros para confirmar
SELECT id, name, lastName, birthDate, 
       TIMESTAMPDIFF(YEAR, birthDate, CURDATE()) AS edad,
       isPriority
FROM patients 
LIMIT 10;

-- Contar cuántos pacientes son prioritarios
SELECT 
    COUNT(*) as total_pacientes,
    SUM(isPriority) as pacientes_prioritarios,
    COUNT(*) - SUM(isPriority) as pacientes_no_prioritarios
FROM patients;
