
-- 1. Migrar clientes (con IDs explícitos)
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

-- 2. Actualizar secuencia de clientes (¡CRÍTICO!)
SELECT setval('clientes_cliente_id_seq', (SELECT MAX(cliente_id) FROM clientes));

-- 3. Insertar otras tablas (categorías, productos)
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y accesorios'),
('Ropa', 'Prendas de vestir para todas las edades'),
('Hogar', 'Artículos para el hogar y decoración');

INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Smartphone X', 799.99, 50, 1),
('Laptop Pro', 1499.99, 30, 1),
('Camiseta Básica', 19.99, 200, 2),
('Jarrón Decorativo', 45.50, 80, 3);

-- 4. Insertar pedidos usando IDs reales existentes
WITH clientes_validos AS (
    SELECT cliente_id FROM clientes ORDER BY cliente_id LIMIT 2
)
INSERT INTO pedidos (cliente_id, estado, total)
SELECT
    cliente_id,
    CASE
        WHEN ROW_NUMBER() OVER () = 1 THEN 'ENTREGADO'
        ELSE 'PENDIENTE'
    END,
    CASE
        WHEN ROW_NUMBER() OVER () = 1 THEN 799.99
        ELSE 1499.99
    END
FROM clientes_validos;

-- 5. Insertar detalles de pedido
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
SELECT
    p.pedido_id,
    CASE p.pedido_id
        WHEN (SELECT MIN(pedido_id) FROM pedidos) THEN 1  -- Smartphone
        ELSE 2  -- Laptop
    END,
    1,
    CASE p.pedido_id
        WHEN (SELECT MIN(pedido_id) FROM pedidos) THEN 799.99
        ELSE 1499.99
    END
FROM pedidos p;