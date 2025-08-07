-- =============================================
-- PRUEBA INTEGRAL DEL SISTEMA DE BASE DE DATOS
-- =============================================

-- ------------------------------------------------------
-- Paso 1: Limpiar datos (sin recrear esquema)
ROLLBACK;
TRUNCATE TABLE detalle_pedido, pedidos, productos, categorias, clientes
RESTART IDENTITY CASCADE;

-- ------------------------------------------------------
-- Paso 2: Insertar datos de prueba
-- ------------------------------------------------------
SELECT 'Datos importados (clientes_ext):' AS prueba;
SELECT COUNT(*) AS total_registros FROM clientes_ext;  -- Debe ser > 0

SELECT 'Clientes migrados:' AS prueba;
SELECT * FROM clientes LIMIT 5;

-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos de última generación'),
('Ropa', 'Prendas de vestir para toda ocasión'),
('Hogar', 'Artículos para el hogar');

-- Insertar productos
INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Smartphone X', 799.99, 50, 1),
('Laptop Pro', 1499.99, 30, 1),
('Camiseta Algodón', 24.99, 100, 2),
('Sofá 3 Plazas', 899.00, 10, 3);

-- Insertar clientes VÁLIDOS
INSERT INTO clientes (edad, genero, gasto_promedio) VALUES
(35, 'M', 0),
(28, 'F', 0),
(42, 'Otro', 0);

-- Insertar pedidos
INSERT INTO pedidos (cliente_id, estado) VALUES
(1, 'ENTREGADO'),
(1, 'ENVIADO'),
(2, 'PENDIENTE'),
(3, 'ENTREGADO');

-- Insertar detalles de pedido
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 799.99),
(1, 3, 2, 24.99),
(2, 2, 1, 1499.99),
(3, 3, 3, 24.99),
(4, 4, 1, 899.00);

-- Actualizar vista materializada
REFRESH MATERIALIZED VIEW resumen_clientes;

-- ------------------------------------------------------
-- Paso 3: Realizar consultas de verificación
-- ------------------------------------------------------
-- 1. Verificar todas las tablas
SELECT 'Tablas existentes:' AS prueba;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Consultar datos insertados
SELECT 'Clientes:' AS prueba; SELECT * FROM clientes;
SELECT 'Categorías:' AS prueba; SELECT * FROM categorias;
SELECT 'Productos:' AS prueba; SELECT * FROM productos;
SELECT 'Pedidos:' AS prueba; SELECT * FROM pedidos;
SELECT 'Detalles pedido:' AS prueba; SELECT * FROM detalle_pedido;
SELECT 'Vista materializada:' AS prueba; SELECT * FROM resumen_clientes;

-- 3. Consulta compleja: Resumen de pedidos por categoría
SELECT 'Resumen por categoría:' AS prueba;
SELECT
    c.nombre AS categoria,
    COUNT(dp.detalle_id) AS total_items,
    SUM(dp.subtotal) AS total_ventas
FROM detalle_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
JOIN categorias c ON p.categoria_id = c.categoria_id
GROUP BY c.nombre
ORDER BY total_ventas DESC;

-- ------------------------------------------------------
-- Paso 4: Probar eliminación en cascada
-- ------------------------------------------------------
-- Eliminar un cliente (debe eliminar pedidos y detalles relacionados)
DELETE FROM clientes WHERE cliente_id = 1;

-- Verificar eliminación en cascada
SELECT 'Pedidos después de eliminar cliente 1:' AS prueba;
SELECT * FROM pedidos WHERE cliente_id = 1;  -- Debe estar vacío

SELECT 'Detalles después de eliminar cliente 1:' AS prueba;
SELECT * FROM detalle_pedido
WHERE pedido_id IN (SELECT pedido_id FROM pedidos WHERE cliente_id = 1);  -- Vacío

-- Actualizar y consultar vista materializada
REFRESH MATERIALIZED VIEW resumen_clientes;  -- Nombre corregido
SELECT 'Vista materializada después de eliminar cliente 1:' AS prueba;
SELECT * FROM resumen_clientes WHERE cliente_id = 1; -- Vacío

-- ------------------------------------------------------
-- Paso 5: Probar índices y rendimiento
-- ------------------------------------------------------
-- Verificar uso de índices
SELECT 'Uso de índices:' AS prueba;
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE cliente_id = 2;
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE fecha_pedido > CURRENT_DATE - INTERVAL '7 days';

-- ------------------------------------------------------
-- Paso 6: Probar campo calculado
-- ------------------------------------------------------
-- Verificar campo calculado subtotal en DETALLE_PEDIDO
SELECT 'Verificación campo calculado (detalle_pedido):' AS prueba;
SELECT
    cantidad,
    precio_unitario,
    subtotal,
    (cantidad * precio_unitario) AS calculado_manual,
    (subtotal = (cantidad * precio_unitario)) AS coincide
FROM detalle_pedido;

-- ------------------------------------------------------
-- Paso 6b: Probar cálculo del TOTAL en PEDIDOS (Nuevo)
-- ------------------------------------------------------
-- Actualizar el total de los pedidos usando los detalles
UPDATE pedidos p
SET total = (
    SELECT SUM(subtotal)
    FROM detalle_pedido dp
    WHERE dp.pedido_id = p.pedido_id
)
WHERE pedido_id IN (SELECT pedido_id FROM detalle_pedido);

-- Verificar totales en pedidos
SELECT 'Total en pedidos después de actualización:' AS prueba;
SELECT
    p.pedido_id,
    p.total AS total_pedido,
    SUM(dp.subtotal) AS total_calculado
FROM pedidos p
JOIN detalle_pedido dp ON p.pedido_id = dp.pedido_id
GROUP BY p.pedido_id, p.total;

-- ------------------------------------------------------
-- Paso 7 Prueba de restricciones con bloques DO
-- ------------------------------------------------------
SELECT 'Pruebas de restricciones (deben fallar):' AS prueba;

-- 1. Género inválido
DO $$
BEGIN
    INSERT INTO clientes (edad, genero) VALUES (30, 'X');
    RAISE EXCEPTION '❌ Género inválido no detectado!';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '✅ Género inválido detectado correctamente';
END $$;

-- 2. Precio negativo
DO $$
BEGIN
    INSERT INTO productos (nombre, precio, categoria_id) VALUES ('Producto inválido', -10, 1);
    RAISE EXCEPTION '❌ Precio negativo no detectado!';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '✅ Precio negativo detectado correctamente';
END $$;

-- 3. Cliente inexistente
DO $$
BEGIN
    INSERT INTO pedidos (cliente_id) VALUES (999);
    RAISE EXCEPTION '❌ Cliente inexistente no detectado!';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '✅ Cliente inexistente detectado correctamente';
END $$;

-- ------------------------------------------------------
-- Paso 8: Prueba de triggers y resultado final
-- ------------------------------------------------------
SELECT 'Prueba de trigger para total en pedidos:' AS prueba;

-- Insertar nuevo pedido con detalles
WITH nuevo_pedido AS (
    INSERT INTO pedidos (cliente_id, estado)
    VALUES (2, 'PENDIENTE')
    RETURNING pedido_id
)
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
SELECT pedido_id, 3, 2, 24.99
FROM nuevo_pedido;

-- Verificar total automático
SELECT
    p.pedido_id,
    p.total AS total_pedido,
    (SELECT SUM(subtotal) FROM detalle_pedido dp WHERE dp.pedido_id = p.pedido_id) AS total_calculado
FROM pedidos p
WHERE p.pedido_id = (SELECT MAX(pedido_id) FROM pedidos);

SELECT '¡TODAS LAS PRUEBAS COMPLETADAS CON ÉXITO!' AS resultado;