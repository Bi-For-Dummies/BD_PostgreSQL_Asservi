-- 1. Crear tabla en el esquema seleccionado
-- TIP: Cambiar nombre del schema con CTRL+SHIFT+L
CREATE TABLE IF NOT EXISTS gth_asistencia.centros_costo_app (
    codigo bigint NOT NULL,
    descripcion text,
    centro_de_servicio text,
    estado text,
    cedula_supervisor text,
    nombre_supervisor text,
    generar_pdf text, -- Columna para activar Bots de AppSheet (UNIQUEID)
    ultima_actualizacion timestamp with time zone DEFAULT now(),
    CONSTRAINT centros_costo_app_pkey PRIMARY KEY (codigo)
);

-- 2. Sincronización Inicial (Carga de datos desde la maestra)
-- Esto pobla la tabla por primera vez sin borrar IDs de PDF existentes
INSERT INTO gth_asistencia.centros_costo_app (
    codigo, 
    descripcion, 
    centro_de_servicio, 
    estado, 
    cedula_supervisor, 
    nombre_supervisor,
    generar_pdf
)
SELECT 
    codigo, 
    descripcion, 
    centro_de_servicio, 
    estado, 
    cedula, -- Cédula del supervisor en la tabla maestra
    nombre_supervisor,
    NULL    -- Se inicializa vacío
FROM public.dim_bd_cc
ON CONFLICT (codigo) DO UPDATE SET
    descripcion = EXCLUDED.descripcion,
    centro_de_servicio = EXCLUDED.centro_de_servicio,
    estado = EXCLUDED.estado,
    cedula_supervisor = EXCLUDED.cedula_supervisor,
    nombre_supervisor = EXCLUDED.nombre_supervisor,
    ultima_actualizacion = now();
    -- NOTA: NO incluimos generar_pdf en el UPDATE para proteger el UNIQUEID de AppSheet

-- 3. Función de Automatización (El "Cerebro" del Sync)
CREATE OR REPLACE FUNCTION gth_asistencia.fn_sync_cc_a_app()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO gth_asistencia.centros_costo_app (
        codigo, descripcion, centro_de_servicio, estado, cedula_supervisor, nombre_supervisor, generar_pdf
    )
    VALUES (
        NEW.codigo, NEW.descripcion, NEW.centro_de_servicio, NEW.estado, NEW.cedula, NEW.nombre_supervisor, NULL
    )
    ON CONFLICT (codigo) DO UPDATE SET
        descripcion = EXCLUDED.descripcion,
        centro_de_servicio = EXCLUDED.centro_de_servicio,
        estado = EXCLUDED.estado,
        cedula_supervisor = EXCLUDED.cedula_supervisor,
        nombre_supervisor = EXCLUDED.nombre_supervisor,
        ultima_actualizacion = now();
        -- La columna 'generar_pdf' se omite en el UPDATE para no interrumpir procesos de la App
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Crear Trigger (Disparador)
-- IMPORTANTE: Cambiar el nombre del trigger si se usa en la misma tabla para otro esquema
-- DROP TRIGGER IF EXISTS trg_sync_cc_gth_asistencia ON public.dim_bd_cc;
CREATE TRIGGER trg_sync_cc_gth_asistencia
AFTER INSERT OR UPDATE ON public.dim_bd_cc
FOR EACH ROW
EXECUTE FUNCTION gth_asistencia.fn_sync_cc_a_app();


