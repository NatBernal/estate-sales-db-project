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
            UPPER(TRIM(T.PUEBLO))
        FROM
            TABLA_PRUEBA T
        WHERE
            T.PUEBLO IS NOT NULL
            AND LENGTH(TRIM(T.PUEBLO)) > 0
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    PUEBLOS P
                WHERE
                    UPPER(P.NOMBRE) = UPPER(T.PUEBLO)
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
    COMMIT;
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
            AND LENGTH(TRIM(TIPO_PROPIEDAD)) > 0
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

-- Procedimiento para poblar tabla TIPOS_RESIDENCIA
CREATE OR REPLACE PROCEDURE SP_POBLAR_TIPOS_RESIDENCIA (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO TIPOS_RESIDENCIA ( DESCRIPCION )
        SELECT DISTINCT
            TIPO_RESIDENCIA
        FROM
            TABLA_PRUEBA
        WHERE
            TIPO_RESIDENCIA IS NOT NULL
            AND LENGTH(TRIM(TIPO_RESIDENCIA)) > 0
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

-- Funcion para extraer latitud y longitud de un campo LOCATION
CREATE OR REPLACE FUNCTION EXTRACT_COORDINATES (
    P_LOCATION   IN VARCHAR2,
    P_RETURN_LAT IN CHAR
) RETURN NUMBER IS
    V_LONGITUD VARCHAR2(50);
    V_LATITUD  VARCHAR2(50);
BEGIN
    IF P_LOCATION IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Extraer ambas coordenadas en una sola pasada
    V_LONGITUD := REGEXP_SUBSTR(P_LOCATION, 'POINT\s*\(([-0-9.]+)\s+([-0-9.]+)\)', 1, 1, 'i',
                                1);
    V_LATITUD := REGEXP_SUBSTR(P_LOCATION, 'POINT\s*\(([-0-9.]+)\s+([-0-9.]+)\)', 1, 1, 'i',
                               2);
    
    -- Devolver según el parámetro solicitado
    IF P_RETURN_LAT = '1' THEN
        RETURN TO_NUMBER ( V_LATITUD, '999.999999999', 'NLS_NUMERIC_CHARACTERS=''.,''' );
    ELSE
        RETURN TO_NUMBER ( V_LONGITUD, '999.999999999', 'NLS_NUMERIC_CHARACTERS=''.,''' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END EXTRACT_COORDINATES;
/

--  Procedimiento para poblar tabla LOCALIZACIONES
CREATE OR REPLACE PROCEDURE SP_POBLAR_LOCALIZACIONES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO LOCALIZACIONES (
        ID_PUEBLO,
        LATITUD,
        LONGITUD,
        DIRECCION
    )
        SELECT
            P.ID_PUEBLO,
            EXTRACT_COORDINATES(T.COORDENADAS, 1),  -- 1 para TRUE (latitud)
            EXTRACT_COORDINATES(T.COORDENADAS, 0),  -- 0 para FALSE (longitud)
            TRIM(UPPER(T.DIRECCION))
        FROM
                 TABLA_PRUEBA T
            JOIN PUEBLOS P ON TRIM(UPPER(P.NOMBRE)) = TRIM(UPPER(T.PUEBLO))
        WHERE
            ( T.DIRECCION IS NOT NULL
              AND LENGTH(TRIM(T.DIRECCION)) > 0 )
            OR T.COORDENADAS IS NOT NULL
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    LOCALIZACIONES L
                WHERE
                        TRIM(UPPER(L.DIRECCION)) = TRIM(UPPER(T.DIRECCION))
                    AND L.ID_PUEBLO = P.ID_PUEBLO
            );

    V_FILAS_INSERTADAS := SQL%ROWCOUNT;
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

-- Procedimiento para poblar tabla PROPIEDADES
CREATE OR REPLACE PROCEDURE SP_POBLAR_PROPIEDADES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO PROPIEDADES (
        NUMERO_SERIAL,
        ID_TIPO_PROPIEDAD,
        ID_TIPO_RESIDENCIA,
        ID_LOCALIZACION,
        VALOR_CATASTRAL
    )
        SELECT
            T.NUMERO_SERIAL,
            TP.ID_TIPO_PROPIEDAD,
            TR.ID_TIPO_RESIDENCIA,
            L.ID_LOCALIZACION,
            T.VALOR_CATASTRAL
        FROM
                 TABLA_PRUEBA T
            JOIN PUEBLOS          PU ON TRIM(UPPER(PU.NOMBRE)) = TRIM(UPPER(T.PUEBLO))
            JOIN (
                SELECT
                    ID_LOCALIZACION,
                    DIRECCION,
                    ID_PUEBLO
                FROM
                    (
                        SELECT
                            ID_LOCALIZACION,
                            DIRECCION,
                            ID_PUEBLO,
                            ROW_NUMBER()
                            OVER(PARTITION BY TRIM(UPPER(DIRECCION)),
                                       ID_PUEBLO
                                 ORDER BY
                                     ID_LOCALIZACION
                            ) AS RN
                        FROM
                            LOCALIZACIONES
                    )
                WHERE
                    RN = 1
            )                L ON TRIM(UPPER(L.DIRECCION)) = TRIM(UPPER(T.DIRECCION))
                   AND L.ID_PUEBLO = PU.ID_PUEBLO
            LEFT JOIN TIPOS_PROPIEDAD  TP ON UPPER(TP.DESCRIPCION) = UPPER(T.TIPO_PROPIEDAD)
            LEFT JOIN TIPOS_RESIDENCIA TR ON UPPER(TR.DESCRIPCION) = UPPER(T.TIPO_RESIDENCIA)
        WHERE
            T.NUMERO_SERIAL IS NOT NULL
            AND LENGTH(TRIM(T.NUMERO_SERIAL)) > 0
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    PROPIEDADES P
                WHERE
                        P.NUMERO_SERIAL = T.NUMERO_SERIAL
                    AND P.ID_LOCALIZACION = L.ID_LOCALIZACION
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

-- Procedimiento para poblar la tabla VENTAS
CREATE OR REPLACE PROCEDURE SP_POBLAR_VENTAS (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_INSERTADAS NUMBER := 0;
BEGIN
    INSERT INTO VENTAS (
        ID_PROPIEDAD,
        ANIO_VENTA,
        FECHA_REGISTRO,
        VALOR_VENTA,
        RELACION_VENTA,
        CODIGO_NO_USO
    )
        WITH PROPIEDADES_POR_PUEBLO AS (
            SELECT
                P.ID_PROPIEDAD,
                P.NUMERO_SERIAL,
                PU.NOMBRE AS PUEBLO,
                ROW_NUMBER()
                OVER(PARTITION BY P.NUMERO_SERIAL, PU.NOMBRE
                     ORDER BY
                         P.ID_PROPIEDAD DESC
                )         AS RN_PROP
            FROM
                     PROPIEDADES P
                JOIN LOCALIZACIONES L ON P.ID_LOCALIZACION = L.ID_LOCALIZACION
                JOIN PUEBLOS        PU ON L.ID_PUEBLO = PU.ID_PUEBLO
            WHERE
                P.NUMERO_SERIAL IS NOT NULL
        ), PRUEBA_UNICA AS (
            SELECT
                NUMERO_SERIAL,
                PUEBLO,
                ANIO_VENTA,
                FECHA_REGISTRO,
                VALOR_VENTA,
                RELACION_VENTA,
                COD_NO_USO,
                ROW_NUMBER()
                OVER(PARTITION BY NUMERO_SERIAL, PUEBLO
                     ORDER BY
                         FECHA_REGISTRO DESC, ANIO_VENTA DESC
                ) AS RN_PRUEBA
            FROM
                TABLA_PRUEBA
            WHERE
                NUMERO_SERIAL IS NOT NULL
                AND PUEBLO IS NOT NULL
                AND LENGTH(TRIM(NUMERO_SERIAL)) > 0
                AND LENGTH(TRIM(PUEBLO)) > 0
        )
        SELECT
            PPP.ID_PROPIEDAD,
            PU.ANIO_VENTA,
            PU.FECHA_REGISTRO,
            PU.VALOR_VENTA,
            CASE
                WHEN REGEXP_LIKE ( TRIM(PU.RELACION_VENTA),
                                   '^-?[0-9]+\.?[0-9]*$' ) THEN
                    TO_NUMBER(REPLACE(
                        TRIM(PU.RELACION_VENTA),
                        '.',
                        ','
                    ))
                ELSE
                    ROUND(TO_NUMBER(REPLACE(PU.RELACION_VENTA, '.', '')) / 1000000000,
                          3)
            END,
            PU.COD_NO_USO
        FROM
                 PRUEBA_UNICA PU
            JOIN PROPIEDADES_POR_PUEBLO PPP ON PPP.NUMERO_SERIAL = PU.NUMERO_SERIAL
                                                     AND UPPER(PPP.PUEBLO) = UPPER(PU.PUEBLO)
        WHERE
                PPP.RN_PROP = 1
            AND PU.RN_PRUEBA = 1;

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
-- Procedimiento para poblar la tabla OBSERVACIONES
CREATE OR REPLACE PROCEDURE SP_POBLAR_OBSERVACIONES (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
    V_FILAS_ASE NUMBER := 0;
    V_FILAS_OPM NUMBER := 0;
    V_TOTAL_OBS NUMBER := 0;
BEGIN

    -- ASE
    INSERT INTO OBSERVACIONES (
        ID_VENTA,
        NOTA,
        TIPO_ORIGEN
    )
        SELECT DISTINCT
            V.ID_VENTA,
            T.OB_ASESOR,
            'ASE'
        FROM
                 TABLA_PRUEBA T
            JOIN PUEBLOS        PU ON UPPER(PU.NOMBRE) = UPPER(T.PUEBLO)
            JOIN LOCALIZACIONES L ON UPPER(L.DIRECCION) = UPPER(T.DIRECCION)
                                           AND L.ID_PUEBLO = PU.ID_PUEBLO
            JOIN PROPIEDADES    P ON P.NUMERO_SERIAL = T.NUMERO_SERIAL
                                        AND P.ID_LOCALIZACION = L.ID_LOCALIZACION
            JOIN VENTAS         V ON V.ID_PROPIEDAD = P.ID_PROPIEDAD
                                   AND V.ANIO_VENTA = T.ANIO_VENTA
                                   AND V.FECHA_REGISTRO = T.FECHA_REGISTRO
        WHERE
            T.OB_ASESOR IS NOT NULL
            AND LENGTH(TRIM(T.OB_ASESOR)) > 0;

    V_FILAS_ASE := SQL%ROWCOUNT;

    -- OPM
    INSERT INTO OBSERVACIONES (
        ID_VENTA,
        NOTA,
        TIPO_ORIGEN
    )
        SELECT DISTINCT
            V.ID_VENTA,
            T.OB_OPM,
            'OPM'
        FROM
                 TABLA_PRUEBA T
            JOIN PUEBLOS        PU ON UPPER(PU.NOMBRE) = UPPER(T.PUEBLO)
            JOIN LOCALIZACIONES L ON UPPER(L.DIRECCION) = UPPER(T.DIRECCION)
                                           AND L.ID_PUEBLO = PU.ID_PUEBLO
            JOIN PROPIEDADES    P ON P.NUMERO_SERIAL = T.NUMERO_SERIAL
                                        AND P.ID_LOCALIZACION = L.ID_LOCALIZACION
            JOIN VENTAS         V ON V.ID_PROPIEDAD = P.ID_PROPIEDAD
                                   AND V.ANIO_VENTA = T.ANIO_VENTA
                                   AND V.FECHA_REGISTRO = T.FECHA_REGISTRO
        WHERE
            T.OB_OPM IS NOT NULL
            AND LENGTH(TRIM(T.OB_OPM)) > 0;

    V_FILAS_OPM := SQL%ROWCOUNT;
    V_TOTAL_OBS := V_FILAS_ASE + V_FILAS_OPM;
    COMMIT;
    SP_REGISTRAR_CONTROL('OBSERVACIONES', V_TOTAL_OBS, 'INSERT', P_FECHA_CARGA);
    DBMS_OUTPUT.PUT_LINE('Observaciones insertadas: ' || V_TOTAL_OBS);
    DBMS_OUTPUT.PUT_LINE('  - ASE: ' || V_FILAS_ASE);
    DBMS_OUTPUT.PUT_LINE('  - OPM: ' || V_FILAS_OPM);
    DBMS_OUTPUT.PUT_LINE('Fecha de proceso: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al poblar observaciones: ' || SQLERRM);
        RAISE;
END SP_POBLAR_OBSERVACIONES;
/

-- Procedimiento para limpiar base de datos
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

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Limpieza finalizada');
    DBMS_OUTPUT.PUT_LINE('Total registros eliminados: ' || V_TOTAL_ELIMINADOS);
    DBMS_OUTPUT.PUT_LINE('Base de datos lista para nueva carga');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR EN LIMPIEZA: ' || SQLERRM);
        RAISE;
END SP_LIMPIAR_BASE_DATOS;
/

-- Funcion para validar la fecha de carga
CREATE OR REPLACE FUNCTION FN_VALIDAR_FECHA_CARGA (
    P_FECHA_CARGA IN DATE
) RETURN BOOLEAN IS
    v_dia_semana NUMBER;
    v_hora NUMBER;
    v_diferencia_dias NUMBER;
    C_FECHA_NULA CONSTANT NUMBER := -20001;
    C_DIA_NO_HABIL CONSTANT NUMBER := -20002;
    C_HORARIO_LABORAL CONSTANT NUMBER := -20003;
    C_FECHA_ANTERIOR CONSTANT NUMBER := -20004;
    C_FECHA_POSTERIOR CONSTANT NUMBER := -20005;
BEGIN
    IF P_FECHA_CARGA IS NULL THEN
        RAISE_APPLICATION_ERROR(C_FECHA_NULA,'La fecha de carga no puede ser NULL.');
    END IF;
    
    v_dia_semana := TO_NUMBER(TO_CHAR(P_FECHA_CARGA, 'D'));
    
    IF v_dia_semana < 2 OR v_dia_semana > 6 THEN
        RAISE_APPLICATION_ERROR(C_DIA_NO_HABIL, 
            'La fecha debe ser un día hábil (lunes a viernes). ' ||
            'Día proporcionado: ' || TO_CHAR(P_FECHA_CARGA, 'DAY, DD/MM/YYYY'));
    END IF;

    v_hora := TO_NUMBER(TO_CHAR(P_FECHA_CARGA, 'HH24'));
    IF v_hora < 8 OR v_hora >= 18 THEN
        RAISE_APPLICATION_ERROR(C_HORARIO_LABORAL, 
            'La fecha debe estar dentro del horario laboral (08:00 - 17:59). ' ||
            'Hora proporcionada: ' || TO_CHAR(P_FECHA_CARGA, 'HH24:MI:SS'));
    END IF;
    

    v_diferencia_dias := TRUNC(P_FECHA_CARGA) - TRUNC(SYSDATE);
    
    IF v_diferencia_dias < -3 THEN
        RAISE_APPLICATION_ERROR(C_FECHA_ANTERIOR, 
            'No se permiten fechas de más de 3 días en el pasado. ' ||
            'Fecha proporcionada: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS') ||
            ', Fecha mínima permitida: ' || TO_CHAR(SYSDATE - 3, 'DD/MM/YYYY HH24:MI:SS') ||
            ', Fecha actual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    END IF;
    
    IF v_diferencia_dias > 3 THEN
        RAISE_APPLICATION_ERROR(C_FECHA_POSTERIOR, 
            'No se permiten fechas con más de 3 días de antelación. ' ||
            'Fecha proporcionada: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS') ||
            ', Fecha máxima permitida: ' || TO_CHAR(SYSDATE + 3, 'DD/MM/YYYY HH24:MI:SS') ||
            ', Fecha actual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    END IF;
    
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END FN_VALIDAR_FECHA_CARGA;
/

-- Procedimiento para poblar todas las tablas
CREATE OR REPLACE PROCEDURE SP_POBLAR_TODO (
    P_FECHA_CARGA IN DATE DEFAULT SYSDATE
) AS
BEGIN

    IF FN_VALIDAR_FECHA_CARGA(P_FECHA_CARGA) THEN
        SP_POBLAR_PUEBLOS(P_FECHA_CARGA);
        SP_POBLAR_TIPOS_PROPIEDAD(P_FECHA_CARGA);
        SP_POBLAR_TIPOS_RESIDENCIA(P_FECHA_CARGA);
        SP_POBLAR_LOCALIZACIONES(P_FECHA_CARGA);
        SP_POBLAR_PROPIEDADES(P_FECHA_CARGA);
        SP_POBLAR_VENTAS(P_FECHA_CARGA);
        SP_POBLAR_OBSERVACIONES(P_FECHA_CARGA);
    END IF;

    DBMS_OUTPUT.PUT_LINE('Poblado completo realizado con fecha: ' || TO_CHAR(P_FECHA_CARGA, 'DD/MM/YYYY HH24:MI:SS'));

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en SP_POBLAR_TODO: ' || SQLERRM);
        RAISE;
END SP_POBLAR_TODO; 
/