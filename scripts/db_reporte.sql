--Archivo de Generación de Reportes
--Fecha de creación: 06/06/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

CREATE TABLE REPORTE_VENTAS_ANIO (
    ANIO_VENTA           NUMBER,
    TOTAL_VENTAS         NUMBER,
    PROMEDIO_VALOR_VENTA FLOAT,
    TOTAL_VALOR_VENTA    FLOAT,
    FECHA_GENERACION     DATE
);

CREATE OR REPLACE PROCEDURE SP_GENERAR_REPORTE (
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN    IN DATE
) AS
BEGIN

-- Primero limpiamos reportes anteriores en el mismo rango de años si es necesario

    DELETE FROM REPORTE_VENTAS_ANIO
    WHERE
        ANIO_VENTA IN (
            SELECT DISTINCT
                ANIO_VENTA
            FROM
                VENTAS
            WHERE
                FECHA_REGISTRO BETWEEN P_FECHA_INICIO AND P_FECHA_FIN
        );


-- Insertamos los resultados en la tabla de reporte

    INSERT INTO REPORTE_VENTAS_ANIO (
        ANIO_VENTA,
        TOTAL_VENTAS,
        PROMEDIO_VALOR_VENTA,
        TOTAL_VALOR_VENTA,
        FECHA_GENERACION
    )
        SELECT
            ANIO_VENTA,
            COUNT(*) AS TOTAL_VENTAS,
            ROUND(
                AVG(VALOR_VENTA),
                3
            )        AS PROMEDIO_VALOR_VENTA,
            ROUND(
                SUM(VALOR_VENTA),
                3
            )        AS TOTAL_VALOR_VENTA,
            SYSDATE  AS FECHA_GENERACION
        FROM
            VENTAS
        WHERE
            FECHA_REGISTRO BETWEEN P_FECHA_INICIO AND P_FECHA_FIN
        GROUP BY
            ANIO_VENTA;

    COMMIT;

    -- Llamada al procedimiento de pivotear los resultados
    SP_GENERAR_VISTA_PIVOTE_VENTAS;

END SP_GENERAR_REPORTE;
/

CREATE OR REPLACE PROCEDURE SP_MOSTRAR_ESTADISTICAS (
    P_FECHA_PROCESO IN DATE DEFAULT NULL
) AS
    V_COUNT        NUMBER;
    V_FECHA_FILTRO DATE := P_FECHA_PROCESO;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Estadísticas de la base de datos');
    IF V_FECHA_FILTRO IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Fecha proceso: '
                             || TO_CHAR(V_FECHA_FILTRO, 'DD MM YYYY'));
    END IF;

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
    DBMS_OUTPUT.PUT_LINE('Resumen de control de carga');
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

END SP_MOSTRAR_ESTADISTICAS;
/

CREATE OR REPLACE FUNCTION GET_TOTAL_VENTAS_ANIO (
    P_ANIO IN NUMBER
) RETURN NUMBER AS
    V_TOTAL NUMBER := 0;
BEGIN
    SELECT
        NVL(
            SUM(VALOR_VENTA),
            0
        )
    INTO V_TOTAL
    FROM
        VENTAS
    WHERE
        ANIO_VENTA = P_ANIO;

    RETURN V_TOTAL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END GET_TOTAL_VENTAS_ANIO;
/

CREATE OR REPLACE FUNCTION GET_PROMEDIO_VENTAS_ANIO (
    P_ANIO IN NUMBER
) RETURN NUMBER AS
    V_PROMEDIO NUMBER := 0;
BEGIN
    SELECT
        NVL(
            AVG(VALOR_VENTA),
            0
        )
    INTO V_PROMEDIO
    FROM
        VENTAS
    WHERE
        ANIO_VENTA = P_ANIO;

    RETURN V_PROMEDIO;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;
END GET_PROMEDIO_VENTAS_ANIO;
/

-- Crear pivote dinamico para el reporte
create or replace PROCEDURE SP_GENERAR_VISTA_PIVOTE_VENTAS
AS
    v_sql   CLOB;
    v_cols  CLOB := '';
BEGIN
    -- Construir dinámicamente la lista de columnas para el PIVOT
    FOR r IN (
        SELECT DISTINCT ANIO_VENTA
        FROM REPORTE_VENTAS_ANIO
        ORDER BY ANIO_VENTA
    )
    LOOP
        v_cols := v_cols || r.ANIO_VENTA || ' AS "AÑO_' || r.ANIO_VENTA || '", ';
    END LOOP;

    -- Eliminar la última coma
    v_cols := RTRIM(v_cols, ', ');

    -- Verificar que la variable v_cols no esté vacía
    IF v_cols IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'No hay años disponibles para el reporte.');
    END IF;

    -- Construir el SQL del PIVOT
    v_sql := '
        CREATE OR REPLACE VIEW VW_REPORTE_VENTAS_PIVOTE AS
        SELECT *
        FROM (
            SELECT
                ''TOTAL_VENTAS'' AS METRICA,
                ANIO_VENTA,
                TOTAL_VENTAS AS VALOR
            FROM REPORTE_VENTAS_ANIO
            UNION ALL
            SELECT
                ''PROMEDIO_VALOR_VENTA'',
                ANIO_VENTA,
                PROMEDIO_VALOR_VENTA
            FROM REPORTE_VENTAS_ANIO
            UNION ALL
            SELECT
                ''TOTAL_VALOR_VENTA'',
                ANIO_VENTA,
                TOTAL_VALOR_VENTA
            FROM REPORTE_VENTAS_ANIO
        )
        PIVOT (
            SUM(VALOR)
            FOR ANIO_VENTA IN (' || v_cols || ')
        )
        ORDER BY METRICA';

    -- Ejecutar la creación de la vista
    EXECUTE IMMEDIATE v_sql;
END sp_crear_vista_pivote_dinamica;