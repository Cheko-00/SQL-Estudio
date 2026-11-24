# 03. SQL básico

Puedes practicar todo esto con la tabla `users` de la base `lotteries`.

## Orden de escritura de un SELECT

```sql
SELECT   columnas          -- 5. qué mostrar
FROM     tabla             -- 1. de dónde
WHERE    condición         -- 2. filtrar filas
GROUP BY columnas          -- 3. agrupar
HAVING   condición         -- 4. filtrar grupos
ORDER BY columnas          -- 6. ordenar
LIMIT    n OFFSET m;       -- 7. paginar
```

El número indica el **orden en que Postgres lo ejecuta**. Por eso un alias del `SELECT` no puede usarse en el `WHERE`: el `WHERE` se ejecuta antes.

## SELECT: leer datos

```sql
SELECT * FROM users;                          -- todas las columnas
SELECT id, name, email FROM users;            -- algunas columnas
SELECT name AS nombre FROM users;             -- alias de columna
SELECT DISTINCT email FROM users;             -- sin duplicados
SELECT COUNT(*) FROM users;                   -- contar filas
```

## WHERE: filtrar

```sql
SELECT * FROM users WHERE id = 1;
SELECT * FROM users WHERE id <> 1;                    -- distinto (también !=)
SELECT * FROM users WHERE id > 5 AND id <= 10;
SELECT * FROM users WHERE id < 3 OR id > 19;
SELECT * FROM users WHERE id BETWEEN 5 AND 10;        -- incluye 5 y 10
SELECT * FROM users WHERE id IN (1, 3, 5);
SELECT * FROM users WHERE id NOT IN (1, 3, 5);
```

### Texto

```sql
SELECT * FROM users WHERE name = 'Test User';         -- comillas SIMPLES para texto
SELECT * FROM users WHERE name LIKE 'Dr.%';           -- empieza con "Dr."
SELECT * FROM users WHERE email LIKE '%.net';         -- termina en ".net"
SELECT * FROM users WHERE name LIKE '%an%';           -- contiene "an"
SELECT * FROM users WHERE name ILIKE '%AN%';          -- igual, sin distinguir mayúsculas (solo Postgres)
SELECT * FROM users WHERE name LIKE '_a%';            -- _ = exactamente un carácter
```

- `'texto'`: comillas simples para **valores**.
- `"columna"`: comillas dobles para **nombres** de tablas o columnas (rara vez se necesitan).

### NULL (valor desconocido o vacío)

```sql
SELECT * FROM users WHERE email_verified_at IS NULL;
SELECT * FROM users WHERE email_verified_at IS NOT NULL;
-- ❌ WHERE columna = NULL   nunca funciona; usa IS NULL
SELECT COALESCE(email_verified_at::text, 'sin verificar') FROM users;  -- valor por defecto si es NULL
```

## ORDER BY y LIMIT

```sql
SELECT * FROM users ORDER BY name;                    -- A → Z (ASC por defecto)
SELECT * FROM users ORDER BY name DESC;               -- Z → A
SELECT * FROM users ORDER BY created_at DESC, id ASC; -- varios criterios
SELECT * FROM users ORDER BY id LIMIT 5;              -- primeros 5
SELECT * FROM users ORDER BY id LIMIT 5 OFFSET 5;     -- página 2 (filas 6 a 10)
```

## Funciones útiles

```sql
-- Texto
SELECT UPPER(name), LOWER(email), LENGTH(name) FROM users;
SELECT name || ' <' || email || '>' AS contacto FROM users;   -- concatenar
SELECT split_part(email, '@', 2) AS dominio FROM users;       -- partir texto
SELECT TRIM('  hola  '), REPLACE('a-b-c', '-', '/');

-- Fechas
SELECT NOW(), CURRENT_DATE;
SELECT created_at::date FROM users;                           -- convertir (cast)
SELECT EXTRACT(YEAR FROM created_at) FROM users;
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';
SELECT DATE_TRUNC('day', created_at) FROM users;

-- Números
SELECT ROUND(10.567, 2), CEIL(4.1), FLOOR(4.9), ABS(-3);
```

## Agregación básica

```sql
SELECT COUNT(*) FROM users;
SELECT MIN(id), MAX(id), AVG(id), SUM(id) FROM users;

SELECT split_part(email, '@', 2) AS dominio, COUNT(*) AS total
FROM users
GROUP BY dominio
HAVING COUNT(*) > 5            -- HAVING filtra GRUPOS; WHERE filtra FILAS
ORDER BY total DESC;
```

**Regla:** cada columna del `SELECT` que no esté dentro de una función de agregación (`COUNT`, `SUM`...) debe aparecer en el `GROUP BY`.

## CASE (un if/else en SQL)

```sql
SELECT name,
  CASE
    WHEN email LIKE '%.org' THEN 'organización'
    WHEN email LIKE '%.net' THEN 'red'
    ELSE 'otro'
  END AS tipo
FROM users;
```

## INSERT: agregar datos

```sql
INSERT INTO users (name, email, password, created_at, updated_at)
VALUES ('Ana', 'ana@example.com', 'x', NOW(), NOW());

-- Varias filas a la vez
INSERT INTO users (name, email, password) VALUES
  ('Luis', 'luis@example.com', 'x'),
  ('Eva',  'eva@example.com',  'x');

-- Devolver lo insertado (solo Postgres)
INSERT INTO users (name, email, password)
VALUES ('Leo', 'leo@example.com', 'x')
RETURNING id, name;
```

## UPDATE: modificar

```sql
UPDATE users SET name = 'Ana María' WHERE id = 22;
UPDATE users SET name = 'X', updated_at = NOW() WHERE email = 'ana@example.com';
```

## DELETE: borrar

```sql
DELETE FROM users WHERE id = 22;
DELETE FROM users WHERE email LIKE '%@example.com' RETURNING id;
```

## ⚠️ Regla de oro

> **UPDATE y DELETE sin WHERE afectan a TODAS las filas.**

Hábito seguro:

1. Escribe primero el `SELECT` con el mismo `WHERE`: `SELECT * FROM users WHERE id = 22;`
2. Si devuelve lo que esperas, cambia `SELECT *` por `DELETE`.
3. O usa una transacción (ver `04-sql-intermedio.md`): `BEGIN; ... ROLLBACK;`
