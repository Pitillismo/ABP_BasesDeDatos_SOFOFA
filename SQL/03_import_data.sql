
-- IMPORTACIÓN DE DATOS DESDE CSV USANDO \COPY
-- Ejecutar este script desde terminal con: psql -U tu_usuario -d tu_base -f 03_import_data.sql

\echo *** Iniciando importación desde clientes_final2.csv ***

\copy clientes_ext FROM 'data/clientes_final2.csv' DELIMITER ',' CSV HEADER;

\echo *** Verificando registros importados ***
SELECT 'Registros importados:' AS info, COUNT(*) FROM clientes_ext;
SELECT 'Rango de IDs:' AS info, MIN(cliente_id), MAX(cliente_id) FROM clientes_ext;


\echo *** Importación finalizada correctamente ***