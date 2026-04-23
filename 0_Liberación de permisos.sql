-- 1. Permiso para entrar al esquema
GRANT USAGE ON SCHEMA nombre_de_tu_esquema TO postgres;

-- 2. Permiso para lo que YA existe
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nombre_de_tu_esquema TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA nombre_de_tu_esquema TO postgres;

-- 3. EL TRUCO FINAL: Permisos automáticos para el FUTURO
-- Esto hace que cualquier tabla nueva que crees ya nazca con permisos
ALTER DEFAULT PRIVILEGES IN SCHEMA nombre_de_tu_esquema 
GRANT ALL ON TABLES TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA nombre_de_tu_esquema 
GRANT ALL ON SEQUENCES TO postgres;
