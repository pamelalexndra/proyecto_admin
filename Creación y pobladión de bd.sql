-- ============================================
-- CREACIÓN DE BASE DE DATOS
-- ============================================
USE master;
GO;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Gimnasio')
BEGIN
    CREATE DATABASE Gimnasio
    CONTAINMENT = PARTIAL;  -- Base de datos autocontenida
    PRINT 'Base de datos Gimnasio creada';
END
ELSE
    PRINT 'Base de datos Gimnasio ya existe';
GO

USE Gimnasio;
GO

-- ============================================
-- CREACIÓN DE ESQUEMAS
-- ============================================
-- 1. Crear esquema gestion_clases
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gestion_clases')
BEGIN
	EXEC('CREATE SCHEMA gestion_clases');
	PRINT 'Esquema gestion_clases creado';
END
ELSE 
	PRINT 'Esquema gestion_clases ya existe';
GO

-- 2. Crear esquema gestion_socios
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gestion_socios')
BEGIN
	EXEC('CREATE SCHEMA gestion_socios');
	PRINT 'Esquema gestion_socios creado';
END
ELSE 
	PRINT 'Esquema gestion_socios ya existe';
GO

-- 3. Crear esquema contabilidad
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'contabilidad')
BEGIN
	EXEC('CREATE SCHEMA contabilidad');
	PRINT 'Esquema contabilidad creado';
END
ELSE 
	PRINT 'Esquema contabilidad ya existe';
GO

-- ============================================
-- CREACIÓN DE TABLAS EN ESQUEMAS
-- ============================================
-- 1. Tablas en gestion_socios
CREATE TABLE gestion_socios.PlanGimnasio(
	Id_plan INT PRIMARY KEY IDENTITY(1,1),
	Nombre_plan NVARCHAR(100) NOT NULL,
	Descripcion NVARCHAR(500),
	Costo DECIMAL(5,2),
	Duracion_dias INT NOT NULL CHECK (Duracion_dias > 0)
);

CREATE TABLE gestion_socios.Socio(
	Id_socio INT PRIMARY KEY IDENTITY(1,1),
	Nombre NVARCHAR(150),
	Telefono VARCHAR(15),
	Correo_electronico VARCHAR(150),
	Fecha_registro DATE,
	Id_plan INT,
	CONSTRAINT FK_Socio_Plan FOREIGN KEY (Id_plan) 
	REFERENCES gestion_socios.PlanGimnasio(Id_plan)
);

-- 2. Tablas en gestion_clases
CREATE TABLE gestion_clases.TipoClase (
	Id_tipo_clase VARCHAR(200) PRIMARY KEY,
	Nombre VARCHAR(150)
);

CREATE TABLE gestion_clases.Entrenador (
	Dui VARCHAR(10) PRIMARY KEY,
	Nombre NVARCHAR(100) NOT NULL,
	Telefono VARCHAR(50),
	Correo_electronico VARCHAR(150),
	Salario DECIMAL(7,2) CHECK (Salario >= 0),
	Seguro VARCHAR(100)
);

CREATE TABLE gestion_clases.Clase (
	Id_clase INT IDENTITY(1,1) PRIMARY KEY,
	Nombre_clase NVARCHAR(100) NOT NULL,
	Cupo INT NOT NULL CHECK (Cupo > 0),
	Dui VARCHAR(10) NOT NULL,
	Id_tipo_clase VARCHAR(200) NOT NULL,
	dia_clase TINYINT NOT NULL CHECK (dia_clase BETWEEN 1 AND 7),
	hora_clase TIME(0) NULL CHECK (
	DATEPART(MINUTE, hora_clase) = 0 AND
	DATEPART(SECOND, hora_clase) = 0)
);

CREATE TABLE gestion_clases.Reserva(
	Id_reserva INT PRIMARY KEY IDENTITY(1,1),
	fecha_reserva DATETIME2(0),
	Id_socio INT,
	Id_clase INT,
	CONSTRAINT FK_Reserva_Socio FOREIGN KEY (Id_socio) 
	REFERENCES gestion_socios.Socio(Id_socio),
	CONSTRAINT FK_Reserva_Clase FOREIGN KEY (Id_clase) 
	REFERENCES gestion_clases.Clase(Id_clase)
);

--3 . Tabla en esquema contabilidad
    CREATE TABLE contabilidad.Factura(
	Id_factura INT PRIMARY KEY IDENTITY(1,1),
	Id_socio INT,
	Fecha DATETIME,
	Monto DECIMAL(10,2),
	Metodo_pago VARCHAR(100),
	Estado VARCHAR(100),
	CONSTRAINT FK_Factura_Socio FOREIGN KEY (Id_socio) 
	REFERENCES gestion_socios.Socio(Id_socio)
);

-- ============================================
-- CREACIÓN DE ROLES
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_administrador' AND type = 'R')
BEGIN
    CREATE ROLE rol_administrador;
    PRINT 'Rol rol_administrador creado';
END
ELSE
    PRINT 'Rol rol_administrador ya existe';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_backup' AND type = 'R')
BEGIN
    CREATE ROLE rol_backup;
    PRINT 'Rol rol_backup creado';
END
ELSE
    PRINT 'Rol rol_backup ya existe';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_gerente_operaciones' AND type = 'R')
BEGIN
    CREATE ROLE rol_gerente_operaciones;
    PRINT 'Rol rol_gerente_operaciones creado';
END
ELSE
    PRINT 'Rol rol_gerente_operaciones ya existe';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_analista_reportes' AND type = 'R')
BEGIN
    CREATE ROLE rol_analista_reportes;
    PRINT 'Rol rol_analista_reportes creado';
END
ELSE
    PRINT 'Rol rol_analista_reportes ya existe';
GO

-- ============================================
-- ASIGNACIÓN DE PERMISOS A ROLES
-- ============================================

-- 1. rol_administrador
-- permisos en gestion_clases
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_clases TO rol_administrador;
GRANT CREATE TABLE, ALTER ANY SCHEMA TO rol_administrador;
-- persmisos en gestion_socios
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_socios TO rol_administrador;
-- permisos en contabilidad
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::contabilidad TO rol_administrador

-- 2. rol_backup
GRANT BACKUP DATABASE TO rol_backup;
GRANT BACKUP LOG TO rol_backup;

-- 3. rol_gerente_operaciones
-- SELECT en todos los esquemas
GRANT SELECT ON SCHEMA::gestion_clases TO rol_gerente_operaciones;
GRANT SELECT ON SCHEMA::gestion_socios TO rol_gerente_operaciones;
GRANT SELECT ON SCHEMA::contabilidad TO rol_gerente_operaciones;

-- INSERT y UPDATE solo en gestion_clases
GRANT INSERT, UPDATE ON SCHEMA::gestion_clases TO rol_gerente_operaciones;

--4. rol_analista_reportes
-- SELECT en todos los esquemas
GRANT SELECT ON SCHEMA::gestion_clases TO rol_analista_reportes;
GRANT SELECT ON SCHEMA::gestion_socios TO rol_analista_reportes;
GRANT SELECT ON SCHEMA::contabilidad TO rol_analista_reportes;

-- ============================================
-- CREACIÓN DE USUARIOS Y ASIGNACIÓN DE ROLES
-- ============================================
-- Usuario: admin_db (Administrador)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_db')
BEGIN
    CREATE USER admin_db WITH PASSWORD = 'c0n54$i_1L23K85k',
        DEFAULT_SCHEMA = dbo;
    ALTER ROLE rol_administrador ADD MEMBER admin_db;
    PRINT 'Usuario admin_db creado y asignado a rol_administrador';
END
ELSE
    PRINT 'Usuario admin_db ya existe';
GO

-- Usuario: estudiantes_db (Administrador)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'estudiantes_db')
BEGIN
    CREATE USER estudiantes_db WITH PASSWORD = 'M#ripPl?azsJNyUt',
        DEFAULT_SCHEMA = dbo;
    ALTER ROLE rol_administrador ADD MEMBER estudiantes_db;
    PRINT 'Usuario estudiantes_db creado y asignado a rol_administrador';
END
ELSE
    PRINT 'Usuario estudiantes_db ya existe';
GO

-- Usuario: backup_user (Backup)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'backup_user')
BEGIN
    CREATE USER backup_user WITH PASSWORD = '67gt56h_19?jTkYa',
        DEFAULT_SCHEMA = dbo;
    ALTER ROLE rol_backup ADD MEMBER backup_user;
    PRINT 'Usuario backup_user creado y asignado a rol_backup';
END
ELSE
    PRINT 'Usuario backup_user ya existe';
GO

-- Usuario: gerente_operaciones (Gerente de Operaciones)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gerente_operaciones')
BEGIN
    CREATE USER gerente_operaciones WITH PASSWORD = 'Lp?!lakA21akj%rB!',
        DEFAULT_SCHEMA = gestion_clases;
    ALTER ROLE rol_gerente_operaciones ADD MEMBER gerente_operaciones;
    PRINT 'Usuario gerente_operaciones creado y asignado a rol_gerente_operaciones';
END
ELSE
    PRINT 'Usuario gerente_operaciones ya existe';
GO

-- Usuario: analista_reportes (Analista de Reportes)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'analista_reportes')
BEGIN
    CREATE USER analista_reportes WITH PASSWORD = 'rRryT278$aLmzI_q',
        DEFAULT_SCHEMA = dbo;
    ALTER ROLE rol_analista_reportes ADD MEMBER analista_reportes;
    PRINT 'Usuario analista_reportes creado y asignado a rol_analista_reportes';
END
ELSE
    PRINT 'Usuario analista_reportes ya existe';
GO

-- Usuario: usuario_profesor (Analista de Reportes)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuario_profesor')
BEGIN
    CREATE USER usuario_profesor WITH PASSWORD = 'sS%10?lOopqnmM',
        DEFAULT_SCHEMA = dbo;
    ALTER ROLE rol_analista_reportes ADD MEMBER analista_reportes;
    PRINT 'Usuario usuario_profesor creado y asignado a rol_analista_reportes';
END
ELSE
    PRINT 'Usuario usuario_profesor ya existe';
GO

-- ============================================
-- AUDITORÍA
-- ============================================
USE master;
GO

-- Primero crear directorio para logs si no existe (en C:\AuditLogs\Factura\), luego:
IF EXISTS (SELECT * FROM sys.server_audits WHERE name = 'AuditoriaBasica')
BEGIN
    ALTER SERVER AUDIT AuditoriaBasica WITH (STATE = OFF);
    DROP SERVER AUDIT AuditoriaBasica;
    PRINT '○ Auditoría de servidor eliminada (reconfiguración)';
END
GO

-- Crear Server Audit
CREATE SERVER AUDIT AuditoriaBasica
TO FILE (
    FILEPATH = 'C:\AuditLogs\Factura\',
    MAXSIZE = 20 MB,
    MAX_FILES = 20
)
WITH (
    ON_FAILURE = CONTINUE,
    QUEUE_DELAY = 1000
);
GO

-- Activar auditoría de servidor
ALTER SERVER AUDIT AuditoriaBasica WITH (STATE = ON);
PRINT 'Server Audit creado y activado';
GO

-- Crear Database Audit Specification
USE Gimnasio;
GO

CREATE DATABASE AUDIT SPECIFICATION AuditoriaBasicaFactura
FOR SERVER AUDIT AuditoriaBasica
    ADD (INSERT ON contabilidad.Factura BY PUBLIC),
    ADD (UPDATE ON contabilidad.Factura BY PUBLIC),
    ADD (DELETE ON contabilidad.Factura BY PUBLIC),
	ADD (SELECT ON contabilidad.Factura BY PUBLIC);
GO

-- Activar auditoría de base de datos
ALTER DATABASE AUDIT SPECIFICATION AuditoriaBasicaFactura WITH (STATE = ON);
PRINT 'Database Audit Specification creada y activada';
GO

-- ============================================
-- COMPROBACIÓN DE QUE TODO ESTÁ BIEN
-- ============================================

-- 1. Verificar esquemas
PRINT 'Esquemas creados:';
SELECT name AS Esquema
FROM sys.schemas
WHERE name IN ('gestion_clases', 'gestion_socios', 'contabilidad')
ORDER BY name;
GO

-- 2. Verificar tablas en esquemas
PRINT 'Distribución de tablas por esquema:';
SELECT 
    SCHEMA_NAME(schema_id) AS Esquema,
    name AS Tabla
FROM sys.tables
WHERE SCHEMA_NAME(schema_id) IN ('gestion_clases', 'gestion_socios', 'contabilidad')
ORDER BY Esquema, Tabla;
GO

-- 4. Verificar roles y usuarios 
SELECT 
    r.name AS 'Rol',
    m.name AS 'Usuario Miembro',
    m.create_date AS 'Fecha Creación Usuario'
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r 
    ON drm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m 
    ON drm.member_principal_id = m.principal_id
WHERE r.type = 'R'  -- Solo roles
  AND r.name LIKE 'rol_%'
ORDER BY r.name, m.name;

SELECT 
    dp.name AS Rol,
    CASE perm.class
        WHEN 0 THEN 'BASE DE DATOS'
        WHEN 1 THEN 'OBJETO/TABLA'
        WHEN 3 THEN 'ESQUEMA'
        ELSE CAST(perm.class AS VARCHAR)
    END AS Nivel,
    CASE 
        WHEN perm.class = 3 THEN SCHEMA_NAME(perm.major_id)
        WHEN perm.class = 1 THEN OBJECT_SCHEMA_NAME(perm.major_id)
        ELSE 'N/A'
    END AS Esquema,
    CASE 
        WHEN perm.class = 1 THEN OBJECT_NAME(perm.major_id)
        ELSE 'TODO EL ESQUEMA'
    END AS Objeto,
    perm.permission_name AS Permiso,
    perm.state_desc AS Estado
FROM sys.database_principals dp
INNER JOIN sys.database_permissions perm 
    ON dp.principal_id = perm.grantee_principal_id
WHERE dp.type = 'R'
  AND dp.name LIKE 'rol_%'
ORDER BY 
    dp.name, 
    perm.class,
    CASE WHEN perm.class = 3 THEN SCHEMA_NAME(perm.major_id) ELSE OBJECT_SCHEMA_NAME(perm.major_id) END,
    perm.permission_name;
GO

-- 5. Verificar auditoría
PRINT '';
PRINT 'Estado de auditoría:';
SELECT 
    a.name AS 'Server Audit',
    a.is_state_enabled AS 'Activo'
FROM sys.server_audits a
WHERE a.name = 'AuditoriaBasica';

SELECT 
    name AS 'Database Audit Spec',
    is_state_enabled AS 'Activo'
FROM sys.database_audit_specifications
WHERE name = 'AuditoriaBasicaFactura';
GO

-- 6. Consulta de auditoría
SELECT
	event_time,
	action_id,
	succeeded,
	server_principal_name,
	database_name,
	schema_name, object_name,
	statement,
	additional_information
FROM sys.fn_get_audit_file('C:\AuditLogs\Factura\*', DEFAULT, DEFAULT)
ORDER BY event_time DESC;


-- ============================================
-- POBLACIÓN DE BASE DE DATOS
-- ============================================
-- 1. Tipo de clase
CREATE OR ALTER PROCEDURE dbo.BulkInsert_TipoClase
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando TipoClase desde: ' + @RutaArchivo;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_clases.TipoClase
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK
        )';
        
        EXEC sp_executesql @SQL;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_clases.TipoClase);
        PRINT CAST(@Count AS NVARCHAR) + ' tipos de clase insertados';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al cargar TipoClase: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 2. Planes de gimnasio
CREATE OR ALTER PROCEDURE dbo.BulkInsert_PlanGimnasio
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando PlanGimnasio desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT gestion_socios.PlanGimnasio ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_socios.PlanGimnasio
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK,
            KEEPIDENTITY
        )';
        
        EXEC sp_executesql @SQL;
        
        SET IDENTITY_INSERT gestion_socios.PlanGimnasio OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_socios.PlanGimnasio);
        PRINT CAST(@Count AS NVARCHAR) + ' planes insertados';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT gestion_socios.PlanGimnasio OFF;
        PRINT 'ERROR al cargar PlanGimnasio: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 3. Socios
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Socio
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Socios desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT gestion_socios.Socio ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_socios.Socio
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK,
            BATCHSIZE = 1000,
            KEEPIDENTITY
        )';
        
        EXEC sp_executesql @SQL;
        
        SET IDENTITY_INSERT gestion_socios.Socio OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_socios.Socio);
        PRINT CAST(@Count AS NVARCHAR) + ' socios insertados';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT gestion_socios.Socio OFF;
        PRINT 'ERROR al cargar Socio: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 4. Entrenadores
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Entrenador
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Entrenadores desde: ' + @RutaArchivo;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_clases.Entrenador
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK
        )';
        
        EXEC sp_executesql @SQL;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_clases.Entrenador);
        PRINT CAST(@Count AS NVARCHAR) + ' entrenadores insertados';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al cargar Entrenador: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 5. Clases
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Clase
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Clases desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT gestion_clases.Clase ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_clases.Clase
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK,
            BATCHSIZE = 1000,
            KEEPIDENTITY
        )';
        
        EXEC sp_executesql @SQL;
        
        SET IDENTITY_INSERT gestion_clases.Clase OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_clases.Clase);
        PRINT CAST(@Count AS NVARCHAR) + ' clases insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT gestion_clases.Clase OFF;
        PRINT 'ERROR al cargar Clase: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 6. Reservas
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Reserva
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Reservas desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT gestion_clases.Reserva ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT gestion_clases.Reserva
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK,
            BATCHSIZE = 1000,
            KEEPIDENTITY
        )';
        
        EXEC sp_executesql @SQL;
        
        SET IDENTITY_INSERT gestion_clases.Reserva OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM gestion_clases.Reserva);
        PRINT CAST(@Count AS NVARCHAR) + ' reservas insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT gestion_clases.Reserva OFF;
        PRINT 'ERROR al cargar Reserva: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 7. Facturas
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Factura
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Facturas desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT contabilidad.Factura ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT contabilidad.Factura
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK,
            BATCHSIZE = 1000,
            KEEPIDENTITY
        )';
        
        EXEC sp_executesql @SQL;
        
        SET IDENTITY_INSERT contabilidad.Factura OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM contabilidad.Factura);
        PRINT CAST(@Count AS NVARCHAR) + ' facturas insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT contabilidad.Factura OFF;
        PRINT 'ERROR al cargar Factura: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 8. Procedimiento maestro - cargar todo
CREATE OR ALTER PROCEDURE dbo.CargarTodosDesdeCsv
    @RutaCarpeta NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Asegurar que la ruta termine con \
    IF RIGHT(@RutaCarpeta, 1) <> '\'
        SET @RutaCarpeta = @RutaCarpeta + '\';
    
    DECLARE @RutaTipoClase NVARCHAR(500) = @RutaCarpeta + 'tipos_clase.csv';
    DECLARE @RutaPlanes NVARCHAR(500) = @RutaCarpeta + 'planes_gimnasio.csv';
    DECLARE @RutaSocios NVARCHAR(500) = @RutaCarpeta + 'socios.csv';
    DECLARE @RutaEntrenadores NVARCHAR(500) = @RutaCarpeta + 'entrenadores.csv';
    DECLARE @RutaClases NVARCHAR(500) = @RutaCarpeta + 'clases.csv';
    DECLARE @RutaReservas NVARCHAR(500) = @RutaCarpeta + 'reservas.csv';
    DECLARE @RutaFacturas NVARCHAR(500) = @RutaCarpeta + 'facturas.csv';
    
    BEGIN TRY
        PRINT '========================================';
        PRINT 'CARGANDO DATOS DESDE ARCHIVOS CSV';
        PRINT '========================================';
        PRINT '';
        
        -- Orden correcto según dependencias de FK
        EXEC dbo.BulkInsert_TipoClase @RutaTipoClase;
        EXEC dbo.BulkInsert_PlanGimnasio @RutaPlanes;
        EXEC dbo.BulkInsert_Socio @RutaSocios;
        EXEC dbo.BulkInsert_Entrenador @RutaEntrenadores;
        EXEC dbo.BulkInsert_Clase @RutaClases;
        EXEC dbo.BulkInsert_Reserva @RutaReservas;
        EXEC dbo.BulkInsert_Factura @RutaFacturas;
        
        PRINT '';
        PRINT '========================================';
        PRINT '✓ TODOS LOS DATOS CARGADOS EXITOSAMENTE';
        PRINT '========================================';
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '========================================';
        PRINT '✗ ERROR EN LA CARGA';
        PRINT '========================================';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        PRINT 'Línea: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        THROW;
    END CATCH
END;
GO

-- 9. Procedimiento para limpiar todas las tablas
CREATE OR ALTER PROCEDURE dbo.LimpiarTodasLasTablas
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT '========================================';
        PRINT 'LIMPIANDO TODAS LAS TABLAS';
        PRINT '========================================';
        PRINT '';
        
        -- Orden inverso a las dependencias
        PRINT 'Limpiando contabilidad.Factura...';
        DELETE FROM contabilidad.Factura;
        
        PRINT 'Limpiando gestion_clases.Reserva...';
        DELETE FROM gestion_clases.Reserva;
        
        PRINT 'Limpiando gestion_clases.Clase...';
        DELETE FROM gestion_clases.Clase;
        
        PRINT 'Limpiando gestion_clases.Entrenador...';
        DELETE FROM gestion_clases.Entrenador;
        
        PRINT 'Limpiando gestion_socios.Socio...';
        DELETE FROM gestion_socios.Socio;
        
        PRINT 'Limpiando gestion_socios.PlanGimnasio...';
        DELETE FROM gestion_socios.PlanGimnasio;
        
        PRINT 'Limpiando gestion_clases.TipoClase...';
        DELETE FROM gestion_clases.TipoClase;
        
        PRINT '';
        PRINT 'Reseteando IDENTITY seeds...';
        
        -- Resetear identity seeds (con esquemas)
        DBCC CHECKIDENT ('contabilidad.Factura', RESEED, 0);
        DBCC CHECKIDENT ('gestion_clases.Reserva', RESEED, 0);
        DBCC CHECKIDENT ('gestion_clases.Clase', RESEED, 0);
        DBCC CHECKIDENT ('gestion_socios.Socio', RESEED, 0);
        DBCC CHECKIDENT ('gestion_socios.PlanGimnasio', RESEED, 0);
        
        PRINT '';
        PRINT '========================================';
        PRINT '✓ TODAS LAS TABLAS HAN SIDO LIMPIADAS';
        PRINT '========================================';
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '========================================';
        PRINT '✗ ERROR AL LIMPIAR TABLAS';
        PRINT '========================================';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- 10. Procedimiento para verificar datos cargados
CREATE OR ALTER PROCEDURE dbo.VerificarDatosCargados
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '========================================';
    PRINT 'VERIFICACIÓN DE DATOS CARGADOS';
    PRINT '========================================';
    PRINT '';
    
    -- Contar registros por tabla
    DECLARE @CountTipoClase INT = (SELECT COUNT(*) FROM gestion_clases.TipoClase);
    DECLARE @CountPlan INT = (SELECT COUNT(*) FROM gestion_socios.PlanGimnasio);
    DECLARE @CountSocio INT = (SELECT COUNT(*) FROM gestion_socios.Socio);
    DECLARE @CountEntrenador INT = (SELECT COUNT(*) FROM gestion_clases.Entrenador);
    DECLARE @CountClase INT = (SELECT COUNT(*) FROM gestion_clases.Clase);
    DECLARE @CountReserva INT = (SELECT COUNT(*) FROM gestion_clases.Reserva);
    DECLARE @CountFactura INT = (SELECT COUNT(*) FROM contabilidad.Factura);
    
    -- Mostrar resultados
    PRINT 'Esquema: gestion_clases';
    PRINT '  TipoClase:    ' + RIGHT('        ' + CAST(@CountTipoClase AS NVARCHAR), 8) + ' registros';
    PRINT '  Entrenador:   ' + RIGHT('        ' + CAST(@CountEntrenador AS NVARCHAR), 8) + ' registros';
    PRINT '  Clase:        ' + RIGHT('        ' + CAST(@CountClase AS NVARCHAR), 8) + ' registros';
    PRINT '  Reserva:      ' + RIGHT('        ' + CAST(@CountReserva AS NVARCHAR), 8) + ' registros';
    PRINT '';
    PRINT 'Esquema: gestion_socios';
    PRINT '  PlanGimnasio: ' + RIGHT('        ' + CAST(@CountPlan AS NVARCHAR), 8) + ' registros';
    PRINT '  Socio:        ' + RIGHT('        ' + CAST(@CountSocio AS NVARCHAR), 8) + ' registros';
    PRINT '';
    PRINT 'Esquema: contabilidad';
    PRINT '  Factura:      ' + RIGHT('        ' + CAST(@CountFactura AS NVARCHAR), 8) + ' registros';
    PRINT '';
    PRINT '========================================';
    PRINT 'TOTAL:          ' + RIGHT('        ' + CAST(
        @CountTipoClase + @CountPlan + @CountSocio + 
        @CountEntrenador + @CountClase + @CountReserva + @CountFactura 
        AS NVARCHAR), 8) + ' registros';
    PRINT '========================================';
END;
GO

-- Limpiar todas las tablas antes de carga
EXEC dbo.LimpiarTodasLasTablas;
GO

-- Cargar todos los datos desde csv. Modificar dirección de acuerdo a la carpeta que contenga los csvs
EXEC dbo.CargarTodosDesdeCsv @RutaCarpeta = 'C:\Users\Tenorio\OneDrive\Documents\admin\';
GO

-- Verificar datos cargados:
EXEC dbo.VerificarDatosCargados;
GO

-- ============================================
-- EXPORTACIÓN DE BASE DE DATOS
-- ============================================

-- Exportación de tablas
-- El valor de -S (servidor) debe ajustarse según el entorno donde se ejecturen los comandos, esta es el modelo:
-- bcp NombreEsquema.NombreTabla out "C:\ruta\archivo.csv" -c -t, -S <SERVIDOR> -d Gimnasio -T
-- Las líneas comentadas son las que se ejecturan en la consola de Windows Powershell

-- bcp --% Gimnasio.gestion_clases.TipoClase out "C:\Export\TipoClase.csv" -c -t, -S DESKTOP-HJJLKTE -T
-- bcp --% Gimnasio.gestion_clases.Entrenador out "C:\Export\Entrenador.csv" -c -t, -S DESKTOP-HJJLKTE -T
-- bcp --% Gimnasio.gestion_clases.Clase out "C:\Export\Clase.csv" -c -t, -S DESKTOP-HJJLKTE -T
-- bcp --% Gimnasio.gestion_clases.Reserva out "C:\Export\Reserva.csv" -c -t, -S DESKTOP-HJJLKTE -T

-- bcp --% Gimnasio.gestion_socios.Socio out "C:\Export\Socio.csv" -c -t, -S DESKTOP-HJJLKTE -T
-- bcp --% Gimnasio.gestion_socios.PlanGimnasio out "C:\Export\PlanGimnasio.csv" -c -t, -S DESKTOP-HJJLKTE -T

-- bcp --% Gimnasio.contabilidad.Factura out "C:\Export\Factura.csv" -c -t, -S DESKTOP-HJJLKTE -T

-- ============================================
-- EXPORTACIÓN DE BASE DE DATOS
-- ============================================
-- El valor de -S (servidor) debe ajustarse según el entorno donde se ejecturen los comandos, este es el modelo:
-- bcp --% Gimnasio.Esquema.Tabla in "C:\ruta\archivo.csv" -c -t, -S <SERVIDOR> -T
-- Las líneas comentadas son las que se ejecturan en la consola de Windows Powershell

-- Primero insertamos las tablas sin dependencias y a las que posean IDENTITY, activamos el IDENTITY_INSERT
-- bcp --% Gimnasio.gestion_clases.TipoClase in "C:\Export\TipoClase.csv" -c -t, -S DESKTOP-HJJLKTE -T

SET IDENTITY_INSERT gestion_socios.PlanGimnasio ON;
-- bcp --% Gimnasio.gestion_socios.PlanGimnasio in "C:\Export\PlanGimnasio.csv" -c -t, -S DESKTOP-HJJLKTE -T
SET IDENTITY_INSERT gestion_socios.PlanGimnasio OFF;

SET IDENTITY_INSERT gestion_socios.Socio ON;
-- bcp --% Gimnasio.gestion_socios.Socio in "C:\Export\Socio.csv" -c -t, -S DESKTOP-HJJLKTE -T
SET IDENTITY_INSERT gestion_socios.Socio OFF;

-- bcp --% Gimnasio.gestion_clases.Entrenador in "C:\Export\Entrenador.csv" -c -t, -S DESKTOP-HJJLKTE -T

SET IDENTITY_INSERT gestion_clases.Clase ON;
-- bcp --% Gimnasio.gestion_clases.Clase in "C:\Export\Clase.csv" -c -t, -S DESKTOP-HJJLKTE -T
SET IDENTITY_INSERT gestion_clases.Clase OFF;

SET IDENTITY_INSERT gestion_clases.Reserva ON;
-- bcp --% Gimnasio.gestion_clases.Reserva in "C:\Export\Reserva.csv" -c -t, -S DESKTOP-HJJLKTE -T
SET IDENTITY_INSERT gestion_clases.Reserva OFF;

SET IDENTITY_INSERT contabilidad.Factura ON;
-- bcp --% Gimnasio.contabilidad.Factura in "C:\Export\Factura.csv" -c -t, -S DESKTOP-HJJLKTE -T
SET IDENTITY_INSERT contabilidad.Factura OFF;

