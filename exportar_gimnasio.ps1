Write-Host "==============================================="
Write-Host "EXPORTANDO TABLAS DE LA BASE 'Gimnasio'"
Write-Host "Servidor: DSKTOP-HJJKTE"
Write-Host "Carpeta: C:\exports"
Write-Host "Autenticación: Windows"
Write-Host "==============================================="
Write-Host ""

# Crear carpeta si no existe
$exportPath = "C:\exports"
if (-Not (Test-Path $exportPath)) {
    Write-Host "Creando carpeta C:\exports"
    New-Item -ItemType Directory -Path $exportPath | Out-Null
}

# Función para exportar con BCP
function Exportar-Tabla {
    param(
        [string]$Tabla,
        [string]$Archivo
    )

    Write-Host "Exportando $Tabla..."
    $cmd = "bcp Gimnasio.$Tabla out `"$Archivo`" -c -t , -T -S DSKTOP-HJJKTE"
    Invoke-Expression $cmd
}

# Lista de tablas
$tablas = @{
    "gestion_clases.TipoClase" = "$exportPath\tipo_clase.csv";
    "gestion_socios.PlanGimnasio" = "$exportPath\plan_gimnasio.csv";
    "gestion_socios.Socio" = "$exportPath\socio.csv";
    "gestion_clases.Entrenador" = "$exportPath\entrenador.csv";
    "gestion_clases.Clase" = "$exportPath\clase.csv";
    "gestion_clases.Reserva" = "$exportPath\reserva.csv";
    "contabilidad.Factura" = "$exportPath\factura.csv";
}

# Exportar todas las tablas
foreach ($t in $tablas.Keys) {
    Exportar-Tabla -Tabla $t -Archivo $tablas[$t]
}

Write-Host ""
Write-Host "==============================================="
Write-Host "EXPORTACIÓN COMPLETADA EXITOSAMENTE."
Write-Host "Archivos generados en C:\exports"
Write-Host "==============================================="
