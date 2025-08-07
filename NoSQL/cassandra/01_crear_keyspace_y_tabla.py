from cassandra.cluster import Cluster

# Conectar al clúster
cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect()  # ← Esto debe ir ANTES de usar `session`

# Crear keyspace si no existe
session.execute("""
    CREATE KEYSPACE IF NOT EXISTS abp_cassandra
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
""")

# Seleccionar el keyspace correcto
session.set_keyspace('abp_cassandra')

# Crear tabla 'clientes'
session.execute("""
    CREATE TABLE IF NOT EXISTS clientes (
        cliente_id int PRIMARY KEY,
        edad int,
        genero text,
        gasto float,
        fuente text,
        gasto_anual_estimado float,
        genero_extendido text,
        grupo_etario text,
        gasto_normalizado float
    )
""")

print("✅ Keyspace y tabla creados correctamente.")
