# Proyecto Integrador - Módulo 4: Bases de Datos  
## Bootcamp Ingeniería de Datos – SOFOFA

Este repositorio contiene el desarrollo completo del Proyecto Integrador del Módulo 4: **Bases de Datos**, en el que se diseña e implementa un ecosistema compuesto por bases de datos **relacionales** y **NoSQL**, con base a un pipeline de datos proveniente del módulo anterior.

---

## 📁 Estructura del Repositorio

```

├── scripts/
│   └── importar_csv_clientes_ext.py
├── sql/
│   ├── 01_tabla_externa.sql
│   ├── 02_esquema_sql.sql
│   ├── 04_migracion_sql.sql
│   └── 05_pruebas.sql
├── NoSQL/
│   ├── mongo/
│   │   ├── scripts/
│   │   │   ├── 01_convertir_csv_a_json.py
│   │   │   ├── 02_importar_json_mongodb.py
│   │   │   ├── 03_agregar_cliente.py
│   │   │   └── 04_verificar_datos_insertos.py
│   ├── cassandra/
│   │   ├── 00_verificar_conexion.py
│   │   ├── 01_crear_keyspace_y_tabla.py
│   │   ├── 02_insertar_datos.py
│   │   ├── 03_verificar_datos.py
│   │   └── 04_agregar_cliente.py
│   └── dynamodb/
│       ├── 00_verificar_conexion.py
│       ├── 01_crear_tabla.py
│       ├── 02_insertar_datos.py
│       └── 03_verificar_datos.py
├── data/
│   ├── clientes_final2.csv
│   └── clientes.json
├── Ecosistema_Bases_Datos.drawio
├── README.md  ← (este archivo)

+ .doc con ejemplo de aplicación y resultados de aplicación flujo SQL.
```

---

## 🧩 Flujo de Ejecución Recomendado

### 🔁 Reinicio de todo el flujo (SQL)

1. Ejecutar `sql/01_tabla_externa.sql` para crear tabla `clientes_ext`.
2. Ejecutar `sql/02_esquema_sql.sql` para crear el modelo relacional completo.
3. Ejecutar `scripts/importar_csv_clientes_ext.py`. Aparecerán dos opciones:
   - Opción 1: Reiniciar base de datos completa sin importar datos (comenzar desde cero).
   - Opción 2: Solo importar datos desde CSV si la tabla ya está creada.
4. Ejecutar `sql/04_migracion_sql.sql` para migrar desde `clientes_ext`.
5. Ejecutar `sql/05_pruebas.sql` para validar integridad, vistas y triggers.

Para reiniciar el flujo, simplemente ejecuta de nuevo `importar_csv_clientes_ext.py` y elige la **opción 1**.

---

**Ejecutar el script Python para importar datos desde CSV:**  
   ```bash
   scripts/importar_csv_clientes_ext.py
   ```  
   Este script tiene dos modos:

   - **Opción 1: Reiniciar todo**  
     - Elimina la base de datos y estructuras existentes.  
     - No realiza ninguna importación.  
     - Permite comenzar desde 0, volviendo a ejecutar paso a paso desde el punto 1.

   - **Opción 2: Solo importar `clientes_ext` desde CSV**  
     - Útil si ya tienes la estructura creada y solo deseas volver a poblarla.

---

## 🔁 Reinicio del flujo

Luego de ejecutar `05_pruebas.sql`, si deseas **reiniciar completamente el proyecto desde cero**, simplemente vuelve a ejecutar el script Python:

```bash
scripts/importar_csv_clientes_ext.py
```

Y elige la **opción 1**: "Reiniciar base de datos completa (no importar nada)".  
Desde ahí podrás volver a aplicar todos los pasos desde el punto 1 hasta el 5.

---

## 🧠 Diseño del Ecosistema

### 🔷 Tecnologías Relacionales

- **PostgreSQL**: Utilizada como tecnología principal por su robustez, soporte de vistas materializadas, triggers y control transaccional completo.
- **MySQL**: Evaluada pero descartada por no soportar vistas materializadas nativamente.

### 🔷 Tecnologías No Relacionales

- **MongoDB**: Base de datos documental orientada a la gestión de perfiles de clientes y productos.
- **Apache Cassandra**: Modelo columnar distribuido para eventos históricos.
- **DynamoDB**: NoSQL en la nube con modelo clave-valor, ideal para trazabilidad serverless y escalabilidad automática.

---

### 🔷 SQL – PostgreSQL

- Se utilizó PostgreSQL por su capacidad de manejar vistas materializadas, triggers y operaciones OLTP.
- El modelo relacional se diseñó en 3FN a partir del dataset `clientes_ext`.
- Tablas: `clientes`, `productos`, `categorias`, `pedidos`, `detalle_pedido`.
- Claves primarias y foráneas garantizan integridad referencial.
- Se implementaron índices y una vista materializada para mejorar el rendimiento.

### 🔷 MongoDB

- Usado como base de datos documental.
- Flujo:
  1. Conversión de CSV a JSON.
  2. Importación de JSON a MongoDB (sobrescribe).
  3. Inserción manual de clientes.
  4. Verificación de datos.
- Base de datos: `abp_nosql`, colección: `clientes`.

### 🔷 Cassandra

- Modelo columnar distribuido.
- Flujo:
  1. Crear keyspace y tabla.
  2. Importar desde JSON.
  3. Agregar nuevos clientes manualmente.
  4. Verificar datos insertos.
- Ideal para lectura escalable y alta disponibilidad.

### 🔷 DynamoDB

- Servicio clave-valor totalmente serverless.
- Flujo:
  1. Crear tabla `clientes`.
  2. Insertar registros desde JSON.
  3. Agregar cliente individual.
  4. Verificar contenido.
- Ideal para alta escalabilidad con mínima administración.

---
## 🏗️ Modelo Relacional Normalizado

Basado en el dataset de clientes del módulo 3 (`clientes_ext`), se definió un modelo relacional con las siguientes entidades:

| Tabla           | Descripción                                |
|-----------------|--------------------------------------------|
| clientes        | Datos personales, edad, género, etc.       |
| productos       | Catálogo de productos                      |
| categorias      | Agrupación de productos                    |
| pedidos         | Registro de compras por cliente            |
| detalle_pedido  | Productos específicos en cada pedido       |

### Relación de Claves
```plaintext
clientes         1 ───────< pedidos
productos        1 ───────< detalle_pedido >────── 1    pedidos
categorias       1 ───────< productos
```

---

## ⚙️ Optimización del Modelo

- **Normalización a 3FN**
  - 1FN: Todos los atributos son atómicos.
  - 2FN: No hay dependencias parciales de clave.
  - 3FN: Se eliminaron dependencias transitivas.

- **Índices**: En `cliente_id`, `producto_id`, `fecha_pedido`.
- **Vista Materializada**: `resumen_clientes` para consolidar gasto por cliente.
- **Triggers**: Sincronización automática ante cambios relevantes.

---

## 📚 Justificación Técnica

| Tecnología   | Tipo         | Justificación                                                                 |
|--------------|--------------|------------------------------------------------------------------------------|
| PostgreSQL   | Relacional   | Soporte completo para integridad, vistas materializadas, triggers.           |
| MongoDB      | Documental   | Permite almacenar y consultar documentos flexibles con baja latencia.        |
| Cassandra    | Columnar     | Alta disponibilidad y escritura eficiente en volúmenes distribuidos.         |
| DynamoDB     | Clave-valor  | Serverless, escalabilidad automática y fácil integración en AWS.             |

MySQL fue considerado pero descartado por no soportar vistas materializadas.

---

## 🔄 Integración con Pipelines Anteriores

- Este proyecto reutiliza el dataset `clientes_ext` generado en el Módulo 3.
- Los datos se integran mediante un script Python (`importar_csv_clientes_ext.py`) que permite importar desde CSV a PostgreSQL.
- Luego, el mismo dataset es transformado a JSON para alimentar MongoDB, Cassandra y DynamoDB.
- Esto demuestra cómo un solo pipeline puede alimentar múltiples motores según el caso de uso.

---

## ✍️ Desarrollado por

**Catalina Millán Coronado**  
Estudiante del Bootcamp Ingeniería de Datos - Trabajo SOFOFA  Módulo 4
Año: 2025