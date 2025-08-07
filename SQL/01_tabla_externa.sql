-- Elimina las tablas (lo hago directamente desde postgres)
DROP MATERIALIZED VIEW IF EXISTS resumen_clientes CASCADE;
DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS clientes_ext CASCADE;
DROP SEQUENCE IF EXISTS clientes_cliente_id_seq CASCADE;

-- Crea la tabla con todas las columnas del dataset_final
CREATE TABLE clientes_ext (
    cliente_id INTEGER PRIMARY KEY,
    edad INTEGER,
    genero VARCHAR(20) CHECK (genero IN ('M', 'F', 'Otro')),
    gasto NUMERIC(10, 2),
    fuente VARCHAR(20),
    gasto_anual_estimado NUMERIC(12, 2),
    genero_extendido VARCHAR(20),
    grupo_etario VARCHAR(20),
    gasto_normalizado NUMERIC(10, 6)
);
