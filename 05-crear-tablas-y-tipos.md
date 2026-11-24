# 05. Crear tablas, tipos de datos e índices

SQL tiene dos grandes familias de comandos:

- **DDL** (definición): `CREATE`, `ALTER`, `DROP`. Definen la **estructura**.
- **DML** (manipulación): `SELECT`, `INSERT`, `UPDATE`, `DELETE`. Trabajan con los **datos**.

## Tipos de datos más usados en PostgreSQL

| Tipo | Uso | Ejemplo |
|---|---|---|
| `INTEGER` / `BIGINT` | números enteros | `42` |
| `NUMERIC(10,2)` | dinero o decimales exactos | `199.99` |
| `REAL` / `DOUBLE PRECISION` | decimales aproximados (científicos) | `3.1416` |
| `VARCHAR(255)` | texto con límite | `'Ana'` |
| `TEXT` | texto sin límite (en Postgres rinde igual que VARCHAR) | `'...'` |
| `BOOLEAN` | verdadero o falso | `TRUE` |
| `DATE` | fecha | `'2026-11-14'` |
| `TIMESTAMP` | fecha y hora | `'2026-11-14 18:00'` |
| `TIMESTAMPTZ` | fecha y hora con zona horaria (recomendado) | `NOW()` |
| `UUID` | identificador único global | `gen_random_uuid()` |
| `JSONB` | JSON indexable | `'{"a": 1}'` |
| `TEXT[]` | arreglo | `ARRAY['a','b']` |

Nunca uses `REAL` o `FLOAT` para dinero, porque redondean. Usa `NUMERIC`.

## CREATE TABLE

```sql
CREATE TABLE productos (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- autoincremental
  nombre      VARCHAR(100) NOT NULL,
  sku         VARCHAR(20)  NOT NULL UNIQUE,
  precio      NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
  creado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

`SERIAL` es la forma antigua de hacer un autoincremental. Se sigue viendo mucho y funciona igual.

## Restricciones (constraints)

| Restricción | Qué garantiza |
|---|---|
| `PRIMARY KEY` | único y no nulo; identifica la fila |
| `NOT NULL` | la columna siempre tiene valor |
| `UNIQUE` | no se repite (por ejemplo, email) |
| `DEFAULT valor` | valor si no se especifica |
| `CHECK (condición)` | regla personalizada |
| `REFERENCES tabla(col)` | clave foránea; el valor debe existir en la otra tabla |

### ¿Qué pasa al borrar el "padre" de una FK?

| Opción | Efecto al borrar el cliente |
|---|---|
| `ON DELETE RESTRICT` (por defecto) | error si tiene boletos |
| `ON DELETE CASCADE` | se borran también sus boletos |
| `ON DELETE SET NULL` | `cliente_id` de sus boletos pasa a NULL |

## ALTER TABLE: modificar estructura

```sql
ALTER TABLE productos ADD COLUMN stock INTEGER NOT NULL DEFAULT 0;
ALTER TABLE productos DROP COLUMN stock;
ALTER TABLE productos RENAME COLUMN nombre TO titulo;
ALTER TABLE productos ALTER COLUMN titulo TYPE TEXT;
ALTER TABLE productos ALTER COLUMN titulo SET NOT NULL;
ALTER TABLE productos RENAME TO articulos;
ALTER TABLE productos ADD CONSTRAINT precio_positivo CHECK (precio > 0);
```

## DROP y TRUNCATE

```sql
DROP TABLE productos;                    -- borra la tabla y sus datos
DROP TABLE IF EXISTS productos;          -- sin error si no existe
TRUNCATE productos;                      -- vacía la tabla y mantiene la estructura
TRUNCATE productos RESTART IDENTITY;     -- además reinicia los ids
```

## Índices: búsquedas rápidas

Un índice funciona como el índice de un libro: evita leer todas las páginas.

```sql
CREATE INDEX idx_boletos_cliente ON boletos (cliente_id);
CREATE UNIQUE INDEX idx_clientes_email ON clientes (email);
CREATE INDEX idx_varias ON boletos (sorteo_id, numero);   -- índice compuesto
DROP INDEX idx_boletos_cliente;
```

Cuándo crear índices:

- Columnas que usas mucho en `WHERE`, `JOIN` u `ORDER BY`.
- Claves foráneas. Postgres **no** las indexa solo, a diferencia de MySQL.

Cuándo no:

- Tablas pequeñas.
- Columnas que casi nunca se consultan. Cada índice hace más lentos los `INSERT` y `UPDATE`.

`PRIMARY KEY` y `UNIQUE` ya crean un índice automáticamente.

## Normalización (diseño de tablas)

Idea básica: **cada dato se guarda en un solo lugar.**

❌ Mal: repetir los datos del cliente en cada boleto.

```
boletos: id | cliente_nombre | cliente_email | numero
```

✅ Bien: separar en tablas y relacionarlas con un id.

```
clientes: id | nombre | email
boletos:  id | cliente_id | numero
```

Si el cliente cambia su email, se actualiza en un solo lugar.

## Usuarios y permisos

```sql
CREATE USER lector WITH PASSWORD 'secreto';
GRANT CONNECT ON DATABASE practica TO lector;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lector;   -- solo lectura
REVOKE SELECT ON clientes FROM lector;
DROP USER lector;
```

## PostgreSQL vs MySQL: diferencias que te encontrarás

| | PostgreSQL | MySQL |
|---|---|---|
| Autoincremental | `IDENTITY` / `SERIAL` | `AUTO_INCREMENT` |
| Buscar sin mayúsculas | `ILIKE` | `LIKE` (depende del collation) |
| Devolver lo insertado | `RETURNING` | no existe |
| Comillas para nombres | `"columna"` | `` `columna` `` |
| JSON | `JSONB` (muy potente) | `JSON` |
| Booleano | `BOOLEAN` real | `TINYINT(1)` |
