import pandas as pd
import json

# Ruta relativa correcta al archivo CSV desde la carpeta /NoSQL/mongo
csv_path = "../../../data/clientes_final2.csv"
json_path = "../../../data/clientes.json"

print("📂 Leyendo CSV...")
df = pd.read_csv(csv_path)

print(f"🔄 Transformando {len(df)} registros...")

data = df.to_dict(orient="records")

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print(f"✅ Archivo JSON generado: {json_path}")
