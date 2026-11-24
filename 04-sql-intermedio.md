# 04. SQL intermedio

Los ejemplos usan la base `practica` (carga primero `practica.sql`). Sus tablas son:

```
clientes (id, nombre, email, ciudad, fecha_registro)
sorteos  (id, nombre, fecha, precio_boleto, premio)
boletos  (id, cliente_id → clientes.id, sorteo_id → sorteos.id, numero, comprado_en)
```

## Relaciones entre tablas

- **Clave primaria (PK)**: identifica cada fila de forma única. Normalmente es `id`.
- **Clave foránea (FK)**: una columna que apunta a la PK de otra tabla. Por ejemplo, `boletos.cliente_id` apunta a `clientes.id`.
- Tipos de relación:
  - **1 a N**: un cliente tiene muchos boletos.
  - **N a M**: clientes y sorteos, a través de la tabla intermedia `boletos`.
  - **1 a 1**: poco común. Por ejemplo, un usuario y su perfil.

## JOINs: combinar tablas

```
 INNER JOIN         LEFT JOIN          RIGHT JOIN         FULL JOIN
  ┌───┬───┐          ┌───┬───┐          ┌───┬───┐          ┌───┬───┐
  │ A │▓B │          │▓A▓│▓B │          │ A │▓B▓│          │▓A▓│▓B▓│
  └───┴───┘          └───┴───┘          └───┴───┘          └───┴───┘
 solo coinciden     todo A +          todo B +           todo de ambos
                    coincidencias     coincidencias
```

```sql
-- INNER JOIN: solo filas con coincidencia en ambas tablas
SELECT c.nombre, b.numero
FROM boletos b
JOIN clientes c ON c.id = b.cliente_id;

-- Tres tablas
SELECT c.nombre, s.nombre AS sorteo, b.numero
FROM boletos b
JOIN clientes c ON c.id = b.cliente_id
JOIN sorteos  s ON s.id = b.sorteo_id
ORDER BY s.fecha;

-- LEFT JOIN: TODOS los clientes, aunque no tengan boletos (sus columnas de b salen NULL)
SELECT c.nombre, b.numero
FROM clientes c
LEFT JOIN boletos b ON b.cliente_id = c.id;

-- Truco: clientes SIN boletos
SELECT c.nombre
FROM clientes c
LEFT JOIN boletos b ON b.cliente_id = c.id
WHERE b.id IS NULL;
```

`c` y `b` son **alias de tabla**. Hacen las consultas más cortas.

## GROUP BY con JOIN

```sql
-- Boletos y gasto total por cliente
SELECT c.nombre,
       COUNT(b.id)          AS boletos,
       SUM(s.precio_boleto) AS gastado
FROM clientes c
JOIN boletos b ON b.cliente_id = c.id
JOIN sorteos s ON s.id = b.sorteo_id
GROUP BY c.id, c.nombre
ORDER BY gastado DESC;

-- Sorteos con más de 3 boletos vendidos
SELECT s.nombre, COUNT(*) AS vendidos
FROM sorteos s
JOIN boletos b ON b.sorteo_id = s.id
GROUP BY s.id, s.nombre
HAVING COUNT(*) > 3;
```

`COUNT(*)` cuenta filas. `COUNT(columna)` no cuenta los NULL, lo cual importa con LEFT JOIN.

## Subconsultas

```sql
-- En WHERE
SELECT nombre FROM clientes
WHERE id IN (SELECT cliente_id FROM boletos WHERE sorteo_id = 1);

-- Con EXISTS (suele ser más eficiente)
SELECT nombre FROM clientes c
WHERE EXISTS (SELECT 1 FROM boletos b WHERE b.cliente_id = c.id);

-- Comparar con un valor calculado
SELECT nombre, premio FROM sorteos
WHERE premio > (SELECT AVG(premio) FROM sorteos);
```

## CTE (WITH): consultas con nombre

Sirven para dividir una consulta difícil en pasos legibles.

```sql
WITH gasto_por_cliente AS (
  SELECT b.cliente_id, SUM(s.precio_boleto) AS total
  FROM boletos b
  JOIN sorteos s ON s.id = b.sorteo_id
  GROUP BY b.cliente_id
)
SELECT c.nombre, g.total
FROM gasto_por_cliente g
JOIN clientes c ON c.id = g.cliente_id
WHERE g.total > 100
ORDER BY g.total DESC;
```

## Funciones de ventana (window functions)

Calculan valores **sin agrupar** las filas.

```sql
-- Ranking de clientes por gasto
SELECT nombre, total,
       RANK() OVER (ORDER BY total DESC) AS posicion
FROM (
  SELECT c.nombre, SUM(s.precio_boleto) AS total
  FROM clientes c
  JOIN boletos b ON b.cliente_id = c.id
  JOIN sorteos s ON s.id = b.sorteo_id
  GROUP BY c.nombre
) t;

-- Numerar los boletos de cada cliente en orden de compra
SELECT cliente_id, numero, comprado_en,
       ROW_NUMBER() OVER (PARTITION BY cliente_id ORDER BY comprado_en) AS n
FROM boletos;
```

## UNION

```sql
SELECT ciudad FROM clientes WHERE ciudad LIKE 'M%'
UNION                   -- quita duplicados (UNION ALL los mantiene)
SELECT ciudad FROM clientes WHERE ciudad LIKE 'G%';
```

## Transacciones: todo o nada

```sql
BEGIN;
  UPDATE clientes SET ciudad = 'Puebla' WHERE id = 1;
  DELETE FROM boletos WHERE cliente_id = 1;
  SELECT * FROM clientes WHERE id = 1;   -- reviso el resultado
ROLLBACK;   -- deshace TODO lo hecho desde BEGIN
-- o COMMIT; para guardarlo
```

Es la mejor red de seguridad mientras aprendes. Las aplicaciones la usan para operaciones que deben ocurrir juntas, como cobrar y emitir un boleto.

## Vistas: guardar una consulta

```sql
CREATE VIEW resumen_clientes AS
SELECT c.nombre, COUNT(b.id) AS boletos
FROM clientes c LEFT JOIN boletos b ON b.cliente_id = c.id
GROUP BY c.nombre;

SELECT * FROM resumen_clientes;   -- se usa como una tabla
DROP VIEW resumen_clientes;
```

## EXPLAIN: ¿por qué va lenta mi consulta?

```sql
EXPLAIN SELECT * FROM boletos WHERE cliente_id = 3;
EXPLAIN ANALYZE SELECT * FROM boletos WHERE cliente_id = 3;   -- la ejecuta de verdad
```

- `Seq Scan`: lee toda la tabla. Es lento en tablas grandes.
- `Index Scan`: usa un índice. Es rápido (ver `05`).
