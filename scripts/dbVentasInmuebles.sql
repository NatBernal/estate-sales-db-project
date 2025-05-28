--Archivo de creación de BD ventas de inmuebles
--echa de creación: 18/03/2025
-- Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

/*
Dataset usado: Real Estate Sales 2001-2022
Link: https://www.kaggle.com/datasets/omniamahmoudsaeed/real-estate-sales-2001-2022
*/

-- EJECUTAR COMO USUARIO SYSTEM

-- Crear tablespaces para las tablas la BD de venta de inmuebles
CREATE TABLESPACE DATOS_VENTAS
    DATAFILE '/datos_ventas.dbf' SIZE 10M
    AUTOEXTEND ON NEXT 10M MAXSIZE 50M;

-- Crear tablespaces para los indices la BD de venta de inmuebles
CREATE TABLESPACE TS_INDICES_VENTAS
    DATAFILE '/indices_ventas.dbf' SIZE 10M
    AUTOEXTEND ON NEXT 10M MAXSIZE 50M;

-- Crear usuario de prueba para la BD de venta de inmuebles
CREATE USER USER_PRUEBA
    DEFAULT TABLESPACE DATOS_VENTAS
    TEMPORARY TABLESPACE TEMP
    PROFILE DEFAULT
IDENTIFIED BY ABC987;
 
-- Asignar permisos al usuario de prueba
GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE SEQUENCE,
    INSERT ANY TABLE
TO USER_PRUEBA;

ALTER USER USER_PRUEBA
    QUOTA UNLIMITED ON DATOS_VENTAS;

ALTER USER USER_PRUEBA
    QUOTA UNLIMITED ON TS_INDICES_VENTAS;

-- Conectar como USER_PRUEBA
CONN USER_PRUEBA/abc987;

-- Crear secuencia para el id de pueblo
CREATE SEQUENCE SEQ_PUEBLO_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de pueblos
CREATE TABLE PUEBLOS(
    id_pueblo NUMBER DEFAULT SEQ_PUEBLO_ID.NEXTVAL,
    nombre VARCHAR2(70)
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla pueblos
COMMENT ON TABLE PUEBLOS IS 'Pueblos de Estados Unidos';
COMMENT ON COLUMN PUEBLOS.id_pueblo IS 'Identificador de pueblo';
COMMENT ON COLUMN PUEBLOS.nombre IS 'Nombre del pueblo';

-- Crear secuencia para el id de tipo de propiedad
CREATE SEQUENCE SEQ_TIPO_PROPIEDAD_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de tipos de propiedad
CREATE TABLE TIPOS_PROPIEDAD(
    id_tipo_propiedad NUMBER DEFAULT SEQ_TIPO_PROPIEDAD_ID.NEXTVAL,
    descripcion VARCHAR2(50)
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla tipos de propiedad
COMMENT ON TABLE TIPOS_PROPIEDAD IS 'Tipos de propiedad';
COMMENT ON COLUMN TIPOS_PROPIEDAD.id_tipo_propiedad IS 'Identificador de tipo de propiedad';
COMMENT ON COLUMN TIPOS_PROPIEDAD.descripcion IS 'Descripcion del tipo de propiedad';


-- Crear secuencia para el id de tipo de residencia
CREATE SEQUENCE SEQ_TIPO_RESIDENCIA_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de tipos de residencia
CREATE TABLE TIPOS_RESIDENCIA(
    id_tipo_residencia NUMBER DEFAULT SEQ_TIPO_RESIDENCIA_ID.NEXTVAL,
    descripcion VARCHAR2(50)
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla tipos de residencia
COMMENT ON TABLE TIPOS_RESIDENCIA IS 'Tipos de residencia';
COMMENT ON COLUMN TIPOS_RESIDENCIA.id_tipo_residencia IS 'Identificador de tipo de residencia';
COMMENT ON COLUMN TIPOS_RESIDENCIA.descripcion IS 'Descripcion del tipo de residencia';

-- Crear secuencia para el id de localizacion
CREATE SEQUENCE SEQ_LOCALIZACIONES_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de ubicaciones
CREATE TABLE LOCALIZACIONES(
    id_localizacion NUMBER DEFAULT SEQ_LOCALIZACIONES_ID.NEXTVAL,
    id_pueblo NUMBER NOT NULL,
    latitud NUMBER,
    longitud NUMBER,
    direccion VARCHAR2(100)
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla localizaciones
COMMENT ON TABLE LOCALIZACIONES IS 'Ubicaciones de las propiedades';
COMMENT ON COLUMN LOCALIZACIONES.id_ubicacion IS 'Identificador de ubicacion';
COMMENT ON COLUMN LOCALIZACIONES.id_pueblo IS 'Identificador de pueblo';
COMMENT ON COLUMN LOCALIZACIONES.latitud IS 'Latitud de la ubicacion';
COMMENT ON COLUMN LOCALIZACIONES.longitud IS 'Longitud de la ubicacion';
COMMENT ON COLUMN LOCALIZACIONES.direccion IS 'Direccion de la propiedad';

-- Crear secuencia para el id de observaciones
CREATE SEQUENCE SEQ_OBSERVACIONES_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de observaciones
CREATE TABLE OBSERVACIONES(
    id_observacion NUMBER DEFAULT SEQ_OBSERVACIONES_ID.NEXTVAL,
    id_venta NUMBER NOT NULL,
    nota VARCHAR2(100) NOT NULL,
    tipo_origen CHAR(3) NOT NULL
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla observaciones
COMMENT ON TABLE OBSERVACIONES IS 'Observaciones de las propiedades p';
COMMENT ON COLUMN OBSERVACIONES.id_observacion IS 'Identificador de observacion';
COMMENT ON COLUMN OBSERVACIONES.id_venta IS 'Identificador de la venta';
COMMENT ON COLUMN OBSERVACIONES.nota IS 'Nota de la observacion';
COMMENT ON COLUMN OBSERVACIONES.tipo_origen IS 'Tipo de origen de la observacion(ASE = Asesor de Ventas, OPM = Office of Policy and Management)';

-- Crear secuencia para el id de ventas
CREATE SEQUENCE SEQ_VENTAS_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

CREATE TABLE VENTAS (
    id_venta NUMBER DEFAULT SEQ_VENTAS_ID.NEXTVAL,
    numero_serial VARCHAR2(50) NOT NULL,
    id_propiedad NUMBER NOT NULL,
    anio_vanta NUMBER NOT NULL,
    fecha_registro DATE NOT NULL,
    valor_venta FLOAT,
    relacion_venta FLOAT,
    codigo_no_uso VARCHAR2(20)
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla ventas
COMMENT ON TABLE VENTAS IS 'Ventas de propiedades';
COMMENT ON COLUMN VENTAS.id_venta IS 'Identificador de venta';
COMMENT ON COLUMN VENTAS.numero_serial IS 'Numero serial de la venta';
COMMENT ON COLUMN VENTAS.id_propiedad IS 'Identificador de propiedad';
COMMENT ON COLUMN VENTAS.anio_vanta IS 'Año de la venta';
COMMENT ON COLUMN VENTAS.fecha_registro IS 'Fecha de registro de la venta';
COMMENT ON COLUMN VENTAS.valor_venta IS 'Valor de la venta';
COMMENT ON COLUMN VENTAS.relacion_venta IS 'Relacion de la venta';
COMMENT ON COLUMN VENTAS.codigo_no_uso IS 'Codigo de no uso de la venta';

-- Crear secuencia para el id de propiedades
CREATE SEQUENCE SEQ_PROPIEDAD_ID
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

-- Crear tabla de propiedades
CREATE TABLE PROPIEDAD(
    id_propiedad NUMBER DEFAULT SEQ_PROPIEDAD_ID.NEXTVAL,
    id_tipo_propiedad NUMBER ,
    id_tipo_residencia NUMBER,
    id_localizacion NUMBER,
    valor_catastral FLOAT
) TABLESPACE DATOS_VENTAS;

-- Comentarios de la tabla propiedades
COMMENT ON TABLE PROPIEDAD IS 'Propiedades';
COMMENT ON COLUMN PROPIEDAD.id_propiedad IS 'Identificador de propiedad';
COMMENT ON COLUMN PROPIEDAD.id_localizacion IS 'Identificador de localizacion';
COMMENT ON COLUMN PROPIEDAD.id_tipo_propiedad IS 'Identificador de tipo de propiedad';
COMMENT ON COLUMN PROPIEDAD.id_tipo_residencia IS 'Identificador de tipo de residencia';
COMMENT ON COLUMN PROPIEDAD.id_venta IS 'Identificador de venta';