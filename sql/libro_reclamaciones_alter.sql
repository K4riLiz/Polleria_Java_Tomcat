-- Migración: Libro de Reclamaciones completo
-- Ejecutar en la base de datos MySQL del proyecto (polleria)
-- No elimina datos existentes. Ejecutar una sola vez.

-- 1. Campo asunto
ALTER TABLE libro_reclamaciones
    ADD COLUMN asunto VARCHAR(200) NOT NULL DEFAULT 'Sin asunto'
    AFTER tipo_reclamo;

-- 2. Respuesta del administrador
ALTER TABLE libro_reclamaciones
    ADD COLUMN respuesta_admin TEXT NULL
    AFTER descripcion;

-- 3. Fecha de respuesta del administrador
ALTER TABLE libro_reclamaciones
    ADD COLUMN fecha_respuesta DATETIME NULL
    AFTER respuesta_admin;

-- 4. Asegurar valor por defecto del estado
ALTER TABLE libro_reclamaciones
    MODIFY COLUMN estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente';

-- Valores válidos de estado: 'Pendiente', 'En proceso', 'Respondido'
