import pandas as pd
import psycopg2
import os
from datetime import datetime
from dotenv import load_dotenv

# ========= CARGAR VARIABLES DEL ARCHIVO .env ==========
load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

# ========= RUTA DEL ARCHIVO CSV Y LOG ==========
CSV_PATH = "data/clientes_final2.csv"
LOG_PATH = "outputs/import_log.txt"
os.makedirs("outputs", exist_ok=True)

try:
    log_lines = []
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_lines.append(f"\n[{now}] Inicio de ejecución")

    print("🔌 Conectando a la base de datos...")
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )
    cursor = conn.cursor()

    # === MODO DE USUARIO ===
    print("\nModo de ejecución:")
    print("1. Reiniciar base de datos completa (no importar nada)")
    print("2. Importar clientes_ext desde CSV")
    modo = input("Selecciona una opción (1 o 2): ").strip()

    if modo == "1":
        print("🧨 Reiniciando base de datos completa...")
        cursor.execute("""
            DROP MATERIALIZED VIEW IF EXISTS resumen_clientes CASCADE;
            TRUNCATE TABLE detalle_pedido, pedidos, productos, categorias, clientes, clientes_ext
            RESTART IDENTITY CASCADE;
        """)
        conn.commit()
        log_lines.append("🧹 Base de datos reiniciada (modo prueba completa).")
        print("✅ Base de datos reiniciada.")
        print("🚦 Puedes continuar ahora ejecutando los scripts en orden:\n1. 01_tabla_externa.sql\n2. 02_esquema_sql.sql\n3. importar_csv_clientes_ext.py (opción 2)\n4. 04_migracion_sql.sql\n5. 05_pruebas.sql")
        cursor.close()
        conn.close()
        exit()

    elif modo == "2":
        print("📂 Leyendo archivo CSV...")
        df = pd.read_csv(CSV_PATH)
        total = len(df)

        print(f"📥 Importando {total} registros a clientes_ext...")
        for _, row in df.iterrows():
            cursor.execute("""
                INSERT INTO clientes_ext (
                    cliente_id,
                    edad,
                    genero,
                    gasto,
                    fuente,
                    gasto_anual_estimado,
                    genero_extendido,
                    grupo_etario,
                    gasto_normalizado
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (cliente_id) DO NOTHING;
            """, (
                row["cliente_id"],
                row["edad"],
                row["genero"],
                row["gasto"],
                row["fuente"],
                row["gasto_anual_estimado"],
                row["genero_extendido"],
                row["grupo_etario"],
                row["gasto_normalizado"]
            ))

        conn.commit()
        log_lines.append(f"✅ Importación completada. Total registros importados: {total}")
        print(f"✅ Total importado: {total}")
        cursor.close()
        conn.close()

    else:
        raise ValueError("Opción inválida. Usa 1 o 2.")

except Exception as e:
    error_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_lines.append(f"❌ Error: {str(e)} - {error_time}")
    print(f"❌ Error: {str(e)}")

finally:
    with open(LOG_PATH, "a", encoding="utf-8") as log_file:
        for line in log_lines:
            log_file.write(line + "\n")
