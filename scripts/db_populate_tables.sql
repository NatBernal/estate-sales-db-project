--Archivo de poblado de tablas de BD Ventas inmobiliarias
--Fecha de creación: 01/06/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

-- Crear secuencia para el id de control
CREATE SEQUENCE SEQ_CONTROL_ID START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Crear tabla de control de procesos de carga
CREATE TABLE CONTROL_CARGA (
    ID_CONTROL      NUMBER DEFAULT SEQ_CONTROL_ID.NEXTVAL,
    NOMBRE_TABLA    VARCHAR2(50) NOT NULL,
    FILAS_AFECTADAS NUMBER NOT NULL,
    OPERACION       VARCHAR2(10) NOT NULL,
    FECHA_PROCESO   DATE NOT NULL,
    USUARIO_PROCESO VARCHAR2(50) NOT NULL
)
TABLESPACE DATOS_VENTAS;

-- Comentarios tabla control
COMMENT ON TABLE CONTROL_CARGA IS
    'Tabla de auditoría para procesos de carga de datos';

COMMENT ON COLUMN CONTROL_CARGA.NOMBRE_TABLA IS
    'Nombre de la tabla afectada por el proceso';

COMMENT ON COLUMN CONTROL_CARGA.FILAS_AFECTADAS IS
    'Cantidad de registros procesados';

COMMENT ON COLUMN CONTROL_CARGA.OPERACION IS
    'Tipo de operación realizada (INSERT, UPDATE, DELETE)';

COMMENT ON COLUMN CONTROL_CARGA.FECHA_PROCESO IS
    'Fecha y hora del proceso de carga';

COMMENT ON COLUMN CONTROL_CARGA.USUARIO_PROCESO IS
    'Usuario que ejecutó el proceso';

-- Restricciones de la tabla control
ALTER TABLE CONTROL_CARGA
    ADD CONSTRAINT PK_CONTROL PRIMARY KEY ( ID_CONTROL )
        USING INDEX TABLESPACE TS_INDICES_VENTAS;

ALTER TABLE CONTROL_CARGA
    ADD CONSTRAINT CK_OPERACION
        CHECK ( OPERACION IN ( 'INSERT', 'UPDATE', 'DELETE' ) );

-- Procedimiento para registrar operaciones en control
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_CONTROL (
    P_NOMBRE_TABLA    IN VARCHAR2,
    P_FILAS_AFECTADAS IN NUMBER,
    P_OPERACION       IN VARCHAR2,
    P_FECHA_PROCESO   IN DATE DEFAULT SYSDATE,
    P_USUARIO         IN VARCHAR2 DEFAULT USER
) AS
BEGIN
    INSERT INTO CONTROL_CARGA (
        NOMBRE_TABLA,
        FILAS_AFECTADAS,
        OPERACION,
        FECHA_PROCESO,
        USUARIO_PROCESO
    ) VALUES ( P_NOMBRE_TABLA,
               P_FILAS_AFECTADAS,
               P_OPERACION,
               P_FECHA_PROCESO,
               P_USUARIO );

    COMMIT;
END SP_REGISTRAR_CONTROL;
/

-- Procedimiento para poblar tabla PUEBLOS
CREATE OR REPLACE PROCEDURE SP_POBLAR_PUEBLOS (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO PUEBLOS ( NOMBRE )
        SELECT DISTINCT
            PUEBLO
        FROM
            TABLA_PRUEBA
        WHERE
            PUEBLO IS NOT NULL
            AND TRIM(PUEBLO) != ''
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    PUEBLOS P
                WHERE
                    UPPER(P.NOMBRE) = UPPER(TABLA_PRUEBA.PUEBLO)
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
    
    -- Registrar en control
    SP_REGISTRAR_CONTROL('PUEBLOS', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Pueblos insertados: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar pueblos: ' || SQLERRM);
        RAISE;
END SP_POBLAR_PUEBLOS;
/

-- Procedimiento para poblar tabla TIPOS_PROPIEDAD
CREATE OR REPLACE PROCEDURE SP_POBLAR_TIPOS_PROPIEDAD (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO TIPOS_PROPIEDAD ( DESCRIPCION )
        SELECT DISTINCT
            TIPO_PROPIEDAD
        FROM
            TABLA_PRUEBA
        WHERE
            TIPO_PROPIEDAD IS NOT NULL
            AND TRIM(TIPO_PROPIEDAD) != ''
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    TIPOS_PROPIEDAD TP
                WHERE
                    UPPER(TP.DESCRIPCION) = UPPER(TABLA_PRUEBA.TIPO_PROPIEDAD)
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
    SP_REGISTRAR_CONTROL('TIPOS_PROPIEDAD', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Tipos de propiedad insertados: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar tipos de propiedad: ' || SQLERRM);
        RAISE;
END SP_POBLAR_TIPOS_PROPIEDAD;
/

-- 6. Procedimiento para poblar tabla TIPOS_RESIDENCIA
CREATE OR REPLACE PROCEDURE SP_POBLAR_TIPOS_RESIDENCIA (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA DE TIPOS DE RESIDENCIA ===');
    INSERT INTO TIPOS_RESIDENCIA ( DESCRIPCION )
        SELECT DISTINCT
            TIPO_RESIDENCIA
        FROM
            TABLA_PRUEBA
        WHERE
            TIPO_RESIDENCIA IS NOT NULL
            AND TRIM(TIPO_RESIDENCIA) != ''
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    TIPOS_RESIDENCIA TR
                WHERE
                    UPPER(TR.DESCRIPCION) = UPPER(TABLA_PRUEBA.TIPO_RESIDENCIA)
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
    SP_REGISTRAR_CONTROL('TIPOS_RESIDENCIA', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Tipos de residencia insertados: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar tipos de residencia: ' || SQLERRM);
        RAISE;
END SP_POBLAR_TIPOS_RESIDENCIA;
/

-- Procedimiento para poblar tabla LOCALIZACIONES
CREATE OR REPLACE PROCEDURE SP_POBLAR_LOCALIZACIONES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_LATITUD          NUMBER;
    V_LONGITUD         NUMBER;
    V_POS_INI          NUMBER;
    V_POS_FIN          NUMBER;
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA DE LOCALIZACIONES ===');
    FOR REC IN (
        SELECT DISTINCT
            PUEBLO,
            ADDRESS,
            LOCATION
        FROM
            TABLA_PRUEBA
        WHERE
            ADDRESS IS NOT NULL
            AND TRIM(ADDRESS) != ''
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    LOCALIZACIONES L
                WHERE
                    UPPER(L.DIRECCION) = UPPER(TABLA_PRUEBA.ADDRESS)
            )
    ) LOOP
        -- Extraer latitud y longitud del campo LOCATION
        V_LATITUD := NULL;
        V_LONGITUD := NULL;
        IF
            REC.LOCATION IS NOT NULL
            AND INSTR(
                UPPER(REC.LOCATION),
                'POINT'
            ) > 0
        THEN
            V_POS_INI := INSTR(REC.LOCATION, '(') + 1;
            V_POS_FIN := INSTR(REC.LOCATION, ')') - 1;
            IF
                V_POS_INI > 1
                AND V_POS_FIN > V_POS_INI
            THEN
                DECLARE
                    V_COORDS    VARCHAR2(100);
                    V_SPACE_POS NUMBER;
                BEGIN
                    V_COORDS := TRIM(SUBSTR(REC.LOCATION, V_POS_INI, V_POS_FIN - V_POS_INI + 1));

                    V_SPACE_POS := INSTR(V_COORDS, ' ');
                    IF V_SPACE_POS > 0 THEN
                        V_LONGITUD := TO_NUMBER ( TRIM(SUBSTR(V_COORDS, 1, V_SPACE_POS - 1)) );

                        V_LATITUD := TO_NUMBER ( TRIM(SUBSTR(V_COORDS, V_SPACE_POS + 1)) );
                    END IF;

                EXCEPTION
                    WHEN OTHERS THEN
                        V_LATITUD := NULL;
                        V_LONGITUD := NULL;
                END;
            END IF;

        END IF;
        
        -- Insertar localización
        INSERT INTO LOCALIZACIONES (
            ID_PUEBLO,
            LATITUD,
            LONGITUD,
            DIRECCION
        ) VALUES ( (
            SELECT
                ID_PUEBLO
            FROM
                PUEBLOS
            WHERE
                UPPER(NOMBRE) = UPPER(REC.PUEBLO)
        ),
                   V_LATITUD,
                   V_LONGITUD,
                   REC.ADDRESS );

        V_FILAS_INSERTADAS := V_FILAS_INSERTADAS + 1;
    END LOOP;

    COMMIT;
    SP_REGISTRAR_CONTROL('LOCALIZACIONES', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Localizaciones insertadas: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar localizaciones: ' || SQLERRM);
        RAISE;
END SP_POBLAR_LOCALIZACIONES;
/

-- 8. Procedimiento para poblar tabla PROPIEDADES
CREATE OR REPLACE PROCEDURE SP_POBLAR_PROPIEDADES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA DE PROPIEDADES ===');
    INSERT INTO PROPIEDADES (
        NUMERO_SERIAL,
        ID_TIPO_PROPIEDAD,
        ID_TIPO_RESIDENCIA,
        ID_LOCALIZACION,
        VALOR_CATASTRAL
    )
        SELECT DISTINCT
            TRE.SERIAL_NUMBER,
            TP.ID_TIPO_PROPIEDAD,
            TR.ID_TIPO_RESIDENCIA,
            L.ID_LOCALIZACION,
            TRE.ASSESSED_VALUE
        FROM
                 TABLA_PRUEBA TRE
            INNER JOIN LOCALIZACIONES   L ON UPPER(L.DIRECCION) = UPPER(TRE.ADDRESS)
            LEFT JOIN TIPOS_PROPIEDAD  TP ON UPPER(TP.DESCRIPCION) = UPPER(TRE.TIPO_PROPIEDAD)
            LEFT JOIN TIPOS_RESIDENCIA TR ON UPPER(TR.DESCRIPCION) = UPPER(TRE.TIPO_RESIDENCIA)
        WHERE
            TRE.ADDRESS IS NOT NULL
            AND TRE.SERIAL_NUMBER IS NOT NULL
            AND TRIM(TRE.ADDRESS) != ''
            AND TRIM(TRE.SERIAL_NUMBER) != ''
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    PROPIEDADES P
                WHERE
                    P.NUMERO_SERIAL = TRE.SERIAL_NUMBER
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
    SP_REGISTRAR_CONTROL('PROPIEDADES', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Propiedades insertadas: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar propiedades: ' || SQLERRM);
        RAISE;
END SP_POBLAR_PROPIEDADES;
/

-- 9. Procedimiento para poblar tabla VENTAS
CREATE OR REPLACE PROCEDURE SP_POBLAR_VENTAS (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA DE VENTAS ===');
    INSERT INTO VENTAS (
        ID_PROPIEDAD,
        ANIO_VENTA,
        FECHA_REGISTRO,
        VALOR_VENTA,
        RELACION_VENTA,
        CODIGO_NO_USO
    )
        SELECT
            P.ID_PROPIEDAD,
            TRE.LIST_YEAR,
            TRE.DATE_RECORDED,
            TRE.SALE_AMOUNT,
            TRE.SALES_RATIO,
            TRE.NON_USE_CODE
        FROM
                 TABLA_PRUEBA TRE
            INNER JOIN PROPIEDADES P ON P.NUMERO_SERIAL = TRE.SERIAL_NUMBER
        WHERE
            TRE.SERIAL_NUMBER IS NOT NULL
            AND TRIM(TRE.SERIAL_NUMBER) != '';

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
    SP_REGISTRAR_CONTROL('VENTAS', V_FILAS_INSERTADAS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Ventas insertadas: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar ventas: ' || SQLERRM);
        RAISE;
END SP_POBLAR_VENTAS;
/

-- 10. Procedimiento para poblar tabla OBSERVACIONES
CREATE OR REPLACE PROCEDURE SP_POBLAR_OBSERVACIONES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
    V_TOTAL_OBS        NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA DE OBSERVACIONES ===');
    
    -- Insertar observaciones de asesores (ASE)
    INSERT INTO OBSERVACIONES (
        ID_VENTA,
        NOTA,
        TIPO_ORIGEN
    )
        SELECT
            V.ID_VENTA,
            TRE.ASSESSOR_REMARKS,
            'ASE'
        FROM
                 TABLA_PRUEBA TRE
            INNER JOIN PROPIEDADES P ON P.NUMERO_SERIAL = TRE.SERIAL_NUMBER
            INNER JOIN VENTAS      V ON V.ID_PROPIEDAD = P.ID_PROPIEDAD
                                   AND V.ANIO_VENTA = TRE.LIST_YEAR
                                   AND V.FECHA_REGISTRO = TRE.DATE_RECORDED
        WHERE
            TRE.ASSESSOR_REMARKS IS NOT NULL
            AND TRIM(TRE.ASSESSOR_REMARKS) != '';

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    V_TOTAL_OBS := V_FILAS_INSERTADAS;
    
    -- Insertar observaciones de OPM
    INSERT INTO OBSERVACIONES (
        ID_VENTA,
        NOTA,
        TIPO_ORIGEN
    )
        SELECT
            V.ID_VENTA,
            TRE.OPM_REMARKS,
            'OPM'
        FROM
                 TABLA_PRUEBA TRE
            INNER JOIN PROPIEDADES P ON P.NUMERO_SERIAL = TRE.SERIAL_NUMBER
            INNER JOIN VENTAS      V ON V.ID_PROPIEDAD = P.ID_PROPIEDAD
                                   AND V.ANIO_VENTA = TRE.LIST_YEAR
                                   AND V.FECHA_REGISTRO = TRE.DATE_RECORDED
        WHERE
            TRE.OPM_REMARKS IS NOT NULL
            AND TRIM(TRE.OPM_REMARKS) != '';

    V_TOTAL_OBS := V_TOTAL_OBS + SQL%ROWCOUNT;
    COMMIT;
    SP_REGISTRAR_CONTROL('OBSERVACIONES', V_TOTAL_OBS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Observaciones insertadas: ' || V_TOTAL_OBS);
    DBMS_OUTPUT.PUT_LINE('  - ASE: ' || V_FILAS_INSERTADAS);
    DBMS_OUTPUT.PUT_LINE('  - OPM: ' ||(V_TOTAL_OBS - V_FILAS_INSERTADAS));
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar observaciones: ' || SQLERRM);
        RAISE;
END SP_POBLAR_OBSERVACIONES;
/

-- 11. Procedimiento maestro para carga completa
CREATE OR REPLACE PROCEDURE SP_CARGA_COMPLETA (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_INICIO_PROCESO DATE;
    V_FIN_PROCESO    DATE;
BEGIN
    V_INICIO_PROCESO := SYSDATE;
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CARGA COMPLETA DE DATOS      ===');
    DBMS_OUTPUT.PUT_LINE('=== Fecha de carga: '
                         || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS')
                         || ' ===');
    DBMS_OUTPUT.PUT_LINE('=== Inicio real: '
                         || TO_CHAR(V_INICIO_PROCESO, 'DD/MM/YYYY HH24:MI:SS')
                         || '    ===');
    DBMS_OUTPUT.PUT_LINE('===============================================');
    
    -- Limpiar tabla de control
    DELETE FROM CONTROL_CARGA
    WHERE
        FECHA_PROCESO = P_FECHA_CARGA;

    COMMIT;
    
    -- Poblar tablas de catálogo
    DBMS_OUTPUT.PUT_LINE('1. Poblando pueblos...');
    SP_POBLAR_PUEBLOS(P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('2. Poblando tipos de propiedad...');
    SP_POBLAR_TIPOS_PROPIEDAD(P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('3. Poblando tipos de residencia...');
    SP_POBLAR_TIPOS_RESIDENCIA(P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('4. Poblando localizaciones...');
    SP_POBLAR_LOCALIZACIONES(P_FECHA_CARGA);
    
    -- Poblar tablas de datos
    DBMS_OUTPUT.PUT_LINE('5. Poblando propiedades...');
    SP_POBLAR_PROPIEDADES(P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('6. Poblando ventas...');
    SP_POBLAR_VENTAS(P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('7. Poblando observaciones...');
    SP_POBLAR_OBSERVACIONES(P_FECHA_CARGA);
    V_FIN_PROCESO := SYSDATE;
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('=== CARGA COMPLETA FINALIZADA              ===');
    DBMS_OUTPUT.PUT_LINE('=== Tiempo total: '
                         || ROUND((V_FIN_PROCESO - V_INICIO_PROCESO) * 24 * 60, 2)
                         || ' minutos ===');

    DBMS_OUTPUT.PUT_LINE('===============================================');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR EN CARGA COMPLETA: ' || SQLERRM);
        RAISE;
END SP_CARGA_COMPLETA;
/

-- 12. Procedimiento para limpiar base de datos (mantener estructura)
CREATE OR REPLACE PROCEDURE SP_LIMPIAR_BASE_DATOS (
    P_FECHA_LIMPIEZA  IN DATE DEFAULT SYSDATE,
    P_LIMPIAR_CONTROL IN BOOLEAN DEFAULT FALSE
) AS

    V_TOTAL_ELIMINADOS NUMBER := 0;
    V_FILAS_ELIMINADAS NUMBER;
    TYPE T_TABLAS IS
        TABLE OF VARCHAR2(50);
    V_TABLAS           T_TABLAS := T_TABLAS('OBSERVACIONES', 'VENTAS', 'PROPIEDADES', 'LOCALIZACIONES', 'TIPOS_RESIDENCIA',
                                  'TIPOS_PROPIEDAD', 'PUEBLOS');
    V_TABLA            VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================');
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO LIMPIEZA DE BASE DE DATOS ===');
    DBMS_OUTPUT.PUT_LINE('=== Fecha: '
                         || TO_CHAR(P_FECHA_LIMPIEZA, 'DD/MM/YYYY HH24:MI:SS')
                         || ' ===');
    DBMS_OUTPUT.PUT_LINE('=======================================');
    
    -- Deshabilitar constraints temporalmente para acelerar eliminación
    FOR I IN 1..V_TABLAS.COUNT LOOP
        V_TABLA := V_TABLAS(I);
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || V_TABLA
        INTO V_FILAS_ELIMINADAS;
        IF V_FILAS_ELIMINADAS > 0 THEN
            EXECUTE IMMEDIATE 'DELETE FROM ' || V_TABLA;
            V_FILAS_ELIMINADAS := SQL%ROWCOUNT;
            
            -- Registrar eliminación en control
            SP_REGISTRAR_CONTROL(V_TABLA, V_FILAS_ELIMINADAS, 'DELETE', P_FECHA_LIMPIEZA);
            V_TOTAL_ELIMINADOS := V_TOTAL_ELIMINADOS + V_FILAS_ELIMINADAS;
            DBMS_OUTPUT.PUT_LINE('Tabla '
                                 || V_TABLA
                                 || ': '
                                 || V_FILAS_ELIMINADAS
                                 || ' registros eliminados');

        ELSE
            DBMS_OUTPUT.PUT_LINE('Tabla '
                                 || V_TABLA
                                 || ': ya estaba vacía');
        END IF;

    END LOOP;
    
    -- Limpiar tabla temporal
    DELETE FROM TABLA_PRUEBA;

    V_FILAS_ELIMINADAS := SQL%ROWCOUNT;
    IF V_FILAS_ELIMINADAS > 0 THEN
        SP_REGISTRAR_CONTROL('TABLA_PRUEBA', V_FILAS_ELIMINADAS, 'DELETE', P_FECHA_LIMPIEZA);
        DBMS_OUTPUT.PUT_LINE('Tabla TABLA_PRUEBA: '
                             || V_FILAS_ELIMINADAS
                             || ' registros eliminados');
    END IF;
    
    -- Limpiar tabla de control si se solicita
    IF P_LIMPIAR_CONTROL THEN
        DELETE FROM CONTROL_CARGA;

        V_FILAS_ELIMINADAS := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('Tabla CONTROL_CARGA: '
                             || V_FILAS_ELIMINADAS
                             || ' registros eliminados');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('=======================================');
    DBMS_OUTPUT.PUT_LINE('=== LIMPIEZA COMPLETADA              ===');
    DBMS_OUTPUT.PUT_LINE('=== Total registros eliminados: '
                         || V_TOTAL_ELIMINADOS
                         || ' ===');
    DBMS_OUTPUT.PUT_LINE('=== Base de datos lista para nueva carga ===');
    DBMS_OUTPUT.PUT_LINE('=======================================');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR EN LIMPIEZA: ' || SQLERRM);
        RAISE;
END SP_LIMPIAR_BASE_DATOS;
/

-- 13. Procedimiento para mostrar estadísticas y control
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