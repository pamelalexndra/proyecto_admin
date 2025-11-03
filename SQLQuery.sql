
RESTORE DATABASE Gimnasio FROM DISK = 'C:\backups\Gimnasio.bak'

DROP DATABASE Gimnasio;

USE Gimnasio;

USE master;

ALTER TABLE Entrenador ALTER COLUMN Salario DECIMAL(7,2);
ALTER TABLE Reserva ALTER COLUMN Fecha_reserva DATETIME2(0);

SELECT * FROM Entrenador;

SELECT * FROM PlanGimnasio


-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS PARA BULK INSERT
-- Base de Datos: Gimnasio
-- ============================================================

USE Gimnasio;
GO

-- ============================================================
-- 1. PROCEDIMIENTO PARA TIPOS DE CLASE
-- ============================================================
CREATE OR ALTER PROCEDURE sp_BulkInsert_TipoClase
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

-- ============================================================
-- 2. PROCEDIMIENTO PARA PLANES DE GIMNASIO
-- ============================================================
CREATE OR ALTER PROCEDURE sp_BulkInsert_PlanGimnasio
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
CREATE OR ALTER PROCEDURE sp_BulkInsert_Socio
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
CREATE OR ALTER PROCEDURE sp_BulkInsert_Entrenador
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
CREATE OR ALTER PROCEDURE sp_BulkInsert_Clase
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
CREATE OR ALTER PROCEDURE sp_BulkInsert_Reserva
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
CREATE OR ALTER PROCEDURE sp_BulkInsert_Factura
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
CREATE OR ALTER PROCEDURE sp_CargarTodosDesdeCsv
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
        
        -- Orden correcto según dependencias de FK
        EXEC sp_BulkInsert_TipoClase @RutaTipoClase;
        EXEC sp_BulkInsert_PlanGimnasio @RutaPlanes;
        EXEC sp_BulkInsert_Socio @RutaSocios;
        EXEC sp_BulkInsert_Entrenador @RutaEntrenadores;
        EXEC sp_BulkInsert_Clase @RutaClases;
        EXEC sp_BulkInsert_Reserva @RutaReservas;
        EXEC sp_BulkInsert_Factura @RutaFacturas;
        
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
CREATE OR ALTER PROCEDURE sp_LimpiarTodasLasTablas
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

EXEC sp_LimpiarTodasLasTablas;
EXEC sp_CargarTodosDesdeCsv 'C:\datos\';

EXEC sp_CargarTodosDesdeCsv 'C:\Users\Tenorio\OneDrive\Documents\admin\';

SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila_estimada, *
FROM dbo.Clase_Staging
WHERE TRY_CAST(Cupo AS INT) IS NULL
  AND (Cupo IS NOT NULL AND LTRIM(RTRIM(Cupo)) <> '');
