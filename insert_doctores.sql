-- ====================================================================
-- Script para insertar profesionales en el sistema CERI CITAS
-- Base de datos: citas_medicas
-- Tabla: doctors
-- Fecha: 27 de enero de 2026
-- ====================================================================

-- Campos utilizados:
-- - name: Nombre del profesional
-- - lastName: Apellido del profesional  
-- - specialty: Área de especialización
-- - license: Cédula de identidad (10 dígitos)
-- - email: Correo electrónico
-- - isActive: Estado activo (1) o inactivo (0)
-- - createdAt: Fecha de creación del registro

USE citas_medicas;

-- Desactivar modo seguro y foreign keys temporalmente
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- Eliminar TODOS los doctores
DELETE FROM doctors;

-- Resetear el auto_increment a 1
ALTER TABLE doctors AUTO_INCREMENT = 1;

-- Reactivar foreign keys y modo seguro
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

INSERT INTO doctors (name, lastName, specialty, license, email, phone, appointmentDuration, isActive, createdAt) VALUES
('Jacqueline del Rocío', 'Freire Iauregui', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '1713461737', 'jacque.freire76@gmail.com', NULL, 30, 1, NOW()),
('Juan Carlos', 'Gualsaqui Gordon', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '1003014055', 'djxnt@hotmail.com', NULL, 30, 1, NOW()),
('Edison Ramón', 'Meza Muñoz', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '0200715227', 'raza.mabe@gmail.com', NULL, 30, 1, NOW()),
('Ángel Rodrigo', 'Palacios Brito', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '0501920115', 'ropab2107@gmail.com', NULL, 30, 1, NOW()),
('Cecilia Elizabeth', 'Ponce Unfcru', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '1710505411', 'ceciponceleon22@gmail.com', NULL, 30, 1, NOW()),
('Jacqueline Liliana', 'Santos Vivanco', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '1714620471', 'yalisanvi_24@hotmail.com', NULL, 30, 1, NOW()),
('Shumar Alberto', 'Tipán Pazmiño', 'TERAPIA FÍSICA ADULTOS (ELECTROTERAPIA Y GIMNASIO TERAPÉUTICO)', '1711801215', 'shumartipan@gmail.com', NULL, 30, 1, NOW()),
('Franklin Roberto', 'Loja Guadalupe', 'TERAPIA FÍSICA PEDIÁTRICA', '1719606335', 'robertolojag@gmail.com', NULL, 30, 1, NOW()),
('Fernando Xavier', 'Molina Estrella', 'TERAPIA FÍSICA PEDIÁTRICA', '1711152007', 'fermolinaft@gmail.com', NULL, 30, 1, NOW()),
('Néstor Javier', 'Gallo Arauz', 'HIPOTERAPIA', '1724856305', 'gallonestor8@gmail.com', NULL, 30, 1, NOW()),
('Marjorie Sofía', 'Lozada Yandún', 'HIPOTERAPIA', '1723485346', 'sofy-march@hotmail.com', NULL, 30, 1, NOW()),
('Mónica Romelia', 'Mier Araujo', 'TERAPIA LENGUAJE', '1707511893', 'myermonicar@gmail.com', NULL, 30, 1, NOW()),
('Gabriela Fernanda', 'Racines Mera', 'TERAPIA LENGUAJE', '1705673361', 'gafer66@hotmail.com', NULL, 30, 1, NOW()),
('Jenny Patricia', 'Mejía Delgado', 'TERAPIA OCUPACIONAL PEDIÁTRICA', '1705056067', 'jpatriciamejia@gmail.com', NULL, 30, 1, NOW()),
('Jorge Omar', 'Patiño Caiza', 'TERAPIA OCUPACIONAL ADULTOS', '1712867652', 'jorgeomar67@hotmail.es', NULL, 30, 1, NOW()),
('Cecilia Safiro', 'Salas Caisaluisa', 'TERAPIA OCUPACIONAL ADULTOS', '1710507227', 'safirosalas@hotmail.com', NULL, 30, 1, NOW());

-- ====================================================================
-- Verificar la inserción
-- ====================================================================
SELECT COUNT(*) as 'Total Profesionales' FROM doctors;

-- Ver TODOS los profesionales
SELECT id, name, lastName, specialty, license, email, isActive 
FROM doctors 
ORDER BY id;
