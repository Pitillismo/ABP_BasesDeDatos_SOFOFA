import boto3

# Conexión a DynamoDB local (docker)
dynamodb = boto3.resource(
    'dynamodb',
    region_name='us-east-1',
    endpoint_url='http://localhost:8000',
    aws_access_key_id='fakeMyKeyId',
    aws_secret_access_key='fakeSecretAccessKey'
)

# Crear tabla
tabla = dynamodb.create_table(
    TableName='clientes',
    KeySchema=[{'AttributeName': 'cliente_id', 'KeyType': 'HASH'}],
    AttributeDefinitions=[{'AttributeName': 'cliente_id', 'AttributeType': 'N'}],
    ProvisionedThroughput={'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
)

# Esperar a que se cree
tabla.wait_until_exists()

print("✅ Tabla 'clientes' creada correctamente.")
