--Crear tabla en esquema--

CREATE TABLE gth_asistencia.centros_costo_app (
    codigo bigint NOT NULL,
    descripcion text,
    centro_de_servicio text,
    estado text,
    cedula_supervisor text,
    nombre_supervisor text,
    ultima_actualizacion timestamp with time zone DEFAULT now(),
    CONSTRAINT centros_costo_app_pkey PRIMARY KEY (codigo)
);

--Insertar datos--

INSERT INTO gth_asistencia.centros_costo_app (
    codigo, 
    descripcion, 
    centro_de_servicio, 
    estado, 
    cedula_supervisor, 
    nombre_supervisor
)
SELECT 
    codigo, 
    descripcion, 
    centro_de_servicio, 
    estado, 
    cedula, -- Esta es la cédula del supervisor en tu tabla original
    nombre_supervisor
FROM public.dim_bd_cc
ON CONFLICT (codigo) DO UPDATE SET
    descripcion = EXCLUDED.descripcion,
    centro_de_servicio = EXCLUDED.centro_de_servicio,
    estado = EXCLUDED.estado,
    cedula_supervisor = EXCLUDED.cedula_supervisor,
    nombre_supervisor = EXCLUDED.nombre_supervisor,
    ultima_actualizacion = now();

--Automatizar Actualización de datos--

CREATE OR REPLACE FUNCTION gth_asistencia.fn_sync_cc_a_app()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO gth_asistencia.centros_costo_app (
        codigo, descripcion, centro_de_servicio, estado, cedula_supervisor, nombre_supervisor
    )
    VALUES (
        NEW.codigo, NEW.descripcion, NEW.centro_de_servicio, NEW.estado, NEW.cedula, NEW.nombre_supervisor
    )
    ON CONFLICT (codigo) DO UPDATE SET
        descripcion = EXCLUDED.descripcion,
        centro_de_servicio = EXCLUDED.centro_de_servicio,
        estado = EXCLUDED.estado,
        cedula_supervisor = EXCLUDED.cedula_supervisor,
        nombre_supervisor = EXCLUDED.nombre_supervisor,
        ultima_actualizacion = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Crear trigger--

CREATE TRIGGER trg_sync_cc_gth_asistencia
AFTER INSERT OR UPDATE ON public.dim_bd_cc
FOR EACH ROW
EXECUTE FUNCTION gth_asistencia.fn_sync_cc_a_app();
