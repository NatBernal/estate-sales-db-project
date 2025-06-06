# Proyecto Base de Datos: Ventas de Inmuebles

**Creado por:** Natalia Bernal & Mileth Martinez  
**Fecha de creación:** Junio 2025  
**Fuente de datos:** [Real Estate Sales 2001–2022 - Kaggle](https://www.kaggle.com/datasets/omniamahmoudsaeed/real-estate-sales-2001-2022)

## Descripción General

Este proyecto implementa una base de datos para la gestión y análisis de ventas de propiedades inmobiliarias. Incluye:

- Creación de tablas, secuencias, vistas y triggers.
- Procedimientos almacenados para poblar la base de datos desde una tabla temporal.
- Registro de auditoría para operaciones sensibles.
- Generación automática de reportes anuales.
- Creación dinámica de una vista pivote con los años generados en el reporte.

## Requisitos Previos

- Oracle Database 19c o superior.
- SQL Developer, SQL\*Plus u otra herramienta compatible con PL/SQL.

## Configuración Inicial

### 1. Crear el usuario y los tablespaces

**Archivo:** `db_userCreation.sql`  
--Ejecutar como usuario SYS o SYSTEM\_

-- Crea:
-- Tablespace DATOS_VENTAS y TS_INDICES_VENTAS
-- Usuario USER_PRUEBA con permisos para crear objetos

## 2. Crear tablas principales

## Archivo: db_creation.sql

--Ejecutar como USER_PRUEBA

-- Define las tablas del modelo relacional:
-- PUEBLOS, PROPIEDADES, VENTAS, LOCALIZACIONES, OBSERVACIONES, etc.
-- Incluye secuencias, restricciones y relaciones.

## 3. Crear tabla temporal para carga desde CSV

## Archivo: db_temporal_table.sql

-- Crea la tabla TABLA_PRUEBA.
-- Esta tabla debe ser llenada manualmente desde un archivo CSV con los datos originales.

## 4. Crear procedimientos de carga

## Archivo: db_populate_tables.sql

## Alternativa estructurada: db_pkg_ventas.sql

--Incluye:
--Procedimientos: SP_POBLAR_PUEBLOS, SP_POBLAR_PROPIEDADES, SP_POBLAR_TODO, etc.
--Procedimiento de limpieza: SP_LIMPIAR_BASE_DATOS
--Validación de fecha: FN_VALIDAR_FECHA_CARGA(fecha)

## 5. Crear lógica del reporte

## Archivo: db_reporte.sql

## Alternativa modular: db_pkg_resportes.sql

--Contiene:
--Tabla REPORTE_VENTAS_ANIO
--Procedimiento: SP_GENERAR_REPORTE(p_fecha_inicio, p_fecha_fin)
--Al ejecutarse, genera automáticamente la vista: VW_REPORTE_VENTAS_PIVOTE mediante SP_GENERAR_VISTA_PIVOTE_VENTAS

## 6. Crear triggers de auditoría

## Archivo: db_triggers.sql

-- Tabla de auditoría: AUDITORIA_CAMBIOS
-- Triggers para UPDATE/DELETE sobre las tablas del modelo

## Ejecución Paso a Paso

## 1. Poblar las tablas normalizadas

BEGIN
PKG_VENTAS_INMUEBLES.SP_POBLAR_TODO(SYSDATE);
END;
/

## 2. Generar el reporte y crear la vista pivote

BEGIN
PKG_REPORTES.SP_GENERAR_REPORTE(
TO_DATE('2001-01-01','YYYY-MM-DD'),
TO_DATE('2024-12-31','YYYY-MM-DD')
);
END;
/

## 3. Consultar la vista dinámica

SELECT \* FROM VW_REPORTE_VENTAS_PIVOTE;
