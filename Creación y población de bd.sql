CREATE DATABASE Gimnasio;
USE Gimnasio;

CREATE TABLE TipoClase(
	Id_tipo_clase VARCHAR(200) PRIMARY KEY,
	Nombre VARCHAR(150),
);

CREATE TABLE Entrenador (
	Dui VARCHAR(10) PRIMARY KEY,
	Nombre NVARCHAR(100) NOT NULL,
	Telefono VARCHAR(50),
	Correo_electronico VARCHAR(150),
	Salario DECIMAL (7,2) CHECK (Salario >= 0),
	Seguro VARCHAR(100)
);

CREATE TABLE PlanGimnasio(
	Id_plan INT PRIMARY KEY IDENTITY (1,1),
	Nombre_plan NVARCHAR(100) NOT NULL,
	Descripcion NVARCHAR(500),
	Costo DECIMAL (5,2),
	Duracion_dias INT NOT NULL CHECK (Duracion_dias > 0)
);

CREATE TABLE Socio(
	Id_socio INT PRIMARY KEY IDENTITY (1,1),
	Nombre NVARCHAR(150),
	Telefono VARCHAR(15),
	Correo_electronico VARCHAR(150),
	Fecha_registro DATE,
	Id_plan INT,
	FOREIGN KEY (Id_plan) REFERENCES PlanGimnasio(Id_plan)
);

CREATE TABLE dbo.Clase (
    Id_clase INT IDENTITY(1,1) PRIMARY KEY,
    Nombre_clase NVARCHAR(100) NOT NULL,
    Cupo INT NOT NULL CHECK (Cupo > 0),
    Dui VARCHAR(10) NOT NULL,
    Id_tipo_clase VARCHAR(200) NOT NULL,
    dia_clase TINYINT NOT NULL CHECK (dia_clase BETWEEN 1 AND 7),
    hora_clase TIME(0) NULL CHECK (
        DATEPART(MINUTE, hora_clase) = 0 AND
        DATEPART(SECOND, hora_clase) = 0
    ),
    CONSTRAINT FK_Clase_Entrenador FOREIGN KEY (Dui)
        REFERENCES dbo.Entrenador(Dui),
    CONSTRAINT FK_Clase_TipoClase FOREIGN KEY (Id_tipo_clase)
        REFERENCES dbo.TipoClase(Id_tipo_clase)
);


CREATE TABLE Factura(
	Id_factura INT PRIMARY KEY IDENTITY (1,1),
	Id_socio INT,
	Fecha DATETIME,
	Monto DECIMAL (10,2),
	Metodo_pago VARCHAR(100),
	Estado VARCHAR(100),
	FOREIGN KEY (Id_socio) REFERENCES Socio(Id_socio)
);

CREATE TABLE Reserva(
	Id_reserva INT PRIMARY KEY IDENTITY (1,1),
	fecha_reserva DATETIME2(0),
	Id_socio INT,
	FOREIGN KEY (Id_socio) REFERENCES Socio(Id_socio),
	Id_clase INT,
	FOREIGN KEY (Id_clase) REFERENCES Clase(Id_clase),
);

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

EXEC sp_spaceused;

