from pymongo import MongoClient

# Conectar al servidor MongoDB en localhost
client = MongoClient("mongodb://localhost:27017/")

# Seleccionar la base de datos y la colección
db = client["abp_nosql"]
coleccion = db["clientes"]

# Contar registros
total = coleccion.count_documents({})
print(f"📊 Total de documentos en la colección: {total}")

# Mostrar los primeros 5 documentos
print("\n🧾 Muestra de registros:")
for doc in coleccion.find().limit(5):
    print(doc)
