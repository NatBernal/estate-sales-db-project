--Archivo de creación de triggers de BD ventas de inmuebles
--Fecha de creación: 18/05/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:


-- Crear tablas necesarias para la auditoría de cambios
CREATE TABLE AUDITORIA_CAMBIOS (
    ID_AUDITORIA       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    USUARIO_BD         VARCHAR2(50),
    MAQUINA            VARCHAR2(100),
    FECHA_HORA         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TIPO_OPERACION     VARCHAR2(10),
    NOMBRE_TABLA       VARCHAR2(50),
    VALOR_ANTERIOR     CLOB,
    VALOR_NUEVO        CLOB
)
TABLESPACE DATOS_VENTAS;


-- Crear disparadores para auditoría de cambios en las tablas de ventas inmobiliarias

-- Disparador para auditar cambios en la tabla ventas
-- Este disparador registra actualizaciones y eliminaciones en la tabla ventas.
CREATE OR REPLACE TRIGGER trg_aud_ventas
AFTER UPDATE OR DELETE ON ventas
FOR EACH ROW
DECLARE
    v_user     VARCHAR2(50);
    v_host     VARCHAR2(100);
    v_op       VARCHAR2(10);
    v_val_ant  CLOB;
    v_val_new  CLOB;
BEGIN
    -- Determinar tipo de operación
    IF DELETING THEN
        v_op := 'DELETE';
    ELSIF UPDATING THEN
        v_op := 'UPDATE';
    END IF;

    -- Obtener usuario y máquina
    SELECT
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST')
    INTO v_user, v_host
    FROM DUAL;

    -- Armar valor anterior
    v_val_ant := 'ID=' || :OLD.id_venta ||
                 ', PROPIEDAD=' || :OLD.id_propiedad ||
                 ', AÑO=' || :OLD.anio_venta ||
                 ', VALOR=' || :OLD.valor_venta ||
                 ', FECHA=' || TO_CHAR(:OLD.fecha_registro, 'YYYY-MM-DD');

    -- Armar valor nuevo solo si es UPDATE
    IF UPDATING THEN
        v_val_new := 'ID=' || :NEW.id_venta ||
                     ', PROPIEDAD=' || :NEW.id_propiedad ||
                     ', AÑO=' || :NEW.anio_venta ||
                     ', VALOR=' || :NEW.valor_venta ||
                     ', FECHA=' || TO_CHAR(:NEW.fecha_registro, 'YYYY-MM-DD');
    ELSE
        v_val_new := NULL;
    END IF;

    -- Insertar registro de auditoría
    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        v_user, v_host, v_op, 'VENTAS', v_val_ant, v_val_new
    );
END;

-- Disparador para auditar cambios en la tabla propiedades
-- Este disparador registra actualizaciones y eliminaciones en la tabla propiedades.
CREATE OR REPLACE TRIGGER trg_aud_propiedades
AFTER UPDATE OR DELETE ON propiedades
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_host VARCHAR2(100);
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER'), SYS_CONTEXT('USERENV', 'HOST')
    INTO v_user, v_host
    FROM DUAL;

    v_ant := 'ID=' || :OLD.id_propiedad || ', SERIAL=' || :OLD.numero_serial || ', VALOR=' || :OLD.valor_catastral;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_propiedad || ', SERIAL=' || :NEW.numero_serial || ', VALOR=' || :NEW.valor_catastral;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        v_user, v_host, v_op, 'PROPIEDADES', v_ant, v_nuev
    );
END;

-- Disparador para auditar cambios en la tabla observaciones
-- Este disparador registra actualizaciones y eliminaciones en la tabla observaciones.  
CREATE OR REPLACE TRIGGER trg_aud_observaciones
AFTER UPDATE OR DELETE ON observaciones
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_host VARCHAR2(100);
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER'), SYS_CONTEXT('USERENV', 'HOST')
    INTO v_user, v_host
    FROM DUAL;

    v_ant := 'ID=' || :OLD.id_observacion || ', NOTA=' || :OLD.nota;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_observacion || ', NOTA=' || :NEW.nota;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        v_user, v_host, v_op, 'OBSERVACIONES', v_ant, v_nuev
    );
END;

-- Disparador para auditar cambios en la tabla localizaciones
-- Este disparador registra actualizaciones y eliminaciones en la tabla localizaciones.
CREATE OR REPLACE TRIGGER trg_aud_localizaciones
AFTER UPDATE OR DELETE ON localizaciones
FOR EACH ROW
DECLARE
    v_user VARCHAR2(50);
    v_host VARCHAR2(100);
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER'), SYS_CONTEXT('USERENV', 'HOST')
    INTO v_user, v_host
    FROM DUAL;

    v_ant := 'ID=' || :OLD.id_localizacion || ', DIR=' || :OLD.direccion;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_localizacion || ', DIR=' || :NEW.direccion;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        v_user, v_host, v_op, 'LOCALIZACIONES', v_ant, v_nuev
    );
END;

-- Disparador para auditar cambios en la tabla pueblos
-- Este disparador registra actualizaciones y eliminaciones en la tabla pueblos.
CREATE OR REPLACE TRIGGER trg_audit_pueblos
BEFORE UPDATE OR DELETE ON pueblos
FOR EACH ROW
DECLARE
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    v_ant := 'ID=' || :OLD.id_pueblo || ', NOMBRE=' || :OLD.nombre;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_pueblo || ', NOMBRE=' || :NEW.nombre;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST'),
        v_op, 'PUEBLOS', v_ant, v_nuev
    );
END;

CREATE OR REPLACE TRIGGER trg_audit_tipos_propiedad
BEFORE UPDATE OR DELETE ON tipos_propiedad
FOR EACH ROW
DECLARE
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    v_ant := 'ID=' || :OLD.id_tipo_propiedad || ', DESC=' || :OLD.descripcion;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_tipo_propiedad || ', DESC=' || :NEW.descripcion;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST'),
        v_op, 'TIPOS_PROPIEDAD', v_ant, v_nuev
    );
END;

-- Disparador para auditar cambios en la tabla tipos_residencia
-- Este disparador registra actualizaciones y eliminaciones en la tabla tipos_residencia.
CREATE OR REPLACE TRIGGER trg_audit_tipos_residencia
BEFORE UPDATE OR DELETE ON tipos_residencia
FOR EACH ROW
DECLARE
    v_op   VARCHAR2(10);
    v_ant  CLOB;
    v_nuev CLOB;
BEGIN
    IF DELETING THEN
        v_op := 'DELETE';
    ELSE
        v_op := 'UPDATE';
    END IF;

    v_ant := 'ID=' || :OLD.id_tipo_residencia || ', DESC=' || :OLD.descripcion;

    IF UPDATING THEN
        v_nuev := 'ID=' || :NEW.id_tipo_residencia || ', DESC=' || :NEW.descripcion;
    END IF;

    INSERT INTO auditoria_cambios (
        usuario_bd, maquina, tipo_operacion, nombre_tabla,
        valor_anterior, valor_nuevo
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST'),
        v_op, 'TIPOS_RESIDENCIA', v_ant, v_nuev
    );
END;