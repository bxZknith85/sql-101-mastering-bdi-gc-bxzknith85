-- ##################################################
-- # CONSULTAS UPPER, LOWER, CONCAT, LENGTH, SUBSTRING - SMART HEALTH #
-- ##################################################

-- 1. Mostrar el nombre completo de todos los pacientes en mayúsculas,
-- junto con la longitud total de su nombre completo,
-- ordenados por la longitud del nombre de mayor a menor.
-- Dificultad: BAJA

SELECT
    UPPER(
        CONCAT(
            p.first_name, ' ',
            COALESCE(p.middle_name, ''), ' ',
            p.first_surname, ' ',
            COALESCE(p.second_surname, '')
        )
    ) AS nombre_completo_mayus,
    LENGTH(
        CONCAT(
            p.first_name, ' ',
            COALESCE(p.middle_name, ''), ' ',
            p.first_surname, ' ',
            COALESCE(p.second_surname, '')
        )
    ) AS longitud_nombre
FROM smart_health.patients p
ORDER BY longitud_nombre DESC;

-- 2. Listar todos los médicos mostrando su nombre en minúsculas,
-- su apellido en mayúsculas, y el correo electrónico profesional
-- con el dominio extraído después del símbolo '@'.
-- Dificultad: BAJA

SELECT
    LOWER(d.first_name) AS nombre_minuscula,
    UPPER(d.first_surname) AS apellido_mayuscula,
    SUBSTRING(d.email FROM POSITION('@' IN d.email) + 1) AS dominio_correo
FROM smart_health.doctors d;

-- 3. Obtener los nombres comerciales de todos los medicamentos en formato título
-- (primera letra mayúscula), junto con las primeras 3 letras del código ATC,
-- y la longitud del principio activo.
-- Dificultad: BAJA-INTERMEDIA

SELECT
    INITCAP(m.trade_name) AS nombre_titulo,
    SUBSTRING(m.atc_code FROM 1 FOR 3) AS atc_3_letras,
    LENGTH(m.active_ingredient) AS longitud_principio_activo
FROM smart_health.medications m;

-- 4. Mostrar el nombre completo de los pacientes concatenado con su tipo de documento,
-- las iniciales del paciente en mayúsculas (primera letra del nombre y apellido),
-- y los últimos 4 dígitos de su número de documento.
-- Dificultad: INTERMEDIA

SELECT
    CONCAT(
        p.first_name, ' ',
        COALESCE(p.middle_name, ''), ' ',
        p.first_surname, ' ',
        COALESCE(p.second_surname, ''),
        ' - ', p.document_type
    ) AS nombre_con_documento,

    -- Iniciales
    UPPER(
        SUBSTRING(p.first_name FROM 1 FOR 1) ||
        SUBSTRING(p.first_surname FROM 1 FOR 1)
    ) AS iniciales,

    -- Últimos 4 dígitos del documento
    SUBSTRING(p.document_number FROM LENGTH(p.document_number) - 3 FOR 4)
        AS ultimos_4_digitos
FROM smart_health.patients p;

-- 5. Listar las especialidades médicas mostrando el nombre en mayúsculas,
-- los primeros 10 caracteres de la descripción, la longitud total de la descripción,
-- y un código generado con las primeras 3 letras de la especialidad en mayúsculas.
-- Dificultad: INTERMEDIA

SELECT
    UPPER(s.specialty_name) AS nombre_mayus,
    SUBSTRING(s.description FROM 1 FOR 10) AS descripcion_10_chars,
    LENGTH(s.description) AS longitud_descripcion,
    UPPER(SUBSTRING(s.specialty_name FROM 1 FOR 3)) AS codigo_generado
FROM smart_health.specialties s;

-- 6. Obtener información de las citas mostrando el nombre del paciente en formato título,
-- el tipo de cita en minúsculas, el motivo con solo los primeros 20 caracteres,
-- y un código de referencia concatenando el ID de la cita con las iniciales del doctor.
-- Dificultad: INTERMEDIA-ALTA

SELECT
    INITCAP(p.first_name || ' ' || p.first_surname) AS paciente,
    LOWER(a.appointment_type) AS tipo_cita_minus,
    SUBSTRING(a.reason FROM 1 FOR 20) AS motivo_20,
    CONCAT(
        a.appointment_id, '-',
        UPPER(
            SUBSTRING(d.first_name FROM 1 FOR 1) ||
            SUBSTRING(d.first_surname FROM 1 FOR 1)
        )
    ) AS codigo_referencia
FROM smart_health.appointments a
JOIN smart_health.patients p ON p.patient_id = a.patient_id
JOIN smart_health.doctors d ON d.doctor_id = a.doctor_id;

-- 7. Mostrar las direcciones completas concatenando todos sus componentes,
-- el código del municipio en mayúsculas, los primeros 5 caracteres de la línea de dirección,
-- la longitud de la dirección completa, y el código postal formateado en minúsculas,
-- junto con el nombre del municipio y departamento en formato título.
-- Dificultad: ALTA

SELECT
    -- Dirección completa concatenada
    CONCAT(
        a.address_line, ', ',
        a.neighborhood, ', ',
        a.zip_code, ', ',
        a.municipality_code
    ) AS direccion_completa,

    UPPER(a.municipality_code) AS municipio_mayus,

    SUBSTRING(a.address_line FROM 1 FOR 5) AS primeros_5_direccion,

    LENGTH(
        CONCAT(
            a.address_line, ' ',
            a.neighborhood, ' ',
            a.zip_code, ' ',
            a.municipality_code
        )
    ) AS longitud_direccion_completa,

    LOWER(a.zip_code) AS codigo_postal_minus,

    INITCAP(m.name) AS municipio_titulo,
    INITCAP(m.department) AS departamento_titulo
FROM smart_health.addresses a
JOIN smart_health.municipalities m ON m.municipality_code = a.municipality_code;

-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################