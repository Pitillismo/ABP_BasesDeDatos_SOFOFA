from pymongo import MongoClient

try:
    print("🔌 Conectando a MongoDB...")
    client = MongoClient("mongodb://localhost:27017/")

    # Accede a una base de ejemplo
    db = client["test"]

    print("📚 Bases de datos disponibles:", client.list_database_names())
    print("✅ Conexión exitosa a MongoDB")

except Exception as e:
    print("❌ Error de conexión:", e)
