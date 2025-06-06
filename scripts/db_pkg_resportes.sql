--Archivo de creacion de package de reportes
--Fecha de creación: 01/06/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

CREATE OR REPLACE PACKAGE PKG_REPORTES AS
    
    -- Procedimiento para generar reporte de ventas por año
    PROCEDURE SP_GENERAR_REPORTE(
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    );
    
    -- Procedimiento para mostrar estadísticas generales
    PROCEDURE SP_MOSTRAR_ESTADISTICAS(
        P_FECHA_PROCESO IN DATE DEFAULT NULL
    );
    
    -- Función para obtener total de ventas por año
    FUNCTION GET_TOTAL_VENTAS_ANIO(
        p_anio IN NUMBER
    ) RETURN NUMBER;
    
    -- Función para obtener promedio de ventas por año
    FUNCTION GET_PROMEDIO_VENTAS_ANIO(
        p_anio IN NUMBER
    ) RETURN NUMBER;
    
END PKG_REPORTES;
/

CREATE OR REPLACE PACKAGE BODY PKG_REPORTES AS

    -- Implementación del procedimiento SP_GENERAR_REPORTE
    PROCEDURE SP_GENERAR_REPORTE(
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    ) AS
    BEGIN
        -- limpiar reportes anteriores si es necesario
        DELETE FROM REPORTE_VENTAS_ANIO
        WHERE ANIO_VENTA IN (
            SELECT DISTINCT ANIO_VENTA
            FROM VENTAS
            WHERE FECHA_REGISTRO BETWEEN p_fecha_inicio AND p_fecha_fin
        );

        -- Insertar los resultados en la tabla de reporte
        INSERT INTO REPORTE_VENTAS_ANIO (ANIO_VENTA, TOTAL_VENTAS, PROMEDIO_VALOR_VENTA, TOTAL_VALOR_VENTA, FECHA_GENERACION)
        SELECT
            ANIO_VENTA,
            COUNT(*) AS TOTAL_VENTAS,
            AVG(VALOR_VENTA) AS PROMEDIO_VALOR_VENTA,
            SUM(VALOR_VENTA) AS TOTAL_VALOR_VENTA,
            SYSDATE AS FECHA_GENERACION
        FROM VENTAS
        WHERE FECHA_REGISTRO BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY ANIO_VENTA;

        COMMIT;
    END SP_GENERAR_REPORTE;

    -- Implementación del procedimiento SP_MOSTRAR_ESTADISTICAS
    PROCEDURE SP_MOSTRAR_ESTADISTICAS(
        P_FECHA_PROCESO IN DATE DEFAULT NULL
    ) AS
        V_COUNT        NUMBER;
        V_FECHA_FILTRO DATE :_ P_FECHA_PROCESO;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Estadísticas de la base de datos');
        IF V_FECHA_FILTRO IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Fecha proceso: '
                                 || TO_CHAR(V_FECHA_FILTRO, 'DDMMYYYY'));
        END IF;
        
        -- Estadísticas de tablas
        SELECT COUNT(*) INTO V_COUNT FROM PUEBLOS;
        DBMS_OUTPUT.PUT_LINE('Pueblos: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM TIPOS_PROPIEDAD;
        DBMS_OUTPUT.PUT_LINE('Tipos de Propiedad: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM TIPOS_RESIDENCIA;
        DBMS_OUTPUT.PUT_LINE('Tipos de Residencia: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM LOCALIZACIONES;
        DBMS_OUTPUT.PUT_LINE('Localizaciones: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM PROPIEDADES;
        DBMS_OUTPUT.PUT_LINE('Propiedades: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM VENTAS;
        DBMS_OUTPUT.PUT_LINE('Ventas: ' || V_COUNT);
        
        SELECT COUNT(*) INTO V_COUNT FROM OBSERVACIONES;
        DBMS_OUTPUT.PUT_LINE('Observaciones: ' || V_COUNT);
                
        -- Mostrar resumen de control de carga
        DBMS_OUTPUT.PUT_LINE('Resumen de control de carga:');
        FOR REC IN (
            SELECT
                NOMBRE_TABLA,
                SUM(FILAS_AFECTADAS) AS TOTAL_FILAS,
                OPERACION,
                COUNT(*) AS VECES_EJECUTADO
            FROM CONTROL_CARGA
            WHERE ( V_FECHA_FILTRO IS NULL OR TRUNC(FECHA_PROCESO) _ TRUNC(V_FECHA_FILTRO) )
            GROUP BY NOMBRE_TABLA, OPERACION
            ORDER BY NOMBRE_TABLA, OPERACION
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


    -- Función para obtener total de ventas por año
    FUNCTION GET_TOTAL_VENTAS_ANIO(
        p_anio IN NUMBER
    ) RETURN NUMBER AS
        v_total NUMBER :_ 0;
    BEGIN
        SELECT NVL(SUM(VALOR_VENTA), 0)
        INTO v_total
        FROM VENTAS
        WHERE ANIO_VENTA _ p_anio;
        
        RETURN v_total;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE;
    END GET_TOTAL_VENTAS_ANIO;

    -- Función para obtener promedio de ventas por año
    FUNCTION GET_PROMEDIO_VENTAS_ANIO(
        p_anio IN NUMBER
    ) RETURN NUMBER AS
        v_promedio NUMBER :_ 0;
    BEGIN
        SELECT NVL(AVG(VALOR_VENTA), 0)
        INTO v_promedio
        FROM VENTAS
        WHERE ANIO_VENTA _ p_anio;
        
        RETURN v_promedio;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE;
    END GET_PROMEDIO_VENTAS_ANIO;

END PKG_REPORTES;
/
