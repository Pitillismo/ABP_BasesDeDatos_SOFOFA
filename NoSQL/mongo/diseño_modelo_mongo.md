Flujo de Trabajo MongoDB:

Convertir CSV a JSON

python NoSQL/mongo/scripts/01_convertir_csv_a_json.py

Entrada: data/clientes_final2.csv

Salida: data/clientes.json

Importar JSON a MongoDB

python NoSQL/mongo/scripts/02_importar_json_mongodb.py

Conexión local a mongodb://localhost:27017/

Inserta 98 registros desde JSON (sobrescribe colección existente)

Agregar nuevo cliente manualmente

python NoSQL/mongo/scripts/03_agregar_cliente.py

Formulario por consola

Validación básica de campos

Verificar registros actuales

python NoSQL/mongo/scripts/04_verificar_datos_insertos.py

Muestra todos los clientes insertos

🔁 Si deseas reiniciar los datos de MongoDB:

Vuelve a ejecutar 02_importar_json_mongodb.py para borrar e insertar los 98 clientes del JSON original.