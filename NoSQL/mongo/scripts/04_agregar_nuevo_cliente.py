from pymongo import MongoClient

# Conexión
client = MongoClient("mongodb://localhost:27017/")
db = client["abp_nosql"]
collection = db["clientes"]

# Ejemplo de nuevo cliente
nuevo_cliente = {
    "cliente_id": 999,
    "edad": 27,
    "genero": "F",
    "gasto": 43000,
    "fuente": "Instagram",
    "gasto_anual_estimado": 516000,
    "genero_extendido": "Femenino",
    "grupo_etario": "25-34",
    "gasto_normalizado": 0.68
}

# Insertar
result = collection.insert_one(nuevo_cliente)
print(f"✅ Cliente insertado con _id: {result.inserted_id}")
