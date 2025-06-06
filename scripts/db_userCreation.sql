--Archivo de creación de usuario de BD ventas de inmuebles
--Fecha de creación: 18/05/2025
--Creado por: Natalia Bernal & Mileth Martinez
--Modificado por:
--Fecha de modificación:
--Observación:

/*
Dataset utilizado: Real Estate Sales 2001–2022
Fuente: https://www.kaggle.com/datasets/omniamahmoudsaeed/real-estate-sales-2001-2022
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
    INSERT ANY TABLE,
    CREATE PROCEDURE,
    CREATE TRIGGER
TO USER_PRUEBA;

-- Asignar cuota de espacio
ALTER USER USER_PRUEBA
    QUOTA UNLIMITED ON DATOS_VENTAS;

ALTER USER USER_PRUEBA
    QUOTA UNLIMITED ON TS_INDICES_VENTAS;