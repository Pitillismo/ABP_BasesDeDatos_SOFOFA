import boto3
from decimal import Decimal

# Conexión a DynamoDB local
dynamodb = boto3.resource(
    'dynamodb',
    region_name='us-east-1',
    endpoint_url='http://localhost:8000',
    aws_access_key_id='fakeMyKeyId',
    aws_secret_access_key='fakeSecretAccessKey'
)

tabla = dynamodb.Table('clientes')

# Formulario por consola
print("🧾 Agregar nuevo cliente")

cliente = {
    "cliente_id": int(input("ID Cliente: ")),
    "edad": int(input("Edad: ")),
    "genero": input("Género (M/F): "),
    "gasto": Decimal(input("Gasto: ")),
    "fuente": input("Fuente (Online/Presencial): "),
    "gasto_anual_estimado": Decimal(input("Gasto anual estimado: ")),
    "genero_extendido": input("Género extendido: "),
    "grupo_etario": input("Grupo etario: "),
    "gasto_normalizado": Decimal(input("Gasto normalizado (0.0 - 1.0): "))
}

# Insertar nuevo cliente
tabla.put_item(Item=cliente)

print("✅ Cliente agregado correctamente.")
