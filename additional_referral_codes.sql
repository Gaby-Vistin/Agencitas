-- Códigos de Referencia Adicionales para Agencitas
-- Ejecutar estos comandos en la base de datos SQLite si necesitas más códigos

-- Códigos para diferentes provincias
INSERT INTO referral_codes (code, description, isForProvince, isActive, createdAt)
VALUES 
('PROV002', 'Pacientes de Guayas', 1, 1, datetime('now', 'unixepoch', 'localtime')),
('PROV003', 'Pacientes de Azuay', 1, 1, datetime('now', 'unixepoch', 'localtime')),
('PROV004', 'Pacientes de Manabí', 1, 1, datetime('now', 'unixepoch', 'localtime')),
('PROV005', 'Pacientes de El Oro', 1, 1, datetime('now', 'unixepoch', 'localtime'));

-- Códigos de referencia especiales
INSERT INTO referral_codes (code, description, isForProvince, isActive, createdAt)
VALUES 
('VIP001', 'Pacientes VIP', 0, 1, datetime('now', 'unixepoch', 'localtime')),
('EMERG001', 'Referencias de emergencia', 0, 1, datetime('now', 'unixepoch', 'localtime')),
('CORP001', 'Pacientes corporativos', 0, 1, datetime('now', 'unixepoch', 'localtime')),
('SEGURO001', 'Pacientes con seguro privado', 0, 1, datetime('now', 'unixepoch', 'localtime'));

-- Códigos temporales con fecha de expiración (90 días)
INSERT INTO referral_codes (code, description, isForProvince, isActive, expiryDate, createdAt)
VALUES 
('TEMP001', 'Código temporal promocional', 0, 1, datetime('now', '+90 days', 'unixepoch', 'localtime'), datetime('now', 'unixepoch', 'localtime')),
('PROMO001', 'Promoción especial', 0, 1, datetime('now', '+30 days', 'unixepoch', 'localtime'), datetime('now', 'unixepoch', 'localtime'));