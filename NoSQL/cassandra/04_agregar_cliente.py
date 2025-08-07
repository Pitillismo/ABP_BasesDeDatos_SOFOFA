from cassandra.cluster import Cluster

cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect('abp_cassandra')

print("🔧 Agregar nuevo cliente")
cliente_id = int(input("ID Cliente: "))
edad = int(input("Edad: "))
genero = input("Género (M/F): ")
gasto = float(input("Gasto: "))
fuente = input("Fuente (Online/Presencial): ")
gasto_anual = float(input("Gasto anual estimado: "))
genero_extendido = input("Género extendido: ")
grupo_etario = input("Grupo etario: ")
gasto_normalizado = float(input("Gasto normalizado (0.0 - 1.0): "))

session.execute("""
    INSERT INTO clientes (cliente_id, edad, genero, gasto, fuente,
                          gasto_anual_estimado, genero_extendido,
                          grupo_etario, gasto_normalizado)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
""", (
    cliente_id, edad, genero, gasto, fuente,
    gasto_anual, genero_extendido, grupo_etario,
    gasto_normalizado
))

print("✅ Cliente agregado correctamente.")
print(f"Cliente con ID {cliente_id} agregado correctamente.")