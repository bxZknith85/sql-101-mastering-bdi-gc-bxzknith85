-- ##################################################
-- # CONSULTAS DATEPART, NOW, CURRENT_DATE, EXTRACT, AGE, INTERVAL - SMART HEALTH #
-- ##################################################

-- 1. Obtener todos los pacientes que nacieron en el mes actual,
-- mostrando su nombre completo, fecha de nacimiento y edad actual en años.
-- Dificultad: BAJA

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,
    p.birth_date,
    DATE_PART('year', AGE(p.birth_date)) AS edad_actual
FROM smart_health.patients p
WHERE DATE_PART('month', p.birth_date) = DATE_PART('month', CURRENT_DATE);

-- 2. Listar todas las citas programadas para los próximos 7 días,
-- mostrando la fecha de la cita, el nombre del paciente, el nombre del doctor,
-- y cuántos días faltan desde hoy hasta la cita.
-- Dificultad: BAJA

SELECT
    a.appointment_date,
    p.first_name || ' ' || p.first_surname AS paciente,
    d.first_name || ' ' || d.first_surname AS doctor,
    DATE_PART('day', a.appointment_date - CURRENT_DATE) AS dias_faltantes
FROM smart_health.appointments a
JOIN smart_health.patients p ON p.patient_id = a.patient_id
JOIN smart_health.doctors d ON d.doctor_id = a.doctor_id
WHERE a.appointment_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY a.appointment_date;

-- 3. Mostrar todos los médicos que ingresaron al hospital hace más de 5 años,
-- incluyendo su nombre completo, fecha de ingreso, y la cantidad exacta de años,
-- meses y días que han trabajado en el hospital.
-- Dificultad: BAJA-INTERMEDIA

SELECT
    d.first_name || ' ' || d.first_surname AS doctor,
    d.admission_date,
    AGE(CURRENT_DATE, d.admission_date) AS tiempo_trabajado
FROM smart_health.doctors d
WHERE d.admission_date <= CURRENT_DATE - INTERVAL '5 years'
ORDER BY d.admission_date;

-- 4. Obtener las prescripciones emitidas en el último mes,
-- mostrando la fecha de prescripción, el nombre del medicamento,
-- el nombre del paciente, cuántos días han pasado desde la prescripción,
-- y el día de la semana en que fue prescrito.
-- Dificultad: INTERMEDIA

SELECT
    pr.prescription_date,
    m.trade_name AS medicamento,
    p.first_name || ' ' || p.first_surname AS paciente,
    DATE_PART('day', CURRENT_DATE - pr.prescription_date) AS dias_desde_prescripcion,
    TO_CHAR(pr.prescription_date, 'Day') AS dia_de_la_semana
FROM smart_health.prescriptions pr
JOIN smart_health.medications m ON m.medication_id = pr.medication_id
JOIN smart_health.patients p ON p.patient_id = pr.patient_id
WHERE pr.prescription_date >= CURRENT_DATE - INTERVAL '1 month'
ORDER BY pr.prescription_date DESC;

-- 5. Listar todos los pacientes registrados en el sistema durante el trimestre actual,
-- mostrando su nombre completo, fecha de registro, edad actual,
-- el trimestre de registro, y cuántas semanas han pasado desde su registro,
-- ordenados por fecha de registro más reciente primero.
-- Dificultad: INTERMEDIA

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,
    p.registration_date,
    DATE_PART('year', AGE(p.birth_date)) AS edad_actual,
    DATE_PART('quarter', p.registration_date) AS trimestre_registro,
    DATE_PART('week', CURRENT_DATE - p.registration_date) AS semanas_desde_registro
FROM smart_health.patients p
WHERE DATE_PART('quarter', p.registration_date) = DATE_PART('quarter', CURRENT_DATE)
  AND DATE_PART('year', p.registration_date) = DATE_PART('year', CURRENT_DATE)
ORDER BY p.registration_date DESC;

-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################