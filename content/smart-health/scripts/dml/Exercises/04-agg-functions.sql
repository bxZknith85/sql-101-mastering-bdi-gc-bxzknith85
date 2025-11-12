-- ##################################################
-- # CONSULTAS GROUP BY QUERIES AND AGG FUNCTIONS WITH DATE AND STRING FUNCTIONS LIKE DATEPART, SPLIT, AGE, INTERVAL, UPPER, LOWER AND SO ON, USING JOINS - SMART HEALTH #
-- ##################################################

-- 1. Contar cuántos pacientes nacieron en cada mes del año,
-- mostrando el número del mes y el nombre del mes en mayúsculas,
-- junto con la cantidad total de pacientes nacidos en ese mes.
-- Dificultad: BAJA

SELECT
    EXTRACT(MONTH FROM birth_date) AS mes_numero,
    UPPER(TO_CHAR(birth_date, 'Month')) AS mes_nombre,
    COUNT(*) AS total_pacientes
FROM smart_health.patients
GROUP BY mes_numero, mes_nombre
ORDER BY mes_numero;

-- 2. Mostrar el número de citas programadas agrupadas por día de la semana,
-- incluyendo el nombre del día en español y la cantidad de citas,
-- ordenadas por la cantidad de citas de mayor a menor.
-- Dificultad: BAJA

SELECT
    EXTRACT(DOW FROM appointment_date) AS numero_dia,
    UPPER(TO_CHAR(appointment_date, 'TMDay')) AS dia_semana,
    COUNT(*) AS total_citas
FROM smart_health.appointments
GROUP BY numero_dia, dia_semana
ORDER BY total_citas DESC;

-- 3. Calcular la cantidad de años promedio que los médicos han trabajado en el hospital,
-- agrupados por especialidad, mostrando el nombre de la especialidad en mayúsculas
-- y el promedio de años de experiencia redondeado a un decimal.
-- Dificultad: BAJA-INTERMEDIA

SELECT
    UPPER(s.specialty_name) AS especialidad,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, d.hospital_admission_date))), 1)
        AS promedio_anios_experiencia
FROM smart_health.doctor_specialties ds
INNER JOIN smart_health.doctors d
    ON ds.doctor_id = d.doctor_id
INNER JOIN smart_health.specialties s
    ON ds.specialty_id = s.specialty_id
GROUP BY especialidad
ORDER BY promedio_anios_experiencia DESC;


-- 4. Obtener el número de pacientes registrados por año,
-- mostrando el año de registro, el trimestre, y el total de pacientes,
-- solo para aquellos trimestres que tengan más de 2 pacientes registrados.
-- Dificultad: INTERMEDIA

SELECT
    DATE_PART('year', registration_date) AS anio,
    DATE_PART('quarter', registration_date) AS trimestre,
    COUNT(*) AS total_pacientes
FROM smart_health.patients
GROUP BY anio, trimestre
HAVING COUNT(*) > 2
ORDER BY anio, trimestre;

-- 5. Listar el número de prescripciones emitidas por mes y año,
-- mostrando el mes en formato texto con la primera letra en mayúscula,
-- el año, y el total de prescripciones, junto con el nombre del medicamento más prescrito.
-- Dificultad: INTERMEDIA

SELECT
    INITCAP(TO_CHAR(p.prescription_date, 'Month')) AS mes,
    DATE_PART('year', p.prescription_date) AS anio,
    COUNT(*) AS total_prescripciones,
    (
        SELECT m2.commercial_name
        FROM smart_health.prescriptions p2
        INNER JOIN smart_health.medications m2
            ON p2.medication_id = m2.medication_id
        WHERE DATE_PART('month', p2.prescription_date) = DATE_PART('month', p.prescription_date)
          AND DATE_PART('year', p2.prescription_date) = DATE_PART('year', p.prescription_date)
        GROUP BY m2.commercial_name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS medicamento_mas_prescrito

FROM smart_health.prescriptions p
GROUP BY mes, anio
ORDER BY anio, mes;

-- 6. Calcular la edad promedio de los pacientes agrupados por tipo de sangre,
-- mostrando el tipo de sangre, la edad mínima, la edad máxima y la edad promedio,
-- solo para grupos que tengan al menos 3 pacientes.
-- Dificultad: INTERMEDIA

SELECT
    blood_type AS tipo_sangre,
    MIN(EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))) AS edad_minima,
    MAX(EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))) AS edad_maxima,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))), 1) AS edad_promedio
FROM smart_health.patients
GROUP BY blood_type
HAVING COUNT(*) >= 3
ORDER BY tipo_sangre;

-- 7. Mostrar el número de citas por médico y por mes,
-- incluyendo el nombre completo del doctor en mayúsculas, el mes y año de la cita,
-- la duración promedio de las citas en minutos, y el total de citas realizadas,
-- solo para aquellos médicos que tengan más de 5 citas en el mes.
-- Dificultad: INTERMEDIA-ALTA

SELECT
    UPPER(d.first_name || ' ' || d.last_name) AS doctor,
    DATE_PART('month', a.appointment_date) AS mes,
    DATE_PART('year', a.appointment_date) AS anio,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 60
    ), 1) AS duracion_promedio_minutos,

    COUNT(*) AS total_citas
FROM smart_health.appointments a
INNER JOIN smart_health.doctors d
    ON a.doctor_id = d.doctor_id
GROUP BY doctor, mes, anio
HAVING COUNT(*) > 5
ORDER BY doctor, anio, mes;

-- 8. Obtener estadísticas de alergias por severidad y mes de diagnóstico,
-- mostrando la severidad en minúsculas, el nombre del mes abreviado,
-- el total de alergias registradas, y el número de pacientes únicos afectados,
-- junto con el nombre comercial del medicamento más común en cada grupo.
-- Dificultad: INTERMEDIA-ALTA

SELECT
    LOWER(pa.severity) AS severidad,
    TO_CHAR(pa.diagnosed_date, 'Mon') AS mes_abreviado,
    COUNT(*) AS total_alergias,
    COUNT(DISTINCT pa.patient_id) AS pacientes_unicos,
    (
        SELECT m2.commercial_name
        FROM smart_health.patient_allergies pa2
        INNER JOIN smart_health.medications m2
            ON pa2.medication_id = m2.medication_id
        WHERE LOWER(pa2.severity) = LOWER(pa.severity)
          AND DATE_PART('month', pa2.diagnosed_date) = DATE_PART('month', pa.diagnosed_date)
        GROUP BY m2.commercial_name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS medicamento_mas_comun

FROM smart_health.patient_allergies pa
GROUP BY severidad, mes_abreviado
ORDER BY severidad, mes_abreviado;

-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################