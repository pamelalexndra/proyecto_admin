

RESTORE DATABASE Gimnasio FROM DISK = 'C:\backups\Gimnasio.bak'

USE Gimnasio;

ALTER TABLE Entrenador ALTER COLUMN Salario DECIMAL(7,2);
ALTER TABLE Reserva ALTER COLUMN Fecha_reserva DATETIME2(0);

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS PARA BULK INSERT PARA POBLAR BASE
-- ============================================================

USE Gimnasio;
GO

-- ============================================================
-- 1. PROCEDIMIENTO PARA TIPOS DE CLASE
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_TipoClase
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando TipoClase desde: ' + @RutaArchivo;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT TipoClase
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK
        )';
        
        EXEC sp_executesql @SQL;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM TipoClase);
        PRINT CAST(@Count AS NVARCHAR) + ' tipos de clase insertados';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al cargar TipoClase: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

SELECT OBJECT_ID('dbo.sp_BulkInsert_TipoClase') AS ObjId;
SELECT * FROM sys.procedures WHERE name = 'sp_BulkInsert_TipoClase';

SELECT * FROM TipoClase;

-- ============================================================
-- 2. PROCEDIMIENTO PARA PLANES DE GIMNASIO
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_PlanGimnasio
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando PlanGimnasio desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT PlanGimnasio ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT PlanGimnasio
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
        
        SET IDENTITY_INSERT PlanGimnasio OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM PlanGimnasio);
        PRINT CAST(@Count AS NVARCHAR) + ' planes insertados';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT PlanGimnasio OFF;
        PRINT 'ERROR al cargar PlanGimnasio: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 3. PROCEDIMIENTO PARA SOCIOS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Socio
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Socios desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT Socio ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT Socio
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
        
        SET IDENTITY_INSERT Socio OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM Socio);
        PRINT CAST(@Count AS NVARCHAR) + ' socios insertados';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT Socio OFF;
        PRINT 'ERROR al cargar Socio: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 4. PROCEDIMIENTO PARA ENTRENADORES
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Entrenador
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Entrenadores desde: ' + @RutaArchivo;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT Entrenador
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
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM Entrenador);
        PRINT CAST(@Count AS NVARCHAR) + ' entrenadores insertados';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al cargar Entrenador: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 5. PROCEDIMIENTO PARA CLASES
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Clase
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Clases desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT Clase ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT Clase
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
        
        SET IDENTITY_INSERT Clase OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM Clase);
        PRINT CAST(@Count AS NVARCHAR) + ' clases insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT Clase OFF;
        PRINT 'ERROR al cargar Clase: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 6. PROCEDIMIENTO PARA RESERVAS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Reserva
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Reservas desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT Reserva ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT Reserva
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
        
        SET IDENTITY_INSERT Reserva OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM Reserva);
        PRINT CAST(@Count AS NVARCHAR) + ' reservas insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT Reserva OFF;
        PRINT 'ERROR al cargar Reserva: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 7. PROCEDIMIENTO PARA FACTURAS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.BulkInsert_Factura
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Cargando Facturas desde: ' + @RutaArchivo;
        
        SET IDENTITY_INSERT Factura ON;
        
        DECLARE @SQL NVARCHAR(MAX) = N'
        BULK INSERT Factura
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
        
        SET IDENTITY_INSERT Factura OFF;
        
        DECLARE @Count INT = (SELECT COUNT(*) FROM Factura);
        PRINT CAST(@Count AS NVARCHAR) + ' facturas insertadas';
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT Factura OFF;
        PRINT 'ERROR al cargar Factura: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 8. PROCEDIMIENTO MAESTRO - CARGAR TODO
-- ============================================================
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
        PRINT 'CARGANDO DATOS DESDE ARCHIVOS CSV';
        
        -- Orden correcto segun dependencias de FK
        EXEC dbo.BulkInsert_TipoClase @RutaTipoClase;
        EXEC dbo.BulkInsert_PlanGimnasio @RutaPlanes;
        EXEC dbo.BulkInsert_Socio @RutaSocios;
        EXEC dbo.BulkInsert_Entrenador @RutaEntrenadores;
        EXEC dbo.BulkInsert_Clase @RutaClases;
        EXEC dbo.BulkInsert_Reserva @RutaReservas;
        EXEC dbo.BulkInsert_Factura @RutaFacturas;
        
        PRINT 'TODOS LOS DATOS CARGADOS EXITOSAMENTE';
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT 'ERROR EN LA CARGA: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
-- ============================================================
-- 9. PROCEDIMIENTO PARA LIMPIAR TODAS LAS TABLAS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.LimpiarTodasLasTablas
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Limpiando todas las tablas...';
        
        -- Orden inverso a las dependencias
        DELETE FROM Factura;
        DELETE FROM Reserva;
        DELETE FROM Clase;
        DELETE FROM Entrenador;
        DELETE FROM Socio;
        DELETE FROM PlanGimnasio;
        DELETE FROM TipoClase;
        
        -- Resetear identity seeds
        DBCC CHECKIDENT ('Factura', RESEED, 0);
        DBCC CHECKIDENT ('Reserva', RESEED, 0);
        DBCC CHECKIDENT ('Clase', RESEED, 0);
        DBCC CHECKIDENT ('Socio', RESEED, 0);
        DBCC CHECKIDENT ('PlanGimnasio', RESEED, 0);
        
        PRINT 'Todas las tablas han sido limpiadas';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al limpiar tablas: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

EXEC dbo.LimpiarTodasLasTablas;

EXEC dbo.CargarTodosDesdeCsv 'C:\Users\Tenorio\OneDrive\Documents\admin\';

-- ============================================================
-- CREACIÓN DE USUARIOS Y ROLES
-- ============================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Contabilidad')
    EXEC('CREATE SCHEMA Contabilidad');
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolCatedratico')
    CREATE ROLE RolCatedratico;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolAdministrador')
    CREATE ROLE RolAdministrador;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolContabilidad')
    CREATE ROLE RolContabilidad;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolBackup')
    CREATE ROLE RolBackup;
GO

-- ROL CATEDRATICO
GRANT SELECT ON SCHEMA::dbo TO RolCatedratico;
GRANT SELECT ON SCHEMA::Operaciones TO RolCatedratico;
GRANT SELECT ON SCHEMA::Contabilidad TO RolCatedratico;
GRANT SELECT ON SCHEMA::Administracion TO RolCatedratico;
GRANT SELECT ON SCHEMA::Reportes TO RolCatedratico;
GRANT EXECUTE ON SCHEMA::Reportes TO RolCatedratico;

GRANT SELECT, INSERT, UPDATE ON Factura TO RolContabilidad;
GRANT SELECT ON Socio TO RolContabilidad;
GRANT SELECT ON Reserva TO RolContabilidad;
GRANT SELECT ON PlanGimnasio TO RolContabilidad;
GRANT SELECT ON Clase TO RolContabilidad;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Contabilidad TO RolContabilidad;
DENY INSERT, UPDATE, DELETE ON Socio TO RolContabilidad;
DENY INSERT, UPDATE, DELETE ON Reserva TO RolContabilidad;

-- ROL BACKUP
GRANT BACKUP DATABASE TO RolBackup;
GRANT BACKUP LOG TO RolBackup;
GRANT SELECT ON SCHEMA::dbo TO RolBackup;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'catedratico_db')
    CREATE USER catedratico_db WITH PASSWORD = '', 
        DEFAULT_SCHEMA = dbo;
GO

-- ========== USUARIOS ADMINISTRADORES (Estudiantes) ==========
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_estudiante1')
    CREATE USER admin_estudiante1 WITH PASSWORD = '', 
        DEFAULT_SCHEMA = dbo;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_estudiante2')
    CREATE USER admin_estudiante2 WITH PASSWORD = '', 
        DEFAULT_SCHEMA = dbo;
GO

-- ========== USUARIO DE CONTABILIDAD ==========
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'contabilidad_gym')
    CREATE USER contabilidad_gym WITH PASSWORD = '', 
        DEFAULT_SCHEMA = Contabilidad;
GO

-- ========== USUARIO DE BACKUP ==========
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'backup_admin')
    CREATE USER backup_admin WITH PASSWORD = '', 
        DEFAULT_SCHEMA = dbo;
GO

ALTER ROLE RolCatedratico ADD MEMBER catedratico_db;
ALTER ROLE RolAdministrador ADD MEMBER admin_estudiante1;
ALTER ROLE RolAdministrador ADD MEMBER admin_estudiante2;
ALTER ROLE RolContabilidad ADD MEMBER contabilidad_gym;
ALTER ROLE RolBackup ADD MEMBER backup_admin;
