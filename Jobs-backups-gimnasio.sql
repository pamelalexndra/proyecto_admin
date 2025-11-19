/*
===============================================================================================
 Job: Backup Completo Gimnasio
===============================================================================================
*/
USE msdb
GO

-- Crear el job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup Completo Gimnasio',
    @description = N'Backup completo de BD Gimnasio - Domingos y Jueves 2:00 AM',
    @enabled = 1;

-- Agregar paso del job
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup Completo Gimnasio',
    @step_name = N'Ejecutar Backup Completo',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE [Gimnasio] TO DISK = ''C:\backups\Gimnasio-full.bak'' WITH INIT, STATS = 10',
    @retry_attempts = 3,
    @retry_interval = 5;

-- Agregar schedule para domingos y jueves a las 2:00 am
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule Backup Completo',
    @freq_type = 8, -- Weekly
    @freq_interval = 65, -- Domingo (1) + Jueves (64) = 65
    @freq_subday_type = 1, -- Una vez al día
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 20000; -- 2:00:00 AM

-- Asociar schedule al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Backup Completo Gimnasio',
    @schedule_name = N'Schedule Backup Completo';

-- Agregar job server
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Backup Completo Gimnasio';

/*
===============================================================================================
Job: Backup Diferencial Gimnasio
===============================================================================================
*/
-- Crear el job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup Diferencial Gimnasio',
    @description = N'Backup diferencial de BD Gimnasio - Diario 3:00 PM',
    @enabled = 1;

-- Agregar paso del job
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup Diferencial Gimnasio',
    @step_name = N'Ejecutar Backup Diferencial',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE [Gimnasio] TO DISK = ''C:\backups\Gimnasio-diff.bak'' WITH DIFFERENTIAL, INIT, STATS = 10',
    @retry_attempts = 3,
    @retry_interval = 5;

-- Agregar schedule diario a las 3:00 pm
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule Backup Diferencial',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 1, -- Una vez al día
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 150000; -- 15:00:00 (3:00 PM)

-- Asociar schedule al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Backup Diferencial Gimnasio',
    @schedule_name = N'Schedule Backup Diferencial';

-- Agregar job server
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Backup Diferencial Gimnasio';

/*
===============================================================================================
Job: Backup Log/Incremental Gimnasio
===============================================================================================
*/
-- Crear el job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup Log Gimnasio',
    @description = N'Backup de log de BD Gimnasio - Cada 6 horas empezando a la 1:00 AM',
    @enabled = 1;

-- Agregar paso del job
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup Log Gimnasio',
    @step_name = N'Ejecutar Backup Log',
    @subsystem = N'TSQL',
    @command = N'BACKUP LOG [Gimnasio] TO DISK = ''C:\backups\Gimnasio-log.trn'' WITH INIT, STATS = 10',
    @retry_attempts = 3,
    @retry_interval = 5;

-- Agregar schedule cada 6 horas empezando a la 1:00 AM
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule Backup Log',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 8, -- Horas
    @freq_subday_interval = 6, -- Cada 6 horas
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_time = 10000; -- 1:00:00 AM (CORREGIDO)

-- Asociar schedule al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Backup Log Gimnasio',
    @schedule_name = N'Schedule Backup Log';

-- Agregar job server
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Backup Log Gimnasio';

--Verificar Jobs creados
SELECT name, description, enabled 
FROM msdb.dbo.sysjobs 
WHERE name LIKE '%Gimnasio%';