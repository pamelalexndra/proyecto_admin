@echo off
echo ===============================================
echo EXPORTANDO TABLAS DE LA BASE DE DATOS GIMNASIO
echo Servidor: DSKTOP-HJJKTE
echo Carpeta: C:\exports
echo Autenticación: Windows
echo ===============================================
echo.

REM Crear carpeta si no existe
if not exist "C:\exports" (
    echo Creando carpeta C:\exports
    mkdir C:\exports
)

REM ============================
REM 1. gestion_clases.TipoClase
REM ============================
echo Exportando TipoClase...
bcp Gimnasio.gestion_clases.TipoClase out "C:\exports\tipo_clase.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 2. gestion_socios.PlanGimnasio
REM ============================
echo Exportando PlanGimnasio...
bcp Gimnasio.gestion_socios.PlanGimnasio out "C:\exports\plan_gimnasio.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 3. gestion_socios.Socio
REM ============================
echo Exportando Socio...
bcp Gimnasio.gestion_socios.Socio out "C:\exports\socio.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 4. gestion_clases.Entrenador
REM ============================
echo Exportando Entrenador...
bcp Gimnasio.gestion_clases.Entrenador out "C:\exports\entrenador.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 5. gestion_clases.Clase
REM ============================
echo Exportando Clase...
bcp Gimnasio.gestion_clases.Clase out "C:\exports\clase.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 6. gestion_clases.Reserva
REM ============================
echo Exportando Reserva...
bcp Gimnasio.gestion_clases.Reserva out "C:\exports\reserva.csv" -c -t , -T -S DSKTOP-HJJKTE

REM ============================
REM 7. contabilidad.Factura
REM ============================
echo Exportando Factura...
bcp Gimnasio.contabilidad.Factura out "C:\exports\factura.csv" -c -t , -T -S DSKTOP-HJJKTE

echo.
echo ===============================================
echo EXPORTACIÓN COMPLETADA EXITOSAMENTE.
echo Archivos generados en C:\exports
echo ===============================================
pause
