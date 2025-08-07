import boto3

try:
    dynamodb = boto3.resource(
        'dynamodb',
        region_name='us-east-1',
        endpoint_url='http://localhost:8000',
        aws_access_key_id='fakeMyKeyId',             # ← clave falsa
        aws_secret_access_key='fakeSecretAccessKey'  # ← clave falsa
    )

    tablas = list(dynamodb.tables.all())
    print("✅ Conexión establecida correctamente con DynamoDB")
    print("📦 Tablas existentes:")
    for tabla in tablas:
        print(f" - {tabla.name}")

except Exception as e:
    print("❌ Error al conectar con DynamoDB:", e)
