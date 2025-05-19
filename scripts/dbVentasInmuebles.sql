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
    DEFAULT TABLESPACE DATOS_PELICULAS
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