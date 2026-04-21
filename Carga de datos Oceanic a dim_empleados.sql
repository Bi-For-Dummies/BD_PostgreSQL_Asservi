INSERT INTO public.dim_historico_empleados (
    "contrato", "cedula", "nombre", "primer_nombre", "segundo_nombre", "primer_apellido", "segundo_apellido",
    "cod_tipo_ident", "tipo_identificacion", "cod_ciudad_expedicion", "ciudad_expedicion", "fecha_nacimiento",
    "cod_ciudad_nacim", "ciudad_nacimiento", "telefono_1", "telefono_2", "cod_ciudad_resid", "ciudad_residencia",
    "direccion", "email", "sexo", "estado_civil", "estrato_social", "grupo_sanguineo", "rh", "fecha_ingreso",
    "venc_contrato", "liquidarlenomina", "cod_tipo_nomina", "tipo_nomina", "cod_cc", "centro_de_costos",
    "salario", "salario_minimo", "salario_integral", "prest_servicios", "cod_cargo", "cargo", "infomación_cargo",
    "cod_tipo_contrato", "tipo_de_contrato", "cod_ciudad", "ciudad_labora", "sabado_habil", "cod_eps",
    "entidad_eps", "cod_pensiones", "entidad_pensiones", "cod_cesantias", "entidad_cesantidas", "porcentaje_arp",
    "cod_tipopago", "tipo_de_pago", "cta_bancaria", "cod_banco", "banco", "tipo_cta_banc", "fecha_ult_vacac",
    "fecha_ult_cesantias", "fecha_ult_intcesantias", "fecha_ult_visita_domic", "tipo_de_cotizante",
    "subtipo_de_cotizante", "es_estranjero", "es_residente_exterior", "exoner_parafiscales", "retirado",
    "causa_retiro", "observaciones", "contacto_emergencia"
)
SELECT 
    "Contrato"::bigint, 
    CASE 
        WHEN "Cedula" LIKE '%E%' THEN split_part(("Cedula"::numeric)::text, '.', 1)
        ELSE "Cedula"
    END,
    "Nombre", "Primer Nombre", "Segundo Nombre", "Primer Apellido", "Segundo Apellido",
    "Cod.Tipo.Ident", "Tipo.Identificacion", "Cod.Ciudad.Expedicion", "Ciudad.Expedicion", "Fecha.Nacimiento",
    "Cod.Ciudad.Nacim", "Ciudad.Nacimiento", "Telefono.1", "Telefono.2", "Cod.Ciudad.Resid", "Ciudad.Residencia",
    "Direccion", "eMail", "Sexo", "Estado.Civil", "Estrato.Social", "Grupo.Sanguineo", "Rh", "Fecha.Ingreso",
    "Venc.Contrato", "LiquidarleNomina", "Cod.Tipo.Nomina", "Tipo.Nomina", "cod.CC", "Centro.De.Costos",
    NULLIF(regexp_replace("Salario", '[^0-9.]', '', 'g'), '')::numeric,
    "Salario.Minimo", "Salario.Integral", "Prest.Servicios", "Cod.Cargo", "Cargo", "Infomación_Cargo",
    "Cod.Tipo.Contrato", "Tipo.De.Contrato", "Cod.Ciudad", "Ciudad.Labora", "Sabado.Habil", "Cod.EPS",
    "Entidad.EPS", "Cod.Pensiones", "Entidad.Pensiones", "Cod.Cesantias", "Entidad.Cesantidas", "%ARP",
    "Cod.TipoPago", "Tipo.De.Pago", "Cta.Bancaria", "Cod.Banco", "Banco", "Tipo.Cta.Banc", "Fecha.Ult.Vacac",
    "Fecha.Ult.Cesantias", "Fecha.Ult.IntCesantias", "Fecha.Ult.Visita.Domic", "Tipo.De.Cotizante",
    "SubTipo.De.Cotizante", "Es.Estranjero", "Es.Residente.Exterior", "Exoner.Parafiscales", "Retirado",
    "Causa.Retiro", "Observaciones", "Contacto.Emergencia"
FROM public.carga_masiva_erp
ON CONFLICT ("contrato") DO UPDATE SET
    "cedula" = EXCLUDED."cedula",
    "nombre" = EXCLUDED."nombre",
    "retirado" = EXCLUDED."retirado",
    "cargo" = EXCLUDED."cargo",
    "centro_de_costos" = EXCLUDED."centro_de_costos",
    "porcentaje_arp" = EXCLUDED."porcentaje_arp",
    "email" = EXCLUDED."email",
    "telefono_1" = EXCLUDED."telefono_1";

    -- 3. Limpieza para la próxima carga
TRUNCATE TABLE public.carga_masiva_erp;
