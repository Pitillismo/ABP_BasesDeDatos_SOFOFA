from cassandra.cluster import Cluster

# Conectar a Cassandra
cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect('abp_cassandra')

# Mostrar 10 primeros clientes
rows = session.execute("SELECT * FROM clientes LIMIT 10")

print("📋 Primeros 10 clientes registrados:")
for row in rows:
    print(row._asdict())  # ✅ Forma correcta

# Contar todos los registros
rows = session.execute("SELECT * FROM clientes")
count = 0
for row in rows:
    count += 1

print(f"\n🔎 Total de clientes encontrados: {count}")


rows = session.execute("SELECT cliente_id FROM clientes")
ids = [row.cliente_id for row in rows]
print("IDs existentes:", ids)


