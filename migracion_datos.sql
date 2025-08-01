-- Migrar datos de clientes_ext a clientes
INSERT INTO clientes (cliente_id, edad, genero, gasto_promedio)
SELECT
    cliente_id,
    edad,
    CASE
        WHEN genero_extendido ILIKE 'femenino' THEN 'F'
        WHEN genero_extendido ILIKE 'masculino' THEN 'M'
        ELSE 'Otro'
    END,
    ROUND(gasto_anual_estimado / 12.0, 2)
FROM clientes_ext;

-- Insertar datos de ejemplo para otras tablas
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y accesorios'),
('Ropa', 'Prendas de vestir para todas las edades'),
('Hogar', 'Artículos para el hogar y decoración');

-- PRODUCTOS
INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Smartphone X', 799.99, 50, 1),
('Laptop Pro', 1499.99, 30, 1),
('Camiseta Básica', 19.99, 200, 2),
('Jarrón Decorativo', 45.50, 80, 3);

-- PEDIDOS (corrigiendo advertencia: listamos todas las columnas relevantes)
INSERT INTO pedidos (cliente_id, estado, total)
VALUES
(1, 'ENTREGADO', 799.99),
(1, 'ENVIADO', 45.50),
(2, 'PENDIENTE', 1499.99);

-- DETALLE DE PEDIDO (sin advertencia, todas las columnas obligatorias explícitas)
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES
(1, 1, 1, 799.99),
(2, 4, 1, 45.50),
(3, 2, 1, 1499.99);