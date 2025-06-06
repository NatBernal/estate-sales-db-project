--Archivo de creación de consultas de BD ventas de inmuebles
--Fecha de creación: 18/05/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

-- Procedimiento para mostrar estadísticas y control
CREATE OR REPLACE PROCEDURE SP_MOSTRAR_ESTADISTICAS (
    P_FECHA_PROCESO IN DATE DEFAULT NULL
) AS
    V_COUNT        NUMBER;
    V_FECHA_FILTRO DATE := P_FECHA_PROCESO;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('=== ESTADÍSTICAS DE LA BASE DE DATOS  ===');
    IF V_FECHA_FILTRO IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('=== Fecha proceso: '
                             || TO_CHAR(V_FECHA_FILTRO, 'DD/MM/YYYY')
                             || ' ===');
    END IF;

    DBMS_OUTPUT.PUT_LINE('==========================================');
    
    -- Estadísticas de tablas
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        PUEBLOS;

    DBMS_OUTPUT.PUT_LINE('Pueblos: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        TIPOS_PROPIEDAD;

    DBMS_OUTPUT.PUT_LINE('Tipos de Propiedad: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        TIPOS_RESIDENCIA;

    DBMS_OUTPUT.PUT_LINE('Tipos de Residencia: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        LOCALIZACIONES;

    DBMS_OUTPUT.PUT_LINE('Localizaciones: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        PROPIEDADES;

    DBMS_OUTPUT.PUT_LINE('Propiedades: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        VENTAS;

    DBMS_OUTPUT.PUT_LINE('Ventas: ' || V_COUNT);
    SELECT
        COUNT(*)
    INTO V_COUNT
    FROM
        OBSERVACIONES;

    DBMS_OUTPUT.PUT_LINE('Observaciones: ' || V_COUNT);
    DBMS_OUTPUT.PUT_LINE('==========================================');
    
    -- Mostrar resumen de control de carga
    DBMS_OUTPUT.PUT_LINE('=== RESUMEN DE PROCESOS DE CARGA       ===');
    FOR REC IN (
        SELECT
            NOMBRE_TABLA,
            SUM(FILAS_AFECTADAS) AS TOTAL_FILAS,
            OPERACION,
            COUNT(*)             AS VECES_EJECUTADO
        FROM
            CONTROL_CARGA
        WHERE
            ( V_FECHA_FILTRO IS NULL
              OR TRUNC(FECHA_PROCESO) = TRUNC(V_FECHA_FILTRO) )
        GROUP BY
            NOMBRE_TABLA,
            OPERACION
        ORDER BY
            NOMBRE_TABLA,
            OPERACION
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(REC.NOMBRE_TABLA
                             || ' ('
                             || REC.OPERACION
                             || '): '
                             || REC.TOTAL_FILAS
                             || ' filas, '
                             || REC.VECES_EJECUTADO
                             || ' veces');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==========================================');
END SP_MOSTRAR_ESTADISTICAS;
/

-- 14. Procedimiento para consultar historial de control
CREATE OR REPLACE PROCEDURE SP_CONSULTAR_CONTROL (
    P_TABLA       IN VARCHAR2 DEFAULT NULL,
    P_FECHA_DESDE IN DATE DEFAULT NULL,
    P_FECHA_HASTA IN DATE DEFAULT NULL
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== HISTORIAL DE CONTROL DE CARGA ===');
    FOR REC IN (
        SELECT
            NOMBRE_TABLA,
            FILAS_AFECTADAS,
            OPERACION,
            TO_CHAR(FECHA_PROCESO, 'DD/MM/YYYY HH24:MI:SS') AS FECHA_PROCESO,
            USUARIO_PROCESO
        FROM
            CONTROL_CARGA
        WHERE
            ( P_TABLA IS NULL
              OR UPPER(NOMBRE_TABLA) = UPPER(P_TABLA) )
            AND ( P_FECHA_DESDE IS NULL
                  OR FECHA_PROCESO >= P_FECHA_DESDE )
            AND ( P_FECHA_HASTA IS NULL
                  OR FECHA_PROCESO <= P_FECHA_HASTA )
        ORDER BY
            FECHA_PROCESO DESC,
            NOMBRE_TABLA
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(REC.FECHA_PROCESO
                             || ' | '
                             || RPAD(REC.NOMBRE_TABLA, 20)
                             || ' | '
                             || LPAD(REC.OPERACION, 8)
                             || ' | '
                             || LPAD(REC.FILAS_AFECTADAS, 8)
                             || ' | '
                             || REC.USUARIO_PROCESO);
    END LOOP;

END SP_CONSULTAR_CONTROL;
/