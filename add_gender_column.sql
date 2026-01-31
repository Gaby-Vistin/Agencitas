-- ====================================================================
-- Script para agregar el campo GENDER a la tabla patients
-- Base de datos: citas_medicas
-- Tabla: patients
-- Fecha: 28 de enero de 2026
-- ====================================================================

USE citas_medicas;

-- Agregar columna gender (0=Hombre, 1=Mujer, 2=Otro)
-- Por defecto: 2 (Otro)
ALTER TABLE patients 
ADD COLUMN gender TINYINT DEFAULT 2 
COMMENT '0=Hombre, 1=Mujer, 2=Otro';

-- Verificar la estructura de la tabla
DESCRIBE patients;

-- Ver algunos registros para confirmar
SELECT id, name, lastName, identification, gender 
FROM patients 
LIMIT 5;
