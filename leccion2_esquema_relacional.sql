-- =============================================
-- ESQUEMA RELACIONAL CORREGIDO (VERSIÓN FINAL)
-- =============================================

-- ----------------------------------------
-- Paso 0: Limpieza completa
-- ----------------------------------------
ROLLBACK;

DROP MATERIALIZED VIEW IF EXISTS resumen_clientes CASCADE;
DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP SEQUENCE IF EXISTS clientes_cliente_id_seq CASCADE;

-- ----------------------------------------
-- Paso 1: Creación de tablas
-- ----------------------------------------

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    edad INTEGER,
    genero VARCHAR(10) CHECK (genero IN ('M', 'F', 'Otro')),
    gasto_promedio NUMERIC(10,2),
    ultima_compra DATE DEFAULT CURRENT_DATE
);


CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) CHECK (precio > 0),
    stock INT DEFAULT 0,
    categoria_id INT NOT NULL REFERENCES categorias(categoria_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) CHECK (estado IN ('PENDIENTE', 'ENVIADO', 'ENTREGADO', 'CANCELADO')) DEFAULT 'PENDIENTE',
    total NUMERIC(12,2)
);

CREATE TABLE detalle_pedido (
    detalle_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

-- ----------------------------------------
-- Paso 2: Índices
-- ----------------------------------------

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_detalle_pedido ON detalle_pedido(pedido_id, producto_id);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);

-- ----------------------------------------
-- Paso 3: Vista materializada y triggers
-- ----------------------------------------

CREATE MATERIALIZED VIEW resumen_clientes AS
SELECT
    c.cliente_id,
    c.genero,
    COUNT(p.pedido_id) AS total_pedidos,
    SUM(dp.subtotal) AS total_gastado,
    MAX(p.fecha_pedido) AS ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
LEFT JOIN detalle_pedido dp ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.genero;

-- Función para refrescar vista
CREATE OR REPLACE FUNCTION refresh_resumen_clientes()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    REFRESH MATERIALIZED VIEW resumen_clientes;
    RETURN NULL;
END;
$$;

-- Trigger para refrescar vista resumen
CREATE TRIGGER update_resumen_clientes
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH STATEMENT EXECUTE FUNCTION refresh_resumen_clientes();

CREATE TRIGGER update_resumen_clientes_details
AFTER INSERT OR UPDATE OR DELETE ON detalle_pedido
FOR EACH STATEMENT EXECUTE FUNCTION refresh_resumen_clientes();

-- Función para actualizar total del pedido
CREATE OR REPLACE FUNCTION actualizar_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalle_pedido
        WHERE pedido_id = NEW.pedido_id
    )
    WHERE pedido_id = NEW.pedido_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar total de pedido automáticamente
CREATE TRIGGER tr_actualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON detalle_pedido
FOR EACH ROW EXECUTE FUNCTION actualizar_total_pedido();
