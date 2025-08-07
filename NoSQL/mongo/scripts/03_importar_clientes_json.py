from pymongo import MongoClient
import json
import os

# Obtener ruta absoluta al JSON
json_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'data', 'clientes.json'))

# Conectar a MongoDB local
client = MongoClient("mongodb://localhost:27017/")
db = client["abp_nosql"]  # Usamos el mismo nombre de base de datos que en el flujo actual
collection = db["clientes"]

# Leer el JSON generado
with open(json_path, encoding="utf-8") as f:
    data = json.load(f)

print(f"📥 Insertando {len(data)} registros...")

# Insertar todos los registros (drop para evitar duplicados si se repite)
collection.drop()  # Reinicia colección
collection.insert_many(data)

print("✅ Datos insertados en MongoDB.")
