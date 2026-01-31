USE citas_medicas;

-- Contar total de registros
SELECT COUNT(*) as 'Total Real de Doctores' FROM doctors;

-- Ver IDs específicos
SELECT 
    MIN(id) as 'ID Mínimo',
    MAX(id) as 'ID Máximo',
    COUNT(*) as 'Total Registros'
FROM doctors;

-- Ver todos los doctores con sus IDs
SELECT id, name, lastName, specialty, email
FROM doctors
ORDER BY id;
