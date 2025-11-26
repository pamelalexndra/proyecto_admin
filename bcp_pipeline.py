import subprocess
import os

SERVER = "DSKTOP-HJJKTE"
DATABASE = "Gimnasio"
EXPORT_DIR = r"C:\exports"

TABLES = [
    ("gestion_clases", "TipoClase"),
    ("gestion_socios", "PlanGimnasio"),
    ("gestion_socios", "Socio"),
    ("gestion_clases", "Entrenador"),
    ("gestion_clases", "Clase"),
    ("gestion_clases", "Reserva"),
    ("contabilidad", "Factura")
]

def run_bcp(command):
    print(f"Ejecutando: {command}")
    result = subprocess.run(command, shell=True)
    print("Código de salida:", result.returncode)
    print("-" * 60)


def export_table(esquema, tabla):
    print(f"\nExportando tabla: {esquema}.{tabla}")

    if not os.path.exists(EXPORT_DIR):
        os.makedirs(EXPORT_DIR)

    output_file = os.path.join(EXPORT_DIR, f"{tabla}.csv")

    cmd = (
        f'bcp {DATABASE}.{esquema}.{tabla} out "{output_file}" '
        f'-c -t, -T -S {SERVER}'
    )

    run_bcp(cmd)


def import_table(esquema, tabla, csv_path):
    print(f"\nImportando tabla: {esquema}.{tabla} desde {csv_path}")

    cmd = (
        f'bcp {DATABASE}.{esquema}.{tabla} in "{csv_path}" '
        f'-c -t, -T -S {SERVER}'
    )

    run_bcp(cmd)


def export_all():
    print("\n========== EXPORTANDO TODAS LAS TABLAS ==========")
    for esquema, tabla in TABLES:
        export_table(esquema, tabla)
    print("============ EXPORTACIÓN COMPLETADA =============\n")


def import_all():
    print("\n========== IMPORTANDO TODAS LAS TABLAS ==========")
    for esquema, tabla in TABLES:
        csv_path = os.path.join(EXPORT_DIR, f"{tabla}.csv")
        import_table(esquema, tabla, csv_path)
    print("============ IMPORTACIÓN COMPLETADA =============\n")


if __name__ == "__main__":
    export_all()
    # import_all()   # ← Descomentar si deseas importar todo otra vez
