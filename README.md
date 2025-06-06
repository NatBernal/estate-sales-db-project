# Proyecto Base de Datos de Ventas de Inmuebles

Este proyecto consiste en el diseño e implementación de una base de datos relacional en Oracle para almacenar, consultar y poblar información relacionada con ventas históricas de inmuebles en Estados Unidos, basada en un dataset real disponible en Kaggle.

## Dataset Utilizado

- **Nombre**: Real Estate Sales 2001-2022
- **Fuente**: [Kaggle](https://www.kaggle.com/datasets/omniamahmoudsaeed/real-estate-sales-2001-2022)
- **Contenido**: Información sobre dirección, valor catastral, valor de venta, tipo de propiedad, tipo de residencia, observaciones del asesor y OPM, coordenadas geográficas, etc.

## Modelo Entidad-Relación

## 🚀 Instrucciones de Uso

README: Base de Datos de Ventas Inmobiliarias

1. Descripción general
   Esta base de datos está diseñada para almacenar y gestionar información sobre ventas de inmuebles en diferentes pueblos o ciudades de EE. UU., cubriendo el periodo 2001–2022. El dataset proviene de "Real Estate Sales 2001–2022" (Kaggle). La estructura contempla tablas maestros (pueblos, tipos de propiedad, tipos de residencia), tablas transaccionales (propiedades, ventas, observaciones) y mecanismos de auditoría y control de carga. El proyecto fue creado por Natalia Bernal y Mileth Martínez.

2. Requisitos previos
   Usuario de base de datos: Se debe ejecutar parte del script como usuario SYSTEM (creación de tablespaces y usuario).

Tablespaces:

DATOS_VENTAS: tablespace para tablas de datos.

TS_INDICES_VENTAS: tablespace para índices.
Ambos se crean con archivos de 10 MB, autoextensión de 10 MB hasta 50 MB.

Usuario de pruebas: USER_PRUEBA con contraseña ABC987, con permisos de creación de sesión, tablas, secuencias, procedimientos y triggers, y cuota ilimitada en los tablespaces relevantes.

3. Secuencias
   Se generan secuencias para manejar claves primarias automáticas en varias tablas:

SEQ_PUEBLO_ID: para PUEBLOS.ID_PUEBLO (inicia en 1).

SEQ_TIPO_PROPIEDAD_ID: para TIPOS_PROPIEDAD.ID_TIPO_PROPIEDAD.

SEQ_TIPO_RESIDENCIA_ID: para TIPOS_RESIDENCIA.ID_TIPO_RESIDENCIA.

SEQ_LOCALIZACIONES_ID: para LOCALIZACIONES.ID_LOCALIZACION.

SEQ_PROPIEDAD_ID: para PROPIEDADES.ID_PROPIEDAD.

SEQ_VENTAS_ID: para VENTAS.ID_VENTA.

SEQ_OBSERVACIONES_ID: para OBSERVACIONES.ID_OBSERVACION.

SEQ_CONTROL_ID: para CONTROL_CARGA.ID_CONTROL.

Todas las secuencias usan NOCACHE NOCYCLE y parten de 1, con incremento de 1.

4. Tablas principales
   4.1 PUEBLOS
   Descripción: Lista de pueblos o ciudades donde se ubican las propiedades.

Columnas:

ID_PUEBLO NUMBER (default SEQ_PUEBLO_ID.NEXTVAL): identificador único.

NOMBRE VARCHAR2(70): nombre del pueblo/ciudad.

Comentarios:

Tabla: "Lista de pueblos o ciudades de EE.UU. donde se ubican propiedades."

ID_PUEBLO: "Identificador único del pueblo."

NOMBRE: "Nombre del pueblo o ciudad."

Restricciones:

Clave primaria en ID_PUEBLO.

NOMBRE es único (UC_PUEBLO_NOMBRE).

4.2 TIPOS_PROPIEDAD
Descripción: Tipos generales de propiedad (por ejemplo, Comercial, Residencial).

Columnas:

ID_TIPO_PROPIEDAD NUMBER (default SEQ_TIPO_PROPIEDAD_ID.NEXTVAL): identificador único.

DESCRIPCION VARCHAR2(50): descripción del tipo.

Comentarios:

Tabla: "Tipos generales de propiedad (ej. Comercial, Residencial)."

ID_TIPO_PROPIEDAD: "Identificador único del tipo de propiedad."

DESCRIPCION: "Descripción del tipo de propiedad."

Restricciones:

Clave primaria en ID_TIPO_PROPIEDAD.

4.3 TIPOS_RESIDENCIA
Descripción: Clasificación del tipo de residencia (por ejemplo, Unifamiliar, Multifamiliar).

Columnas:

ID_TIPO_RESIDENCIA NUMBER (default SEQ_TIPO_RESIDENCIA_ID.NEXTVAL): identificador único.

DESCRIPCION VARCHAR2(50): descripción del tipo de residencia.

Comentarios:

Tabla: "Clasificación del tipo de residencia (ej. Unifamiliar, Multifamiliar)."

ID_TIPO_RESIDENCIA: "Identificador único del tipo de residencia."

DESCRIPCION: "Descripción del tipo de residencia."

Restricciones:

Clave primaria en ID_TIPO_RESIDENCIA.

4.4 LOCALIZACIONES
Descripción: Ubicaciones de las propiedades (geografía y dirección).

Columnas:

ID_LOCALIZACION NUMBER (default SEQ_LOCALIZACIONES_ID.NEXTVAL): identificador único.

ID_PUEBLO NUMBER NOT NULL: llave foránea a PUEBLOS(ID_PUEBLO).

LATITUD NUMBER: coordenada de latitud.

LONGITUD NUMBER: coordenada de longitud.

DIRECCION VARCHAR2(100): dirección textual.

Comentarios:

Tabla: "Ubicaciones de las propiedades" / "Información geográfica y dirección específica de cada propiedad."

ID_LOCALIZACION: "Identificador único de la localización."

ID_PUEBLO: "Llave foránea al pueblo correspondiente."

LATITUD: "Coordenada geográfica de latitud."

LONGITUD: "Coordenada geográfica de longitud."

DIRECCION: "Dirección textual de la propiedad."

Restricciones:

Clave primaria en ID_LOCALIZACION.

FK ID_PUEBLO → PUEBLOS(ID_PUEBLO).

4.5 PROPIEDADES
Descripción: Propiedades inmobiliarias registradas.

Columnas:

ID_PROPIEDAD NUMBER (default SEQ_PROPIEDAD_ID.NEXTVAL): identificador único.

NUMERO_SERIAL NUMBER NOT NULL: número serial único dentro de la localización.

ID_TIPO_PROPIEDAD NUMBER: FK a TIPOS_PROPIEDAD(ID_TIPO_PROPIEDAD).

ID_TIPO_RESIDENCIA NUMBER: FK a TIPOS_RESIDENCIA(ID_TIPO_RESIDENCIA).

ID_LOCALIZACION NUMBER: FK a LOCALIZACIONES(ID_LOCALIZACION).

VALOR_CATASTRAL FLOAT: valor fiscal de la propiedad.

Comentarios:

Tabla: "Propiedades inmobiliarias registradas en la base de datos."

ID_PROPIEDAD: "Identificador único de la propiedad."

NUMERO_SERIAL: "Número de serie de la propiedad, único dentro de la localización."

ID_TIPO_PROPIEDAD: "Tipo general de propiedad."

ID_TIPO_RESIDENCIA: "Tipo de residencia, si aplica."

ID_LOCALIZACION: "Ubicación asociada a la propiedad."

VALOR_CATASTRAL: "Valor fiscal de la propiedad."

Restricciones:

Clave primaria en ID_PROPIEDAD.

FK ID_TIPO_PROPIEDAD → TIPOS_PROPIEDAD(ID_TIPO_PROPIEDAD).

FK ID_TIPO_RESIDENCIA → TIPOS_RESIDENCIA(ID_TIPO_RESIDENCIA).

FK ID_LOCALIZACION → LOCALIZACIONES(ID_LOCALIZACION).

Único combinado en (NUMERO_SERIAL, ID_LOCALIZACION) para evitar duplicados.

4.6 VENTAS
Descripción: Ventas de propiedades.

Columnas:

ID_VENTA NUMBER (default SEQ_VENTAS_ID.NEXTVAL): identificador único.

ID_PROPIEDAD NUMBER NOT NULL: FK a PROPIEDADES(ID_PROPIEDAD).

ANIO_VENTA NUMBER NOT NULL: año de la venta.

FECHA_REGISTRO DATE NOT NULL: fecha de registro de la venta.

VALOR_VENTA FLOAT: valor de la venta.

RELACION_VENTA FLOAT: relación de la venta (puede requerir conversión).

CODIGO_NO_USO VARCHAR2(50): campo de código no uso libre.

Comentarios:

Tabla: "Ventas de propiedades"

ID_VENTA: "Identificador de venta"

ID_PROPIEDAD: "Identificador de la propiedad"

ANIO_VENTA: "Año de la venta"

FECHA_REGISTRO: "Fecha de registro de la venta"

VALOR_VENTA: "Valor de la venta"

RELACION_VENTA: "Relación de la venta"

CODIGO_NO_USO: "Código de no uso de la venta"

Restricciones:

Clave primaria en ID_VENTA.

FK ID_PROPIEDAD → PROPIEDADES(ID_PROPIEDAD).

4.7 OBSERVACIONES
Descripción: Observaciones registradas sobre una venta específica.

Columnas:

ID_OBSERVACION NUMBER (default SEQ_OBSERVACIONES_ID.NEXTVAL): identificador único.

ID_VENTA NUMBER NOT NULL: FK a VENTAS(ID_VENTA).

NOTA VARCHAR2(130) NOT NULL: contenido textual de la observación.

TIPO_ORIGEN CHAR(3) NOT NULL: origen de la observación (ASE = Asesor de Ventas, OPM = Office of Policy and Management).

Comentarios:

Tabla: "Observaciones registradas sobre una venta específica."

ID_OBSERVACION: "Identificador único de la observación."

ID_VENTA: "Venta a la que pertenece esta observación."

NOTA: "Contenido textual de la observación."

TIPO_ORIGEN: "Tipo de origen de la observación (ASE = Asesor de Ventas, OPM = Office of Policy and Management)"

Restricciones:

Clave primaria en ID_OBSERVACION.

FK ID_VENTA → VENTAS(ID_VENTA).

TIPO_ORIGEN validado con CHECK (TIPO_ORIGEN IN ('ASE', 'OPM')).

4.8 CONTROL_CARGA
Descripción: Tabla de auditoría para procesos de carga de datos. Registra qué tablas se cargan, número de filas, operaciones y fechas.

Columnas:

ID_CONTROL NUMBER (default SEQ_CONTROL_ID.NEXTVAL): identificador único.

NOMBRE_TABLA VARCHAR2(50) NOT NULL: nombre de la tabla afectada.

FILAS_AFECTADAS NUMBER NOT NULL: cantidad de registros procesados.

OPERACION VARCHAR2(10) NOT NULL: tipo de operación (INSERT, UPDATE, DELETE).

FECHA_PROCESO DATE NOT NULL: fecha y hora del proceso de carga.

USUARIO_PROCESO VARCHAR2(50) NOT NULL: usuario que ejecutó el proceso.

Comentarios:

Tabla: "Tabla de auditoría para procesos de carga de datos."

NOMBRE_TABLA: "Nombre de la tabla afectada por el proceso."

FILAS_AFECTADAS: "Cantidad de registros procesados."

OPERACION: "Tipo de operación realizada (INSERT, UPDATE, DELETE)"

FECHA_PROCESO: "Fecha y hora del proceso de carga."

USUARIO_PROCESO: "Usuario que ejecutó el proceso."

Restricciones:

Clave primaria en ID_CONTROL.

OPERACION validado con CHECK (OPERACION IN ('INSERT','UPDATE','DELETE')).

4.9 AUDITORIA_CAMBIOS
Descripción: Tabla de auditoría de cambios (DML) para detectar actualizaciones o eliminaciones en tablas críticas.

Columnas:

ID_AUDITORIA NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY: identificador único.

USUARIO_BD VARCHAR2(50): usuario de BD que realizó la operación.

MAQUINA VARCHAR2(100): máquina desde donde se ejecutó.

FECHA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP: fecha y hora de la operación.

TIPO_OPERACION VARCHAR2(10): tipo de operación (UPDATE o DELETE).

NOMBRE_TABLA VARCHAR2(50): nombre de la tabla afectada.

VALOR_ANTERIOR CLOB: estado anterior del registro.

VALOR_NUEVO CLOB: nuevo estado (sólo para UPDATE).

Restricciones:

Clave primaria en ID_AUDITORIA.

4.10 TABLA_PRUEBA
Descripción: Tabla temporal donde se importan datos brutos desde un CSV antes de poblar las tablas definitivas. Debe ejecutarse como USER_PRUEBA.

Columnas:

NUMERO_SERIAL NUMBER(38)

ANIO_VENTA NUMBER(38)

FECHA_REGISTRO DATE

PUEBLO VARCHAR2(26)

DIRECCION VARCHAR2(128)

VALOR_CATASTRAL FLOAT

VALOR_VENTA FLOAT

RELACION_VENTA VARCHAR2(26)

TIPO_PROPIEDAD VARCHAR2(26)

TIPO_RESIDENCIA VARCHAR2(26)

COD_NO_USO VARCHAR2(50)

OB_ASESOR VARCHAR2(128)

OB_OPM VARCHAR2(128)

COORDENADAS VARCHAR2(128)

Uso: Importar datos desde CSV externo para luego distribuirlos con los procedimientos de población.

5. Relaciones y restricciones entre tablas
   LOCALIZACIONES.ID_PUEBLO → PUEBLOS(ID_PUEBLO).

PROPIEDADES.ID_TIPO_PROPIEDAD → TIPOS_PROPIEDAD(ID_TIPO_PROPIEDAD).

PROPIEDADES.ID_TIPO_RESIDENCIA → TIPOS_RESIDENCIA(ID_TIPO_RESIDENCIA).

PROPIEDADES.ID_LOCALIZACION → LOCALIZACIONES(ID_LOCALIZACION).

VENTAS.ID_PROPIEDAD → PROPIEDADES(ID_PROPIEDAD).

OBSERVACIONES.ID_VENTA → VENTAS(ID_VENTA).

Además, combinaciones únicas y chequeos:

PROPIEDADES: (NUMERO_SERIAL, ID_LOCALIZACION) único.

OBSERVACIONES.TIPO_ORIGEN en ('ASE', 'OPM').

CONTROL_CARGA.OPERACION en ('INSERT', 'UPDATE', 'DELETE').

6. Procedimientos y funciones de población y validación
   Todos los procedimientos para poblar tablas desde TABLA_PRUEBA, así como para registrar auditoría de carga, están agrupados en el paquete PKG_VENTAS_INMUEBLES.

6.1 PKG_VENTAS_INMUEBLES
Procedimientos:

SP_REGISTRAR_CONTROL(P_NOMBRE_TABLA, P_FILAS_AFECTADAS, P_OPERACION, P_FECHA_PROCESO DEFAULT SYSDATE, P_USUARIO DEFAULT USER): inserta un registro en CONTROL_CARGA.

SP_POBLAR_PUEBLOS(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en PUEBLOS todos los nombres únicos (mayúsculas) de la columna PUEBLO en TABLA_PRUEBA, si no existen.

Registra la cantidad insertada en CONTROL_CARGA y muestra por DBMS_OUTPUT.

Maneja excepciones con rollback y salida de error.

SP_POBLAR_TIPOS_PROPIEDAD(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en TIPOS_PROPIEDAD valores únicos de TIPO_PROPIEDAD desde TABLA_PRUEBA.

Registra en CONTROL_CARGA.

Manejo de excepciones.

SP_POBLAR_TIPOS_RESIDENCIA(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en TIPOS_RESIDENCIA valores únicos de TIPO_RESIDENCIA desde TABLA_PRUEBA.

Registra en CONTROL_CARGA.

Manejo de excepciones.

SP_POBLAR_LOCALIZACIONES(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en LOCALIZACIONES combinando PUEBLOS y los datos DIRECCION/COORDENADAS de TABLA_PRUEBA.

“Coordenadas” se parsea con la función EXTRACT_COORDINATES, separando latitud y longitud.

Evita duplicados comparando (dirección, id_pueblo).

Registra en CONTROL_CARGA.

Manejo de excepciones.

SP_POBLAR_PROPIEDADES(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en PROPIEDADES relacionando TABLA_PRUEBA, PUEBLOS, LOCALIZACIONES, TIPOS_PROPIEDAD y TIPOS_RESIDENCIA.

Solo toma la fila más reciente por serial (ROW_NUMBER sobre partición).

Evita duplicados con (NUMERO_SERIAL, ID_LOCALIZACION).

Registra en CONTROL_CARGA.

Manejo de excepciones.

SP_POBLAR_VENTAS(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta en VENTAS, utilizando subconsultas para garantizar unívocos por (NUMERO_SERIAL, PUEBLO), convertiendo RELACION_VENTA a número o dividiendo por 1 000 000 000 si no es numérico puro.

Usa PROPIEDADES_POR_PUEBLO y PRUEBA_UNICA con ROW_NUMBER para obtener datos más recientes.

Registra en CONTROL_CARGA.

Manejo de excepciones.

SP_POBLAR_OBSERVACIONES(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Inserta observaciones tipo ASE en OBSERVACIONES cuando OB_ASESOR no es nulo en TABLA_PRUEBA, vinculando PUEBLOS, LOCALIZACIONES, PROPIEDADES, VENTAS.

Inserta observaciones tipo OPM de forma similar.

Suma filas ASE y OPM, registra en CONTROL_CARGA y muestra detalles.

Manejo de excepciones.

SP_LIMPIAR_BASE_DATOS(P_FECHA_LIMPIEZA IN DATE DEFAULT SYSDATE, P_LIMPIAR_CONTROL IN BOOLEAN DEFAULT FALSE):

Elimina registros en orden desde OBSERVACIONES, VENTAS, PROPIEDADES, LOCALIZACIONES, PUEBLOS, TIPOS_RESIDENCIA, TIPOS_PROPIEDAD, CONTROL_CARGA (opcional).

Este procedimiento asegura la limpieza completa de todas las tablas.

SP_POBLAR_TODO(P_FECHA_CARGA IN DATE DEFAULT SYSDATE):

Invoca FN_VALIDAR_FECHA_CARGA para comprobar que la fecha no esté fuera de rango (±3 días).

Si válida, ejecuta en orden todos los procedimientos de población (PUEBLOS, TIPOS_PROPIEDAD, TIPOS_RESIDENCIA, LOCALIZACIONES, PROPIEDADES, VENTAS, OBSERVACIONES).

Muestra mensaje de “Poblado completo”.

Manejo de excepciones.

Funciones:

EXTRACT_COORDINATES(P_LOCATION IN VARCHAR2, P_RETURN_LAT IN CHAR) RETURN NUMBER:

Extrae latitud (cuando P_RETURN_LAT = '1') o longitud (cuando P_RETURN_LAT ≠ '1') de un campo POINT (long lat) usando expresiones regulares.

Retorna NULL en caso de error o si P_LOCATION es nulo.

FN_VALIDAR_FECHA_CARGA(P_FECHA_CARGA IN DATE) RETURN BOOLEAN:

Verifica que P_FECHA_CARGA no sea más de 3 días en el pasado ni en el futuro con respecto a SYSDATE.

Si falla, lanza error con código C_FECHA_ANTERIOR (fecha < SYSDATE − 3) o C_FECHA_POSTERIOR (fecha > SYSDATE + 3).

Retorna TRUE si el rango es válido, de lo contrario dispara excepción.

7. Procedimientos y funciones de reportes y estadísticas
   Todos los objetos de reporte se agrupan en el paquete PKG_REPORTES (archivo db_pkg_reportes.sql) y en procedimientos sueltos asociados (DB_REPORTE.sql, db_consultas_informes.sql).

7.1 PKG_REPORTES
Procedimientos:

GENERAR_REPORTE(p_fecha_inicio IN DATE, p_fecha_fin IN DATE):

Elimina filas de REPORTE_VENTAS_ANIO para años con ventas entre las fechas provistas.

Inserta en REPORTE_VENTAS_ANIO por año de venta (ANIO_VENTA), contando ventas, calculando promedio y sumatoria de VALOR_VENTA, y fecha de generación (SYSDATE).

Realiza COMMIT.

SP_MOSTRAR_ESTADISTICAS(P_FECHA_PROCESO IN DATE DEFAULT NULL):

Muestra por DBMS_OUTPUT conteo de registros en PUEBLOS, TIPOS_PROPIEDAD, TIPOS_RESIDENCIA, LOCALIZACIONES, PROPIEDADES, VENTAS, OBSERVACIONES. Si se pasa fecha, la muestra en formato DDMMYYYY (o DD MM YYYY).

Luego, recorre CONTROL_CARGA y muestra total filas procesadas y veces ejecutado por NOMBRE_TABLA y OPERACION.

Formato de líneas con subrayados para separación visual.

Funciones:

GET_TOTAL_VENTAS_ANIO(p_anio IN NUMBER) RETURN NUMBER:

Retorna suma de VALOR_VENTA en VENTAS donde ANIO_VENTA = p_anio.

Si no hay datos, retorna 0.

Captura excepciones NO_DATA_FOUND y OTHERS.

GET_PROMEDIO_VENTAS_ANIO(p_anio IN NUMBER) RETURN NUMBER:

Retorna promedio (AVG(VALOR_VENTA)) para ANIO_VENTA = p_anio.

Si no hay datos, retorna 0.

Captura excepciones.

7.2 Procedimientos adicionales de consulta
SP_MOSTRAR_ESTADISTICAS (archivo db_consultas_informes.sql):

Implementa, de forma muy similar al de PKG_REPORTES, estadísticas de conteo en tablas principales, y resumen de CONTROL_CARGA.

Usa formato DD/MM/YYYY para fecha de proceso.

Cita creación: 18/05/2025 (Natalia Bernal & Mileth Martínez).

SP_CONSULTAR_CONTROL(P_TABLA IN VARCHAR2 DEFAULT NULL, P_FECHA_DESDE IN DATE DEFAULT NULL, P_FECHA_HASTA IN DATE DEFAULT NULL):

Muestra historiales de CONTROL_CARGA filtrando por tabla y rango de fechas, con salida por DBMS_OUTPUT.

8. Triggers de auditoría
   Cada vez que se realiza un UPDATE o DELETE en ciertas tablas, el trigger correspondiente registra los valores anteriores y nuevos en AUDITORIA_CAMBIOS.

Tabla de auditoría:

AUDITORIA_CAMBIOS (creada en db_triggers.sql):

Columnas: ID_AUDITORIA (PK, identidad), USUARIO_BD, MAQUINA, FECHA_HORA, TIPO_OPERACION, NOMBRE_TABLA, VALOR_ANTERIOR, VALOR_NUEVO.

Triggers (para cada tabla relevante):

trg_aud_ventas: Después de UPDATE o DELETE en VENTAS. Registra usuario, máquina, operación, tabla, valores antiguos y nuevos (si aplica).

trg_aud_propiedades: Después de UPDATE o DELETE en PROPIEDADES. Registra valores de ID_PROPEDAD, NUMERO_SERIAL, VALOR_CATASTRAL.

trg_aud_observaciones: Después de UPDATE o DELETE en OBSERVACIONES. Registra ID_OBSERVACION y NOTA.

trg_aud_localizaciones: Después de UPDATE o DELETE en LOCALIZACIONES. Registra ID_LOCALIZACION y DIRECCION.

trg_audit_pueblos: Antes de UPDATE o DELETE en PUEBLOS. Registra ID_PUEBLO y NOMBRE.

trg_audit_tipos_propiedad: Antes de UPDATE o DELETE en TIPOS_PROPIEDAD. Registra ID_TIPO_PROPIEDAD y DESCRIPCION.

(Existen triggers análogos para TIPOS_RESIDENCIA, CONTROL_CARGA, etc., siguiendo la misma lógica).

9. Flujo de carga de datos y uso básico
   Crear tablespaces y usuario

Ejecutar db_userCreation.sql como SYSTEM para crear tablespaces DATOS_VENTAS, TS_INDICES_VENTAS y usuario USER_PRUEBA con permisos y cuotas.

Conectar como USER_PRUEBA

Crear todas las tablas principales (scripts db_creation.sql y db_populate_tables.sql).

Crear secuencias y comentarios en columnas/tablas.

Crear tabla CONTROL_CARGA y sus procedimientos de registro.

Crear tabla temporal TABLA_PRUEBA.

Importar datos

Cargar el archivo CSV en TABLA_PRUEBA (mecanismo externo, p. ej., SQL\*Loader o similar).

Ejecutar población automatizada

Invocar PKG_VENTAS_INMUEBLES.FN_VALIDAR_FECHA_CARGA(p_fecha) para validar rango de fecha (por defecto SYSDATE).

Ejecutar PKG_VENTAS_INMUEBLES.SP_POBLAR_TODO(p_fecha) para poblar todas las tablas en orden:

PUEBLOS, TIPOS_PROPIEDAD, TIPOS_RESIDENCIA, LOCALIZACIONES, PROPIEDADES, VENTAS, OBSERVACIONES.

Cada paso registra su ejecución en CONTROL_CARGA y reporta cantidad de filas y fecha de proceso vía DBMS_OUTPUT.

Realizar consultas y reportes

Usar PKG_REPORTES.GENERAR_REPORTE(p_fecha_inicio, p_fecha_fin) para generar o actualizar datos en REPORTE_VENTAS_ANIO.

Invocar PKG_REPORTES.SP_MOSTRAR_ESTADISTICAS(p_fecha_proceso) para ver recuentos de tablas y resumen de carga por fecha.

Alternativamente, SP_MOSTRAR_ESTADISTICAS del archivo db_consultas_informes.sql provee funcionalidad similar.

Consulta manual de historiales de cargas con SP_CONSULTAR_CONTROL.

Auditoría de DML

Cada vez que se actualiza o elimina un registro en VENTAS, PROPIEDADES, OBSERVACIONES, LOCALIZACIONES, PUEBLOS o TIPOS_PROPIEDAD, los triggers correspondientes almacenan los cambios en AUDITORIA_CAMBIOS.

10. Esquema resumido
    plaintext
    Copiar
    Editar
    Tablespaces:

- DATOS_VENTAS (datos principales)
- TS_INDICES_VENTAS (índices)

Usuario:

- USER_PRUEBA

Secuencias:

- SEQ_PUEBLO_ID
- SEQ_TIPO_PROPIEDAD_ID
- SEQ_TIPO_RESIDENCIA_ID
- SEQ_LOCALIZACIONES_ID
- SEQ_PROPIEDAD_ID
- SEQ_VENTAS_ID
- SEQ_OBSERVACIONES_ID
- SEQ_CONTROL_ID

Tablas maestras:

- PUEBLOS
- TIPOS_PROPIEDAD
- TIPOS_RESIDENCIA

Tablas de ubicación y bienes:

- LOCALIZACIONES (FK → PUEBLOS)
- PROPIEDADES (FK → TIPOS_PROPIEDAD, TIPOS_RESIDENCIA, LOCALIZACIONES)

Tablas transaccionales:

- VENTAS (FK → PROPIEDADES)
- OBSERVACIONES (FK → VENTAS)

Tablas de soporte:

- CONTROL_CARGA (registro de cargas)
- AUDITORIA_CAMBIOS (registro de DML)
- TABLA_PRUEBA (temporal para importar datos)

Objetos de PL/SQL:

- Package PKG_VENTAS_INMUEBLES (población y control)
- Package PKG_REPORTES (reportes y estadísticas)
- Procedimientos sueltos SP\_… (consultas e informes)
- Triggers trg*aud*… (auditoría de DML)

11. Notas de implementación y uso detallado
    Creación inicial

Ejecutar db_userCreation.sql como SYSTEM para crear tablespaces y usuario de pruebas.

Conectarse como USER_PRUEBA y ejecutar db_creation.sql para crear secuencias, tablas maestras y transaccionales junto con comentarios y restricciones.

Ejecutar db_populate_tables.sql para crear CONTROL_CARGA, los procedimientos de registro de carga y los procedimientos de población inicial de PUEBLOS, TIPOS_PROPIEDAD, TIPOS_RESIDENCIA, etc.

Crear la tabla temporal TABLA_PRUEBA (incluida en db_temporal_table.sql).

Carga de datos desde CSV

Importar el CSV bruto a TABLA_PRUEBA (método externo, p. ej. SQL\*Loader).

Verificar contenido en TABLA_PRUEBA. Campos clave: NUMERO_SERIAL, ANIO_VENTA, FECHA_REGISTRO, PUEBLO, DIRECCION, VALOR_CATASTRAL, VALOR_VENTA, RELACION_VENTA, TIPO_PROPIEDAD, TIPO_RESIDENCIA, COD_NO_USO, OB_ASESOR, OB_OPM, COORDENADAS.

Ejecución de población completa

Para poblar todas las tablas, invocar:

sql
Copiar
Editar
BEGIN
PKG_VENTAS_INMUEBLES.SP_POBLAR_TODO(SYSDATE);
END;
Esto validará la fecha y luego, en orden:

Pueblos

Tipos de propiedad

Tipos de residencia

Localizaciones (incluyendo parseo de COORDENADAS)

Propiedades (relaciona serial + localización)

Ventas (filtra duplicados y normaliza RELACION_VENTA)

Observaciones (inserta notas de asesores y OPM)

Cada subproceso registra en CONTROL_CARGA y escribe en DBMS_OUTPUT:

ruby
Copiar
Editar
<Tabla> insertados: <número>
Fecha de proceso: <DD/MM/YYYY HH24:MI:SS>
En caso de error en cualquier paso, se realiza rollback del paso actual y se muestra el mensaje de error.

Reportes y consultas

Para generar un reporte de ventas agregado por año entre dos fechas específicas:

sql
Copiar
Editar
BEGIN
PKG_REPORTES.GENERAR_REPORTE(TO_DATE('01/01/2022','DD/MM/YYYY'),
TO_DATE('31/12/2022','DD/MM/YYYY'));
END;
Esto actualizará o insertará en REPORTE_VENTAS_ANIO estadísticas de ventas anuales.

Para mostrar estadísticas generales de la BD (conteos de tablas y resumen de carga):

sql
Copiar
Editar
BEGIN
PKG_REPORTES.SP_MOSTRAR_ESTADISTICAS(NULL);
END;
O pasar una fecha específica:

sql
Copiar
Editar
BEGIN
PKG_REPORTES.SP_MOSTRAR_ESTADISTICAS(TO_DATE('01/06/2025','DD/MM/YYYY'));
END;
Esto imprimirá por DBMS_OUTPUT un reporte con subrayados y líneas de separación.

Alternativamente, usar el procedimiento suelto SP_MOSTRAR_ESTADISTICAS definido en db_consultas_informes.sql para obtener información similar.

Para consultar historiales de carga filtrados:

sql
Copiar
Editar
BEGIN
SP_CONSULTAR_CONTROL('PROPIEDADES',
TO_DATE('01/05/2025','DD/MM/YYYY'),
TO_DATE('05/06/2025','DD/MM/YYYY'));
END;
Se listarán las filas de CONTROL_CARGA que cumplan criterios.

Auditoría de cambios

Cada vez que se realiza un UPDATE o DELETE en las tablas:

VENTAS (trigger trg_aud_ventas)

PROPIEDADES (trg_aud_propiedades)

OBSERVACIONES (trg_aud_observaciones)

LOCALIZACIONES (trg_aud_localizaciones)

PUEBLOS (trg_audit_pueblos)

TIPOS_PROPIEDAD (trg_audit_tipos_propiedad)

…
Los valores previos y nuevos (cuando aplique) se guardan en AUDITORIA_CAMBIOS.

Esto permite rastrear modificaciones a nivel de fila con nombre de usuario y máquina de origen.

12. Detalle de objetos de PL/SQL
    12.1 Paquete PKG_VENTAS_INMUEBLES
    Código fuente: db_PKG_VENTAS_INM.sql.

Descripción: Provee lógica para poblar las tablas entrenando sobre datos de TABLA_PRUEBA, registrar auditoría de carga en CONTROL_CARGA, validar fechas y limpiar la base de datos cuando sea necesario.

12.2 Paquete PKG_REPORTES
Código fuente: db_pkg_reportes.sql.

Descripción: Contiene procedimientos para generar reportes de ventas anuales y mostrar estadísticas de uso de la base de datos, así como funciones para calcular totales y promedios de ventas por año.

12.3 Procedimientos sueltos
En DB_REPORTE.sql:

GENERAR_REPORTE y SP_MOSTRAR_ESTADISTICAS (duplican funcionalidad de PKG_REPORTES).

En db_consultas_informes.sql:

SP_MOSTRAR_ESTADISTICAS (versión alternativa)

SP_CONSULTAR_CONTROL

Otras consultas e informes (no listadas completamente aquí).

13. Triggers de auditoría (detalle)
    Definición: Todos los triggers se crean en db_triggers.sql.

Lógica común:

Detectar si la operación es UPDATE o DELETE.

Obtener usuario de sesión y máquina con SYS_CONTEXT('USERENV', ...).

Construir cadenas de texto con valores antiguos (:OLD) y nuevos (:NEW para UPDATE).

Insertar un registro en AUDITORIA_CAMBIOS con columnas: usuario_bd, maquina, tipo_operacion, nombre_tabla, valor_anterior, valor_nuevo.

Ejemplos:

Trigger trg_aud_ventas:

plsql
Copiar
Editar
CREATE OR REPLACE TRIGGER trg_aud_ventas
AFTER UPDATE OR DELETE ON ventas
FOR EACH ROW
DECLARE
v_user VARCHAR2(50);
v_host VARCHAR2(100);
v_op VARCHAR2(10);
v_val_ant CLOB;
v_val_new CLOB;
BEGIN
IF DELETING THEN v_op := 'DELETE'; ELSIF UPDATING THEN v_op := 'UPDATE'; END IF;
SELECT SYS_CONTEXT('USERENV','SESSION_USER'),
SYS_CONTEXT('USERENV','HOST') INTO v_user, v_host FROM DUAL;
v_val_ant := 'ID='||:OLD.id_venta||', PROPIEDAD='||:OLD.id_propiedad||', AÑO='||:OLD.anio_venta||', VALOR='||:OLD.valor_venta||', FECHA='||TO_CHAR(:OLD.fecha_registro,'YYYY-MM-DD');
IF UPDATING THEN
v_val_new := 'ID='||:NEW.id_venta||', PROPIEDAD='||:NEW.id_propiedad||', AÑO='||:NEW.anio_venta||', VALOR='||:NEW.valor_venta||', FECHA='||TO_CHAR(:NEW.fecha_registro,'YYYY-MM-DD');
ELSE
v_val_new := NULL;
END IF;
INSERT INTO auditoria_cambios(usuario_bd, maquina, tipo_operacion, nombre_tabla, valor_anterior, valor_nuevo)
VALUES(v_user, v_host, v_op, 'VENTAS', v_val_ant, v_val_new);
END;

Similar para trg_aud_propiedades, trg_aud_observaciones, trg_aud_localizaciones, trg_audit_pueblos, trg_audit_tipos_propiedad, etc.

14. Tablas de reporte final (opcional)
    REPORTE_VENTAS_ANIO (no incluida explícitamente en scripts, pero implícita en paquetes de reporte):

Columnas habituales: ANIO_VENTA, TOTAL_VENTAS, PROMEDIO_VALOR_VENTA, TOTAL_VALOR_VENTA, FECHA_GENERACION.

Se actualiza/inserta con PKG_REPORTES.GENERAR_REPORTE.

15. Resumen de flujo de trabajo sugerido
    plaintext
    Copiar
    Editar
1. Ejecutar como SYSTEM:

   - Crear tablespaces (DATOS_VENTAS, TS_INDICES_VENTAS).
   - Crear usuario USER_PRUEBA y asignar permisos/quotas.

1. Conectarse como USER_PRUEBA:

   - Ejecutar db*creation.sql:
     • Crear secuencias (SEQ*...).
     • Crear tablas PUEBLOS, TIPOS_PROPIEDAD, TIPOS_RESIDENCIA,
     LOCALIZACIONES, PROPIEDADES, VENTAS, OBSERVACIONES.
     • Crear constraints (PK, FK, unique, check).
     • Crear comentarios de tablas y columnas.
   - Ejecutar db_populate_tables.sql:
     • Crear CONTROL_CARGA y su secuencia.
     • Crear SP_REGISTRAR_CONTROL, SP_POBLAR_PUEBLOS, SP_POBLAR_TIPOS_PROPIEDAD,
     SP_POBLAR_TIPOS_RESIDENCIA, SP_POBLAR_LOCALIZACIONES, SP_POBLAR_PROPIEDADES,
     SP_POBLAR_VENTAS, SP_POBLAR_OBSERVACIONES, SP_LIMPIAR_BASE_DATOS.
     • Crear CHECK para OPERACION en CONTROL_CARGA.
   - Ejecutar db_temporal_table.sql:
     • Crear TABLA_PRUEBA.

1. Importar datos CSV a TABLA_PRUEBA (externamente).

1. Ejecutar PKG_VENTAS_INMUEBLES.SP_POBLAR_TODO(SYSDATE):

   - Llena las tablas maestras y transaccionales en orden,
     validando fechas y registrando en CONTROL_CARGA.

1. Ejecutar reportes:

   - PKG_REPORTES.GENERAR_REPORTE para actualizar REPORTE_VENTAS_ANIO.
   - PKG_REPORTES.SP_MOSTRAR_ESTADISTICAS (o SP_MOSTRAR_ESTADISTICAS suelto)
     para ver conteos y resumen de cargas.

1. Consultas puntuales:

   - SP_CONSULTAR_CONTROL para ver historiales de carga.
   - Funciones GET_TOTAL_VENTAS_ANIO y GET_PROMEDIO_VENTAS_ANIO
     para obtener métricas de ventas por año.

1. Auditoría de valores:

   - Cada `UPDATE`/`DELETE` en tablas críticas genera un registro en AUDITORIA_CAMBIOS
     mediante triggers (p.ej. trg_aud_ventas, trg_aud_propiedades, etc.).

1. Limpieza completa (opcional):
   - SP_LIMPIAR_BASE_DATOS para vaciar todas las tablas (OBSERVACIONES → VENTAS → PROPIEDADES → LOCALIZACIONES → PUEBLOS → TIPOS_RESIDENCIA → TIPOS_PROPIEDAD → CONTROL_CARGA).
1. Referencias a los scripts
   db_userCreation.sql (creación de tablespaces y usuario):

db_creation.sql (secuencias, tablas maestras/transaccionales, comentarios, restricciones):

db_populate_tables.sql (CONTROL_CARGA, procedimientos de población y registro, validación de fechas, tabla temporal):

db_temporal_table.sql (creación de TABLA_PRUEBA):

db_pkg_reportes.sql (paquete de reportes, estadísticas, funciones de ventas):

DB_REPORTE.sql (procedimientos de reportes sueltos):

db_consultas_informes.sql (procedimientos de estadísticas y control en versión suelta):

db_triggers.sql (creación de AUDITORIA_CAMBIOS y triggers de auditoría):

17. Conclusión
    Este README provee una visión detallada de la estructura, objetos y flujos de la base de datos de ventas inmobiliarias. Al seguir los pasos en orden—creación de tablespaces/usuario, definición de tablas y secuencias, importación de datos a TABLA_PRUEBA, ejecución de procedimientos de población y generación de reportes—se garantiza la integridad, trazabilidad y capacidad analítica de los datos. Además, los mecanismos de auditoría y control de carga ofrecen trazabilidad completa de las modificaciones y procesos de ETL internos.
