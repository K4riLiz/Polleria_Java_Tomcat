-- ============================================================
-- Control de stock para promociones - Pollería El Dorado
-- Ejecutar en MySQL antes de desplegar la aplicación
-- ============================================================

USE polleria_db;

-- Agregar columna stock a promociones
ALTER TABLE promociones
ADD COLUMN stock INT NOT NULL DEFAULT 0
COMMENT 'Cantidad de promociones disponibles para venta';

-- Valores iniciales de ejemplo
UPDATE promociones SET stock = 10 WHERE activo = 1 AND stock = 0;

-- Verificación
SELECT id, nombre, precio, stock, activo FROM promociones ORDER BY nombre;
