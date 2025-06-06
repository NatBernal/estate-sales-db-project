CREATE TABLE REPORTE_VENTAS_ANIO (
    ANIO_VENTA           NUMBER,
    TOTAL_VENTAS         NUMBER,
    PROMEDIO_VALOR_VENTA FLOAT,
    TOTAL_VALOR_VENTA    FLOAT,
    FECHA_GENERACION     DATE
);

CREATE OR REPLACE PROCEDURE GENERAR_REPORTE (
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
END GENERAR_REPORTE;
/

CREATE OR REPLACE PROCEDURE SP_MOSTRAR_ESTADISTICAS (
    P_FECHA_PROCESO IN DATE DEFAULT NULL
) AS
    V_COUNT        NUMBER;
    V_FECHA_FILTRO DATE := P_FECHA_PROCESO;
BEGIN
    DBMS_OUTPUT.PUT_LINE('___________________________________________');
    DBMS_OUTPUT.PUT_LINE('___ ESTADÍSTICAS DE LA BASE DE DATOS  ___');
    IF V_FECHA_FILTRO IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('___ Fecha proceso: '
                             || TO_CHAR(V_FECHA_FILTRO, 'DD MM YYYY')
                             || ' __');
    END IF;

    DBMS_OUTPUT.PUT_LINE('==========================================');
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
    DBMS_OUTPUT.PUT_LINE('______________________________________________');
    DBMS_OUTPUT.PUT_LINE('_______ RESUMEN DE PROCESOS DE CARGA    _______');
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

    DBMS_OUTPUT.PUT_LINE('________________________________________-');
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

CREATE VIEW REPORTE_PIBOTE AS
    SELECT
        *
    FROM
        (
            SELECT
                'TOTAL_VENTAS' AS METRICA,
                ANIO_VENTA,
                TOTAL_VENTAS   AS VALOR
            FROM
                REPORTE_VENTAS_ANIO
            UNION ALL
            SELECT
                'PROMEDIO_VALOR_VENTA' AS METRICA,
                ANIO_VENTA,
                PROMEDIO_VALOR_VENTA
            FROM
                REPORTE_VENTAS_ANIO
            UNION ALL
            SELECT
                'TOTAL_VALOR_VENTA' AS METRICA,
                ANIO_VENTA,
                TOTAL_VALOR_VENTA
            FROM
                REPORTE_VENTAS_ANIO
        ) PIVOT (
            SUM(VALOR)
            FOR ANIO_VENTA
            IN ( 2001 AS "AÑO_2001", 2005 AS "AÑO_2005", 2006 AS "AÑO_2006", 2007 AS "AÑO_2007", 2008 AS "AÑO_2008", 2009 AS "AÑO_2009"
            , 2011 AS "AÑO_2011", 2012 AS "AÑO_2012", 2013 AS "AÑO_2013", 2014 AS "AÑO_2014", 2015 AS "AÑO_2015", 2016 AS "AÑO_2016",
            2019 AS "AÑO_2019", 2020 AS "AÑO_2020", 2021 AS "AÑO_2021" )
        )
    ORDER BY
        METRICA;

SELECT * FROM REPORTE_PIBOTE;

BEGIN

GENERAR_REPORTE(

    TO_DATE('2001-01-01', 'YYYY-MM-DD'),

    TO_DATE('2024-12-31', 'YYYY-MM-DD')

); end;
/

select * from reporte_ventas_anio;