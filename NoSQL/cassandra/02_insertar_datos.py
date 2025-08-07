from cassandra.cluster import Cluster
import json

# Cargar archivo JSON
with open('../../data/clientes.json', encoding="utf-8") as f:
    clientes = json.load(f)

# Conexión
cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect('abp_cassandra')

# Limpiar tabla
session.execute("TRUNCATE clientes")

# Insertar registros
for c in clientes:
    session.execute("""
        INSERT INTO clientes (cliente_id, edad, genero, gasto, fuente,
                              gasto_anual_estimado, genero_extendido,
                              grupo_etario, gasto_normalizado)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        c['cliente_id'], c['edad'], c['genero'], c['gasto'], c['fuente'],
        c['gasto_anual_estimado'], c['genero_extendido'], c['grupo_etario'],
        c['gasto_normalizado']
    ))

print(f"✅ {len(clientes)} clientes insertados en Cassandra.")
