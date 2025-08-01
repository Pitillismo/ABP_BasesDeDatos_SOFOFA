-- ========================================
-- RUN_ALL_FINAL.sql - Flujo completo del proyecto
-- Proyecto ABP - Módulo 4 - Bases de Datos
-- ========================================

-- ========================================
-- Paso 1: Crear tabla staging clientes_ext
-- ========================================

DROP TABLE IF EXISTS clientes_ext;

CREATE TABLE clientes_ext (
    cliente_id INTEGER PRIMARY KEY,
    edad INTEGER,
    genero VARCHAR(1) CHECK (genero IN ('M', 'F')),
    gasto NUMERIC(10, 2),
    fuente VARCHAR(20),
    gasto_anual_estimado NUMERIC(12, 2),
    genero_extendido VARCHAR(20),
    grupo_etario VARCHAR(20),
    gasto_normalizado NUMERIC(10, 6)
);

-- ========================================
-- Paso 2: Crear modelo relacional optimizado
-- ========================================

DROP MATERIALIZED VIEW IF EXISTS resumen_clientes CASCADE;
DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    edad INT,
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

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_detalle_pedido ON detalle_pedido(pedido_id, producto_id);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);

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

CREATE OR REPLACE FUNCTION refresh_resumen_clientes()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    REFRESH MATERIALIZED VIEW resumen_clientes;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION actualizar_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE pedidos p
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalle_pedido dp
        WHERE dp.pedido_id = NEW.pedido_id
    )
    WHERE p.pedido_id = NEW.pedido_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_actualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON detalle_pedido
FOR EACH ROW
EXECUTE FUNCTION actualizar_total_pedido();

CREATE TRIGGER update_resumen_clientes
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH STATEMENT EXECUTE FUNCTION refresh_resumen_clientes();

CREATE TRIGGER update_resumen_clientes_details
AFTER INSERT OR UPDATE OR DELETE ON detalle_pedido
FOR EACH STATEMENT EXECUTE FUNCTION refresh_resumen_clientes();

-- ========================================
-- Paso 3: Migrar datos desde clientes_ext
-- ========================================

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

INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y accesorios'),
('Ropa', 'Prendas de vestir para todas las edades'),
('Hogar', 'Artículos para el hogar y decoración');

INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Smartphone X', 799.99, 50, 1),
('Laptop Pro', 1499.99, 30, 1),
('Camiseta Básica', 19.99, 200, 2),
('Jarrón Decorativo', 45.50, 80, 3);

INSERT INTO pedidos (cliente_id, total) VALUES
(1, 799.99),
(1, 45.50),
(2, 1499.99);

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 799.99),
(2, 4, 1, 45.50),
(3, 2, 1, 1499.99);

-- ========================================
-- Paso 4: Configurar secuencia para cliente_id
-- ========================================

DO $$
DECLARE
    max_id INT;
BEGIN
    SELECT MAX(cliente_id) INTO max_id FROM clientes;
    IF max_id IS NULL THEN
        max_id := 1;
    ELSE
        max_id := max_id + 1;
    END IF;

    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS clientes_cliente_id_seq START WITH %s;', max_id);
    EXECUTE 'ALTER TABLE clientes ALTER COLUMN cliente_id SET DEFAULT nextval(''clientes_cliente_id_seq'');';
END $$;
