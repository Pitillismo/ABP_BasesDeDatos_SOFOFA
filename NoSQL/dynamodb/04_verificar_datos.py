import boto3

# Conexión a DynamoDB local
dynamodb = boto3.resource(
    'dynamodb',
    region_name='us-east-1',
    endpoint_url='http://localhost:8000',
    aws_access_key_id='fakeMyKeyId',
    aws_secret_access_key='fakeSecretAccessKey'
)

tabla = dynamodb.Table('clientes')

# Escanear todos los registros
print("🔍 Verificando clientes registrados...")
response = tabla.scan()
clientes = response.get('Items', [])

# Mostrar resultados
if clientes:
    print(f"✅ Se encontraron {len(clientes)} clientes:")
    for c in clientes:
        print(c)
else:
    print("⚠️ No se encontraron registros en la tabla.")
