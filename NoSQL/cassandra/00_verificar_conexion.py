from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider

try:
    # Conexión local al contenedor de Docker en el puerto 9042
    cluster = Cluster(['127.0.0.1'], port=9042)

    # Establecer sesión (no requiere autenticación por defecto en Cassandra local)
    session = cluster.connect()

    print("✅ Conexión establecida correctamente con Cassandra.")

    # Listar keyspaces disponibles como prueba
    rows = session.execute("SELECT keyspace_name FROM system_schema.keyspaces;")
    print("📦 Keyspaces existentes:")
    for row in rows:
        print(f" - {row.keyspace_name}")

except Exception as e:
    print("❌ Error al conectar con Cassandra:", e)
