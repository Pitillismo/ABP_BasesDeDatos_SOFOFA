# Proyecto Integrador - Módulo 4: Bases de Datos.
# Bootcamp Ingenieria de Datos.
Este repositorio contiene el desarrollo completo del proyecto integrador del Módulo 4 del curso de Ingeniería de Datos - SOFOFA.

## Contenido

- `Leccion_1_Seleccion_Tecnologias.docx`: Documento técnico con la justificación de tecnologías relacionales y NoSQL seleccionadas.
- `Ecosistema_Bases_Datos.drawio`: Diagrama integrador que representa la arquitectura de bases de datos propuesta.
- `scripts/`: En esta carpeta se almacenarán los scripts de creación, inserción y consultas para cada base de datos (SQL, CQL, .json o .js).
- `documentacion/`: Incluirá los archivos explicativos por lección, con decisiones técnicas y justificaciones. Además se explicará la integración con lospipeline de datos desarrollados anteriormente.

## Tecnologías Seleccionadas

### Relacionales
- **PostgreSQL**: Principal motor utilizado por su soporte a vistas materializadas, triggers e integridad transaccional.
- **MySQL**: Analizado pero descartado por no soportar vistas materializadas de forma nativa.

### No Relacionales
- **MongoDB** (documental)
- **Apache Cassandra** (columnar)
- **DynamoDB** (clave-valor, serverless en AWS)

### Diseño del modelo relacional

El modelo parte del dataset `df_clientes` (módulo 3), y se extiende a una arquitectura transaccional con normalización a 3FN. Las tablas resultantes son:

- **clientes**: Información personal y demográfica.
- **categorias**: Agrupación de productos.
- **productos**: Catálogo de artículos.
- **pedidos**: Órdenes de compra realizadas por clientes.
- **detalle_pedido**: Detalles individuales por producto en cada pedido.

#### Claves y relaciones
```plaintext
clientes         1 ──────< pedidos
productos        1 ──────< detalle_pedido >────── 1    pedidos
categorias       1 ──────< productos

#### Consideraciones técnicas
- Se definieron claves primarias y foráneas para mantener integridad referencial.
- Se añadieron índices en campos de búsqueda frecuente (`ClienteID`, `FechaPedido`, `ProductoID`).
- Se propone una vista materializada `vista_resumen_pedidos` que agrupa el gasto por cliente.

#### Justificación de PostgreSQL
PostgreSQL fue elegido por su capacidad de gestionar integridad transaccional, soporte a vistas materializadas y robustez en ambientes OLTP. MySQL fue descartado por no soportar vistas materializadas de forma nativa.

## Diseño del Esquema Relacional

### Normalización
- **1FN**: Todos los campos son atómicos
- **2FN**: Todas las tablas tienen claves primarias y no hay dependencias parciales
- **3FN**: Eliminadas dependencias transitivas (ej: productos dependen de categorías, no de clientes)

### Optimizaciones
- **Índices**: Creados en campos de búsqueda frecuente (fechas, IDs)
- **Vista Materializada**: `resumen_clientes` para consultas rápidas de análisis
- **Triggers**: Actualización automática de la vista ante cambios

### Integración con Pipeline Anterior
Los datos de clientes fueron migrados desde la tabla `clientes_ext` (proveniente del módulo 3) mediante:
```sql

---
Desarrollado por: Catalina Millán Coronado – Estudiante de Ingeniería de Datos
