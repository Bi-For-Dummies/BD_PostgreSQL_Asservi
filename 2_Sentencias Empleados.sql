-- 0. Aseguramos que el esquema exista
CREATE SCHEMA IF NOT EXISTS prueba;

-- 1. Crear tabla en el esquema
-- Cambiar el nombre por el esquema que se quiere
CREATE TABLE IF NOT EXISTS prueba.empleados_app (
    cedula text NOT NULL,
    nombre text,
    contrato bigint,
    cod_cc text,
    centro_de_costos text,
    cod_cargo text,
    cargo text,
    retirado text,
    email text,
    telefono_1 text,
    porcentaje_arp text,
    generar_pdf text, 
    ultima_sincronizacion timestamp with time zone DEFAULT now(),
    CONSTRAINT empleados_app_prueba_pkey PRIMARY KEY (cedula)
);

-- 2. Sincronización inicial
INSERT INTO prueba.empleados_app (
    cedula, nombre, contrato, cod_cc, centro_de_costos, 
    cod_cargo, cargo, retirado, email, telefono_1, porcentaje_arp, generar_pdf
)
SELECT DISTINCT ON (cedula) 
    CASE 
        WHEN cedula LIKE '%E%' THEN split_part((cedula::numeric)::text, '.', 1)
        ELSE cedula
    END, 
    nombre, contrato, cod_cc, centro_de_costos, 
    cod_cargo, cargo, retirado, email, telefono_1, porcentaje_arp,
    NULL 
FROM public.dim_historico_empleados
ORDER BY cedula, contrato DESC
ON CONFLICT (cedula) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    contrato = EXCLUDED.contrato,
    cod_cc = EXCLUDED.cod_cc,
    centro_de_costos = EXCLUDED.centro_de_costos,
    cargo = EXCLUDED.cargo,
    retirado = EXCLUDED.retirado,
    email = EXCLUDED.email,
    telefono_1 = EXCLUDED.telefono_1,
    porcentaje_arp = EXCLUDED.porcentaje_arp,
    ultima_sincronizacion = now();

-- 3. Función de automatización para 'prueba'
CREATE OR REPLACE FUNCTION prueba.fn_sync_personal_a_app()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO prueba.empleados_app (
        cedula, nombre, contrato, cod_cc, centro_de_costos, 
        cod_cargo, cargo, retirado, email, telefono_1, porcentaje_arp, generar_pdf
    )
    VALUES (
        CASE 
            WHEN NEW.cedula LIKE '%E%' THEN split_part((NEW.cedula::numeric)::text, '.', 1)
            ELSE NEW.cedula
        END,
        NEW.nombre, NEW.contrato, NEW.cod_cc, NEW.centro_de_costos, 
        NEW.cod_cargo, NEW.cargo, NEW.retirado, NEW.email, NEW.telefono_1, NEW.porcentaje_arp,
        NULL 
    )
    ON CONFLICT (cedula) DO UPDATE SET
        nombre = EXCLUDED.nombre,
        contrato = EXCLUDED.contrato,
        cod_cc = EXCLUDED.cod_cc,
        centro_de_costos = EXCLUDED.centro_de_costos,
        cargo = EXCLUDED.cargo,
        retirado = EXCLUDED.retirado,
        email = EXCLUDED.email,
        telefono_1 = EXCLUDED.telefono_1,
        porcentaje_arp = EXCLUDED.porcentaje_arp,
        ultima_sincronizacion = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Crear el Trigger con nombre ÚNICO para evitar el error 42710
-- Le añadimos el sufijo '_prueba' para diferenciarlo de los otros
--Agregar solo si es necesario: DROP TRIGGER IF EXISTS trg_sync_personal_prueba ON public.dim_historico_empleados;

CREATE TRIGGER trg_sync_personal_prueba --Cambiar nombre siempre
AFTER INSERT OR UPDATE ON public.dim_historico_empleados
FOR EACH ROW
EXECUTE FUNCTION prueba.fn_sync_personal_a_app();
