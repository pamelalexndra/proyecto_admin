USE GimnasioBD;
GO

/* CONSULTAS/REPORTES DE AN�LISIS (FUNCIONES VENTANA) */


-- 1. Tendencia de Facturaci�n Mensual con Crecimiento 
-- Muestra cu�nto creci� la facturaci�n comparada con el mes anterior usando LAG.
SELECT 
    FORMAT(f.Fecha, 'yyyy-MM') as mes,
    SUM(f.Monto) as facturacion_mes,
    LAG(SUM(f.Monto)) OVER(ORDER BY MIN(f.Fecha)) as facturacion_mes_anterior,
    SUM(f.Monto) - LAG(SUM(f.Monto)) OVER(ORDER BY MIN(f.Fecha)) as crecimiento_absoluto,
    ((SUM(f.Monto) - LAG(SUM(f.Monto)) OVER(ORDER BY MIN(f.Fecha))) 
     * 100.0 / LAG(SUM(f.Monto)) OVER(ORDER BY MIN(f.Fecha))) as crecimiento_porcentual
FROM contabilidad.Factura f
WHERE f.Estado = 'Pagada'
GROUP BY FORMAT(f.Fecha, 'yyyy-MM')
ORDER BY mes;

-- 2. Ranking de Entrenadores por Salario
-- Muestra la posici�n de cada entrenador seg�n su sueldo y qu� % del total representa.
SELECT 
    e.Dui,
    e.Nombre,
    e.Salario,
    RANK() OVER(ORDER BY e.Salario DESC) AS ranking_salario,
    ROUND(e.Salario * 100.0 / SUM(e.Salario) OVER(), 2) AS porcentaje_del_total_salarial
FROM gestion_clases.Entrenador e
LEFT JOIN gestion_clases.Clase c ON e.Dui = c.Dui
GROUP BY e.Dui, e.Nombre, e.Salario, e.Seguro
ORDER BY e.Salario DESC;

-- 3. Ranking de horarios preferidos agrupados por Tipo de Clase 
-- Identifica la hora pico para cada disciplina (Yoga, Crossfit, etc.)
SELECT 
    tc.Nombre AS Tipo_De_Clase,
    c.hora_clase,
    COUNT(r.Id_reserva) AS Total_Reservas,
    DENSE_RANK() OVER (
        PARTITION BY tc.Nombre 
        ORDER BY COUNT(r.Id_reserva) DESC
    ) AS Ranking_Horario
FROM 
    gestion_clases.Clase c
JOIN 
    gestion_clases.TipoClase tc ON c.Id_tipo_clase = tc.Id_tipo_clase
LEFT JOIN 
    gestion_clases.Reserva r ON c.Id_clase = r.Id_clase
GROUP BY 
    tc.Nombre, 
    c.hora_clase
ORDER BY 
    tc.Nombre, 
    Ranking_Horario;

-- 4. Ranking mensual de entrenadores seg�n volumen clases impartidas
-- Muestra la evoluci�n del desempe�o de los entrenadores mes a mes.
-- Ranking mensual de clases impartidas (Sesiones �nicas)
SELECT 
    YEAR(r.fecha_reserva) AS Anio,
    DATENAME(MONTH, r.fecha_reserva) AS Mes,
    e.Nombre AS Nombre_Entrenador,
    COUNT(DISTINCT r.fecha_reserva) AS Cantidad_Clases_Impartidas, 
    
    DENSE_RANK() OVER (
        PARTITION BY YEAR(r.fecha_reserva), MONTH(r.fecha_reserva) 
        ORDER BY COUNT(DISTINCT r.fecha_reserva) DESC 
    ) AS Ranking_Mensual
FROM 
    gestion_clases.Entrenador e 
JOIN 
    gestion_clases.Clase c ON e.Dui = c.Dui
JOIN 
    gestion_clases.Reserva r ON c.Id_clase = r.Id_clase
GROUP BY 
    YEAR(r.fecha_reserva), 
    MONTH(r.fecha_reserva), 
    DATENAME(MONTH, r.fecha_reserva),
    e.Nombre
ORDER BY 
    Anio DESC, 
    MONTH(r.fecha_reserva) DESC, 
    Ranking_Mensual ASC;

    /* CREACI�N DE �NDICES */


/* Consulta 1: Tendencia de Facturaci�n. Filtra por Estado y ordena por Fecha. */
CREATE NONCLUSTERED INDEX IX_Factura_Estado_Fecha_Monto
ON contabilidad.Factura (Estado, Fecha) INCLUDE (Monto);

/* Consulta 2: Ranking Salarios. Ordena f�sicamente los salarios. */
CREATE NONCLUSTERED INDEX IX_Entrenador_Salario
ON gestion_clases.Entrenador (Salario DESC) INCLUDE (Nombre);

/* Consultas 2 y 4: Soporte para JOINS con la tabla Entrenador. */
CREATE NONCLUSTERED INDEX IX_Clase_Dui
ON gestion_clases.Clase (Dui);

/* Consulta 3: Ranking Horarios. Optimiza el agrupamiento por Tipo y Hora. */
CREATE NONCLUSTERED INDEX IX_Clase_IdTipo_Hora
ON gestion_clases.Clase (Id_tipo_clase, hora_clase);

/* Consultas 3 y 4: Soporte cr�tico para JOINS de Reservas y an�lisis temporal. */
CREATE NONCLUSTERED INDEX IX_Reserva_IdClase_Fecha
ON gestion_clases.Reserva (Id_clase, fecha_reserva);

GO

-- Salud de los indices
SELECT
    t.name AS Tabla,
    i.name AS Indice,
    i.type_desc AS TipoIndice,
    i.is_primary_key AS EsClavePrimaria,
    i.is_unique AS EsUnico,
    c.name AS Columna,
    ips.avg_fragmentation_in_percent AS Fragmentacion
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
OUTER APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, 'LIMITED') ips
WHERE t.is_ms_shipped = 0
ORDER BY t.name, i.name, ic.key_ordinal;
