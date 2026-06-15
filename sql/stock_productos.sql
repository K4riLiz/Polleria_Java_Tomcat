-- ============================================================
-- Módulo de control de stock - Pollería El Dorado
-- Ejecutar en MySQL antes de desplegar la aplicación
-- ============================================================

USE polleria_db;

-- 1. Agregar columna stock (platos disponibles del día)
ALTER TABLE productos
ADD COLUMN stock INT NOT NULL DEFAULT 0
COMMENT 'Cantidad de platos disponibles para venta';

-- 2. Valores iniciales de ejemplo (ajusta según tu menú real)
UPDATE productos SET stock = 20 WHERE nombre LIKE '%1/4%' OR nombre LIKE '%cuarto%';
UPDATE productos SET stock = 15 WHERE nombre LIKE '%1/2%' OR nombre LIKE '%medio%';
UPDATE productos SET stock = 10 WHERE nombre LIKE '%entero%' OR nombre LIKE '%Entero%';
UPDATE productos SET stock = 30 WHERE categoria_id IN (SELECT id FROM categorias WHERE nombre LIKE '%bebida%' OR nombre LIKE '%gaseosa%');
UPDATE productos SET stock = 15 WHERE categoria_id IN (SELECT id FROM categorias WHERE nombre LIKE '%postre%');

-- 3. Productos activos sin stock asignado: valor por defecto razonable
UPDATE productos SET stock = 10 WHERE activo = 1 AND stock = 0;

-- 4. Consulta de verificación
SELECT p.id, p.nombre, c.nombre AS categoria, p.stock, p.activo
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nombre, p.nombre;
