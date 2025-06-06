--Archivo de creación de tabla temporal
--Fecha de creación: 01/06/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

-- EJECUTAR COMO USUARIO USER_PRUEBA

-- Crear tabla temporal
CREATE TABLE TABLA_PRUEBA (
    NUMERO_SERIAL    NUMBER(38),
    ANIO_VENTA      NUMBER(38),
    FECHA_REGISTRO  DATE,
    PUEBLO          VARCHAR2(26),
    DIRECCION       VARCHAR2(128),
    VALOR_CATASTRAL FLOAT,
    VALOR_VENTA     FLOAT,
    RELACION_VENTA  VARCHAR2(26),
    TIPO_PROPIEDAD  VARCHAR2(26),
    TIPO_RESIDENCIA VARCHAR2(26),
    COD_NO_USO      VARCHAR2(50),
    OB_ASESOR       VARCHAR2(128),
    OB_OPM          VARCHAR2(128),
    COORDENADAS     VARCHAR2(128)
)
TABLESPACE DATOS_VENTAS;


-- Es necesario importar los datos desde el archivo CSV
-- para poder llenar la tabla temporal