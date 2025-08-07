import boto3
import json
from decimal import Decimal

# Función para convertir floats a Decimal
def convertir_a_decimal(obj):
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convertir_a_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convertir_a_decimal(i) for i in obj]
    else:
        return obj

# Conexión a DynamoDB local
dynamodb = boto3.resource(
    'dynamodb',
    region_name='us-east-1',
    endpoint_url='http://localhost:8000',
    aws_access_key_id='fakeMyKeyId',
    aws_secret_access_key='fakeSecretAccessKey'
)

# Leer JSON
with open('../../data/clientes.json', encoding='utf-8') as f:
    clientes = json.load(f)

# Convertir floats a Decimal
clientes = [convertir_a_decimal(c) for c in clientes]

# Tabla
tabla = dynamodb.Table('clientes')

# Insertar
for cliente in clientes:
    tabla.put_item(Item=cliente)

print(f"✅ {len(clientes)} clientes insertados en DynamoDB.")
