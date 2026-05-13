## 1. Arquitectura de Datos

* **Origen**: PostgreSQL alojado en Supabase (Esquema `public`).
* **Capa de Acceso**: Data API autogenerada (PostgREST).
* **Seguridad**: Row Level Security (RLS) con validación de API Key.
* **Consumidor**: Power BI Service mediante conector Web (Modo Avanzado).

## 2. Configuración en Supabase

### Credenciales de la API

Para la conexión se requiere la URL base y la llave anónima pública:

* **API URL**: `https://hqgnkzypecnchnrgtuqi.supabase.co/rest/v1/`
* **API Key (anon)**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (Token JWT)

### Política de Seguridad (RLS)

Para permitir que Power BI lea los datos de la tabla `dim_historico_empleados`, se implementó la siguiente política en el SQL Editor:

```sql
-- 1. Asegurar que el RLS esté activo para la tabla
ALTER TABLE public.dim_historico_empleados ENABLE ROW LEVEL SECURITY;

-- 2. Crear la política de lectura global para el rol 'anon'
CREATE POLICY "Permitir lectura para Power BI"
ON "public"."dim_historico_empleados"
AS PERMISSIVE
FOR SELECT
TO public
USING (
  true
);

```

## 3. Configuración en Power BI

Se utiliza el conector **Web** en la opción **Uso avanzado**:

1. **Partes de la URL**:
* Casilla 1: `https://hqgnkzypecnchnrgtuqi.supabase.co/rest/v1/`
* Casilla 2: `dim_historico_empleados?select=*`


2. **Parámetros de encabezado HTTP**:
* `apikey`: `TU_TOKEN_JWT_ANON`
* `Authorization`: `Bearer TU_TOKEN_JWT_ANON`



## 4. Actualización de Datos

* **Método**: Importación de datos (Import Mode).
* **Frecuencia**: Actualización programada en la nube (Power BI Service).
* **Licencia Pro**: Hasta 8 veces al día.
* **Licencia Premium**: Hasta 48 veces al día.


* **Actualización en la nube**: Al configurar las credenciales en Power BI Service, se debe seleccionar el método de autenticación **"Anónimo"**, ya que las llaves están embebidas en los encabezados HTTP del script de Power Query.
