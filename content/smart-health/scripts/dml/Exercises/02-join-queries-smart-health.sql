-- ##################################################
-- #   CONSULTAS CON JOINS - SMART HEALTH          #
-- ##################################################

-- 1. Listar todos los pacientes con su tipo de documento correspondiente,
-- mostrando el nombre completo del paciente, número de documento y nombre del tipo de documento,
-- ordenados por apellido del paciente.
SELECT
    T1.first_name||' '||COALESCE(T1.middle_name, '')||' '||T1.first_surname||' '||COALESCE(T1.second_surname, '') AS paciente,
    T1.document_number AS numero_documento,
    T2.type_name AS tipo_documento

FROM smart_health.patients T1
INNER JOIN smart_health.document_types T2
    ON T1.document_type_id = T2.document_type_id
ORDER BY T1.first_surname
LIMIT 10; 


-- 2. Consultar todas las citas médicas con la información del paciente y del doctor asignado,
-- mostrando nombres completos, fecha y hora de la cita,
-- ordenadas por fecha de cita de forma descendente.

SELECT
    T2.first_name||' '||COALESCE(T2.middle_name, '')||' '||T2.first_surname||' '||COALESCE(T2.second_surname, '') AS paciente,
    T1.appointment_date AS fecha_cita,
    T1.start_time AS hora_inicio_cita,
    T1.end_time AS hora_fin_cita,
    'Dr. '||' '||T3.first_name||' '||COALESCE(T3.last_name, '') AS doctor_asignado,
    T3.internal_code AS codigo_medico

FROM smart_health.appointments T1
INNER JOIN smart_health.patients T2
    ON T1.patient_id = T2.patient_id
INNER JOIN smart_health.doctors T3
    ON T1.doctor_id = T3.doctor_id
ORDER BY T1.appointment_date DESC
LIMIT 10;


-- 3. Obtener todas las direcciones de pacientes con información completa del municipio y departamento,
-- mostrando el nombre del paciente, dirección completa y ubicación geográfica,
-- ordenadas por departamento y municipio.

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,

    a.address_line AS direccion,
    a.postal_code AS codigo_postal,

    m.municipality_name AS municipio,
    d.department_name AS departamento

FROM smart_health.patient_addresses pa
INNER JOIN smart_health.patients p
    ON pa.patient_id = p.patient_id
INNER JOIN smart_health.addresses a
    ON pa.address_id = a.address_id
INNER JOIN smart_health.municipalities m
    ON a.municipality_code = m.municipality_code
INNER JOIN smart_health.departments d
    ON m.department_code = d.department_code

ORDER BY d.department_name, m.municipality_name;

-- 4. Listar todos los médicos con sus especialidades asignadas,
-- mostrando el nombre del doctor, especialidad y fecha de certificación,
-- filtrando solo especialidades activas y ordenadas por apellido del médico.

SELECT
    d.first_name || ' ' || d.last_name AS doctor,
    s.specialty_name AS especialidad,
    ds.certification_date AS fecha_certificacion
FROM smart_health.doctors d
INNER JOIN smart_health.doctor_specialties ds
    ON d.doctor_id = ds.doctor_id
INNER JOIN smart_health.specialties s
    ON ds.specialty_id = s.specialty_id
WHERE s.active = TRUE
ORDER BY d.last_name ASC;


-- [NO REALIZAR]
-- 5. Consultar todas las alergias de pacientes con información del medicamento asociado,
-- mostrando el nombre del paciente, medicamento, severidad y descripción de la reacción,
-- filtrando solo alergias graves o críticas, ordenadas por severidad.

-- [NO REALIZAR]
-- 6. Obtener todos los registros médicos con el diagnóstico principal asociado,
-- mostrando el paciente, doctor que registró, diagnóstico y fecha del registro,
-- filtrando registros del último año, ordenados por fecha de registro descendente.

-- 7. Listar todas las prescripciones médicas con información del medicamento y registro médico asociado,
-- mostrando el paciente, medicamento prescrito, dosis y si se generó alguna alerta,
-- filtrando prescripciones con alertas generadas, ordenadas por fecha de prescripción.

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,

    m.commercial_name AS medicamento,
    pr.dosage AS dosis,
    pr.alert_generated AS alerta_generada,
    pr.prescription_date AS fecha_prescripcion

FROM smart_health.prescriptions pr
INNER JOIN smart_health.medical_records mr
    ON pr.medical_record_id = mr.medical_record_id
INNER JOIN smart_health.patients p
    ON mr.patient_id = p.patient_id
INNER JOIN smart_health.medications m
    ON pr.medication_id = m.medication_id

WHERE pr.alert_generated = TRUE
ORDER BY pr.prescription_date DESC;

-- 8. Consultar todas las citas con información de la sala asignada (si tiene),
-- mostrando paciente, doctor, sala y horario,
-- usando LEFT JOIN para incluir citas sin sala asignada, ordenadas por fecha y hora.

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,

    'Dr. ' || d.first_name || ' ' || d.last_name AS doctor,

    r.room_name AS sala,
    r.room_type AS tipo_sala,

    a.appointment_date AS fecha,
    a.start_time AS hora_inicio,
    a.end_time AS hora_fin

FROM smart_health.appointments a
INNER JOIN smart_health.patients p
    ON a.patient_id = p.patient_id
INNER JOIN smart_health.doctors d
    ON a.doctor_id = d.doctor_id
LEFT JOIN smart_health.rooms r
    ON a.room_id = r.room_id

ORDER BY a.appointment_date ASC, a.start_time ASC;


-- 9. Listar todos los teléfonos de pacientes con información completa del paciente,
-- mostrando nombre, tipo de teléfono, número y si es el teléfono principal,
-- filtrando solo teléfonos móviles, ordenados por nombre del paciente.

SELECT
    p.first_name || ' ' || COALESCE(p.middle_name, '') || ' ' ||
    p.first_surname || ' ' || COALESCE(p.second_surname, '') AS paciente,

    ph.phone_type,
    ph.phone_number,
    ph.is_primary AS principal

FROM smart_health.patient_phones ph
INNER JOIN smart_health.patients p
    ON ph.patient_id = p.patient_id

WHERE ph.phone_type ILIKE 'mobile'
ORDER BY p.first_surname, p.first_name;

-- 10. Obtener todos los doctores que NO tienen especialidades asignadas (ANTI JOIN),
-- mostrando su información básica y fecha de ingreso,
-- útil para identificar médicos que requieren actualización de información,
-- ordenados por fecha de ingreso al hospital.

SELECT
    d.doctor_id,
    d.internal_code,
    d.first_name,
    d.last_name,
    d.hospital_admission_date
FROM smart_health.doctors d
LEFT JOIN smart_health.doctor_specialties ds
    ON d.doctor_id = ds.doctor_id
WHERE ds.doctor_id IS NULL
ORDER BY d.hospital_admission_date ASC;

-- ##################################################
-- #              FIN DE CONSULTAS                  #
-- ##################################################