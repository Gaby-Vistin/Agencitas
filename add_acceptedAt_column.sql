-- Script para agregar las columnas acceptedAt e insuranceType a la tabla patients
-- Ejecutar en MySQL Workbench o línea de comandos MySQL

USE citas_medicas;

-- Agregar columna acceptedAt
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS acceptedAt DATETIME AFTER updatedAt;

-- Agregar columna insuranceType (0=ninguno, 1=público, 2=privado)
ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS insuranceType INT DEFAULT 0 AFTER acceptedAt;

-- Verificar la estructura de la tabla
DESCRIBE patients;
