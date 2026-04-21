--Crear tabla en esquema

CREATE TABLE IF NOT EXISTS sig_epp.empleados_app (
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
    ultima_sincronizacion timestamp with time zone DEFAULT now(),
    CONSTRAINT empleados_app_pkey PRIMARY KEY (cedula)
);

--Insertar datos en tabla

INSERT INTO sig_epp.empleados_app (
    cedula, 
    nombre, 
    contrato, 
    cod_cc, 
    centro_de_costos, 
    cod_cargo, 
    cargo, 
    retirado,
    email,
    telefono_1
)
SELECT DISTINCT ON (cedula) 
    CASE 
        WHEN cedula LIKE '%E%' THEN split_part((cedula::numeric)::text, '.', 1)
        ELSE cedula
    END as cedula, 
    nombre, 
    contrato, 
    cod_cc, 
    centro_de_costos, 
    cod_cargo, 
    cargo, 
    retirado,
    email, 
    telefono_1
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
    ultima_sincronizacion = now();

--Automatizar actualización

CREATE OR REPLACE FUNCTION sig_epp.fn_sync_personal_a_app()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO sig_epp.empleados_app (
        cedula, nombre, contrato, cod_cc, centro_de_costos, cod_cargo, cargo, retirado, email, telefono_1, porcentaje_arp
    )
    VALUES (
        CASE 
            WHEN NEW.cedula LIKE '%E%' THEN split_part((NEW.cedula::numeric)::text, '.', 1)
            ELSE NEW.cedula
        END,
        NEW.nombre, NEW.contrato, NEW.cod_cc, NEW.centro_de_costos, NEW.cod_cargo, NEW.cargo, NEW.retirado, NEW.email, NEW.telefono_1, NEW.porcentaje_arp
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

--Trigger

CREATE TRIGGER trg_sync_personal
AFTER INSERT OR UPDATE ON public.dim_historico_empleados
FOR EACH ROW
EXECUTE FUNCTION sig_epp.fn_sync_personal_a_app();
