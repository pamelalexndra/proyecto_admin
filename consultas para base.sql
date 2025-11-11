-- Consultas para ver que todo bien
SELECT
  (SELECT COUNT(*) FROM socio) AS total_socios,
  (SELECT COUNT(*) FROM entrenador) AS total_entrenadores,
  (SELECT COUNT(*) FROM clase) AS total_clases,
  (SELECT COUNT(*) FROM reserva) AS total_reservas,
  (SELECT COUNT(*) FROM factura) AS total_facturas;

SELECT 'reservas' AS tabla, MIN(fecha_reserva), MAX(fecha_reserva) FROM reserva
UNION ALL
SELECT 'clases', MIN(dia_clase), MAX(dia_clase) FROM clase
UNION ALL
SELECT 'facturas', MIN(fecha), MAX(fecha) FROM factura;

SELECT r.Id_reserva, r.Id_socio
FROM reserva r
LEFT JOIN socio s ON r.Id_socio = s.Id_socio
WHERE s.Id_socio IS NULL

select r.Id_reserva, r.Id_clase from reserva r
left join clase c on r.Id_clase = c.Id_clase
where c.Id_clase IS NULL

select f.Id_factura, f.Id_socio from factura f
left join socio s on f.Id_socio = s.Id_socio
where s.Id_socio is null

-- Todo comienza en 2020
SELECT 
    'Socios' as Tabla,
    MIN(Fecha_registro) as Fecha_Min,
    MAX(Fecha_registro) as Fecha_Max,
    DATEDIFF(DAY, MIN(Fecha_registro), MAX(Fecha_registro)) as Dias_Diferencia
FROM Socio
UNION ALL
SELECT 
    'Reservas',
    MIN(fecha_reserva),
    MAX(fecha_reserva),
    DATEDIFF(DAY, MIN(fecha_reserva), MAX(fecha_reserva))
FROM Reserva
UNION ALL
SELECT 
    'Facturas',
    MIN(Fecha),
    MAX(Fecha),
    DATEDIFF(DAY, MIN(Fecha), MAX(Fecha))
FROM Factura;

-- Distribución de socios por plan

-- Verificar total de socios
SELECT COUNT(*) as Total_Socios FROM Socio;

-- Ver si hay socios sin plan
SELECT COUNT(*) as Socios_Sin_Plan 
FROM Socio 
WHERE Id_plan IS NULL;

-- Ver si hay socios con planes inexistentes
SELECT COUNT(*) as Socios_Plan_Invalido
FROM Socio s
WHERE Id_plan IS NOT NULL 
AND NOT EXISTS (SELECT 1 FROM PlanGimnasio p WHERE p.Id_plan = s.Id_plan);

-- Ver distribución real
SELECT 
    ISNULL(p.Nombre_plan, 'SIN PLAN') as Plan,
    COUNT(s.Id_socio) as Total_Socios
FROM Socio s
LEFT JOIN PlanGimnasio p ON s.Id_plan = p.Id_plan
GROUP BY p.Nombre_plan
ORDER BY Total_Socios DESC;

-- CORRECTO: LEFT JOIN desde Socio
SELECT 
    ISNULL(p.Nombre_plan, 'Sin Plan Asignado') as Nombre_plan,
    COUNT(s.Id_socio) as Total_Socios,
    CAST(COUNT(s.Id_socio) * 100.0 / (SELECT COUNT(*) FROM Socio) AS DECIMAL(5,2)) as Porcentaje,
    AVG(p.Costo) as Costo_Plan
FROM Socio s
LEFT JOIN PlanGimnasio p ON s.Id_plan = p.Id_plan
GROUP BY p.Nombre_plan, p.Costo
ORDER BY Total_Socios DESC;

-- Ver qué IDs de plan están usando los socios
SELECT 
    s.Id_plan,
    COUNT(*) as Cantidad_Socios
FROM Socio s
GROUP BY s.Id_plan
ORDER BY s.Id_plan;

-- Ver qué planes existen realmente
SELECT Id_plan, Nombre_plan 
FROM PlanGimnasio 
ORDER BY Id_plan;

-- Ver socios con planes que NO existen
SELECT 
    s.Id_plan as Plan_Invalido,
    COUNT(*) as Cantidad_Socios
FROM Socio s
WHERE s.Id_plan NOT IN (SELECT Id_plan FROM PlanGimnasio)
GROUP BY s.Id_plan;

-- 4. Carga de trabajo por entrenador
SELECT 
    e.Nombre as Entrenador,
    COUNT(c.Id_clase) as Total_Clases,
    COUNT(DISTINCT c.Id_tipo_clase) as Tipos_Clase_Distintos,
    AVG(c.Cupo) as Cupo_Promedio
FROM Entrenador e
LEFT JOIN Clase c ON e.Dui = c.Dui
GROUP BY e.Nombre
ORDER BY Total_Clases DESC;

-- 5. Ocupación promedio de clases
SELECT 
    tc.Nombre as Tipo_Clase,
    COUNT(DISTINCT c.Id_clase) as Total_Clases,
    AVG(c.Cupo) as Cupo_Promedio,
    COUNT(r.Id_reserva) as Total_Reservas,
    CAST(COUNT(r.Id_reserva) * 1.0 / (COUNT(DISTINCT c.Id_clase) * AVG(c.Cupo)) * 100 AS DECIMAL(5,2)) as Porcentaje_Ocupacion
FROM TipoClase tc
JOIN Clase c ON tc.Id_tipo_clase = c.Id_tipo_clase
LEFT JOIN Reserva r ON c.Id_clase = r.Id_clase
GROUP BY tc.Nombre
ORDER BY Porcentaje_Ocupacion DESC;

-- 6. Actividad de socios (reservas por socio)
SELECT 
    'Muy Activos (>50 reservas)' as Categoria,
    COUNT(*) as Cantidad_Socios
FROM (
    SELECT Id_socio, COUNT(*) as Total_Reservas
    FROM Reserva
    GROUP BY Id_socio
    HAVING COUNT(*) > 50
) sub
UNION ALL
SELECT 
    'Activos (20-50 reservas)',
    COUNT(*)
FROM (
    SELECT Id_socio, COUNT(*) as Total_Reservas
    FROM Reserva
    GROUP BY Id_socio
    HAVING COUNT(*) BETWEEN 20 AND 50
) sub
UNION ALL
SELECT 
    'Poco Activos (5-19 reservas)',
    COUNT(*)
FROM (
    SELECT Id_socio, COUNT(*) as Total_Reservas
    FROM Reserva
    GROUP BY Id_socio
    HAVING COUNT(*) BETWEEN 5 AND 19
) sub
UNION ALL
SELECT 
    'Inactivos (<5 reservas)',
    COUNT(*)
FROM (
    SELECT Id_socio, COUNT(*) as Total_Reservas
    FROM Reserva
    GROUP BY Id_socio
    HAVING COUNT(*) < 5
) sub;

-- 8. Horarios más populares (por reservas)
SELECT TOP 10
    CASE c.dia_clase
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END as Dia,
    DATEPART(HOUR, c.hora_clase) as Hora,
    COUNT(r.Id_reserva) as Total_Reservas,
    AVG(c.Cupo) as Cupo_Promedio
FROM Clase c
LEFT JOIN Reserva r ON c.Id_clase = r.Id_clase
GROUP BY c.dia_clase, DATEPART(HOUR, c.hora_clase), c.Cupo
ORDER BY Total_Reservas DESC;

-- 9. Análisis de facturas por socio
SELECT 
    AVG(Total_Facturas) as Promedio_Facturas_Por_Socio,
    MIN(Total_Facturas) as Minimo,
    MAX(Total_Facturas) as Maximo,
    AVG(Monto_Total) as Promedio_Pagado
FROM (
    SELECT 
        Id_socio,
        COUNT(*) as Total_Facturas,
        SUM(Monto) as Monto_Total
    FROM Factura
    GROUP BY Id_socio
) sub;

-- 10. Ingresos mensuales (últimos 12 meses)
SELECT 
    YEAR(Fecha) as Año,
    MONTH(Fecha) as Mes,
    COUNT(*) as Total_Facturas,
    SUM(Monto) as Ingresos_Total,
    AVG(Monto) as Ticket_Promedio
FROM Factura
WHERE Fecha >= DATEADD(MONTH, -12, GETDATE())
GROUP BY YEAR(Fecha), MONTH(Fecha)
ORDER BY Año DESC, Mes DESC;

SELECT 
    Estado,
    COUNT(*) as Total,
    SUM(Monto) as Monto_Total,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Factura) AS DECIMAL(5,2)) as Porcentaje
FROM Factura
GROUP BY Estado;

-- 13. Verificar clases sobresaturadas (más reservas que cupo)
SELECT 
    c.Id_clase,
    c.Nombre_clase,
    c.Cupo,
    COUNT(r.Id_reserva) as Reservas_Actuales
FROM Clase c
LEFT JOIN Reserva r ON c.Id_clase = r.Id_clase
GROUP BY c.Id_clase, c.Nombre_clase, c.Cupo
HAVING COUNT(r.Id_reserva) > c.Cupo;

-- 14. Socios sin reservas
SELECT COUNT(*) as Socios_Sin_Reservas
FROM Socio s
WHERE NOT EXISTS (SELECT 1 FROM Reserva r WHERE r.Id_socio = s.Id_socio);

SELECT 
    s.Id_socio,
    s.Nombre,
    COUNT(DISTINCT r.Id_reserva) as Total_Reservas,
    COUNT(DISTINCT f.Id_factura) as Facturas_Atrasadas
FROM Socio s
INNER JOIN Reserva r ON s.Id_socio = r.Id_socio
INNER JOIN Factura f ON s.Id_socio = f.Id_socio
WHERE f.Estado IN ('Atrasada', 'Cancelada')
GROUP BY s.Id_socio, s.Nombre;
SELECT 
    'Total Socios' as Metrica,
    COUNT(*) as Valor
FROM Socio
UNION ALL
SELECT 
    'Socios con Reservas',
    COUNT(DISTINCT Id_socio)
FROM Reserva
UNION ALL
SELECT 
    'Socios con Facturas Atrasadas',
    COUNT(DISTINCT Id_socio)
FROM Factura
WHERE Estado = 'Atrasada'
UNION ALL
SELECT 
    'Socios CON Reservas Y Facturas Atrasadas (DEBE SER 0)',
    COUNT(DISTINCT s.Id_socio)
FROM Socio s
WHERE EXISTS (SELECT 1 FROM Reserva r WHERE r.Id_socio = s.Id_socio)
  AND EXISTS (SELECT 1 FROM Factura f WHERE f.Id_socio = s.Id_socio AND f.Estado = 'Atrasada');