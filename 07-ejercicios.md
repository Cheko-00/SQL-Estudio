# 07. Ejercicios

Primero carga la base de práctica (ver `README.md`) y conéctate:

```bash
pgcli -h localhost -U admin -d practica
```

Intenta resolver cada ejercicio **antes** de abrir la solución.

---

## Nivel 1: SELECT y WHERE

**1.1** Muestra el nombre y el email de todos los clientes.

<details><summary>Solución</summary>

```sql
SELECT nombre, email FROM clientes;
```
</details>

**1.2** Clientes que viven en `Guadalajara`.

<details><summary>Solución</summary>

```sql
SELECT * FROM clientes WHERE ciudad = 'Guadalajara';
```
</details>

**1.3** Clientes cuyo nombre empieza con `M`, ordenados alfabéticamente.

<details><summary>Solución</summary>

```sql
SELECT nombre FROM clientes WHERE nombre LIKE 'M%' ORDER BY nombre;
```
</details>

**1.4** Los 3 sorteos con mayor premio.

<details><summary>Solución</summary>

```sql
SELECT nombre, premio FROM sorteos ORDER BY premio DESC LIMIT 3;
```
</details>

**1.5** Sorteos con boleto entre 20 y 50 (incluidos).

<details><summary>Solución</summary>

```sql
SELECT * FROM sorteos WHERE precio_boleto BETWEEN 20 AND 50;
```
</details>

**1.6** Clientes registrados en 2025.

<details><summary>Solución</summary>

```sql
SELECT * FROM clientes WHERE EXTRACT(YEAR FROM fecha_registro) = 2025;
-- o, mejor para índices:
SELECT * FROM clientes WHERE fecha_registro >= '2025-01-01' AND fecha_registro < '2026-01-01';
```
</details>

---

## Nivel 2: agregación

**2.1** ¿Cuántos clientes hay?

<details><summary>Solución</summary>

```sql
SELECT COUNT(*) FROM clientes;
```
</details>

**2.2** ¿Cuántos clientes hay en cada ciudad? Ordena de mayor a menor.

<details><summary>Solución</summary>

```sql
SELECT ciudad, COUNT(*) AS total
FROM clientes
GROUP BY ciudad
ORDER BY total DESC;
```
</details>

**2.3** Premio promedio, mínimo y máximo de los sorteos.

<details><summary>Solución</summary>

```sql
SELECT ROUND(AVG(premio), 2) AS promedio, MIN(premio), MAX(premio) FROM sorteos;
```
</details>

**2.4** Ciudades con más de 2 clientes.

<details><summary>Solución</summary>

```sql
SELECT ciudad, COUNT(*) FROM clientes
GROUP BY ciudad
HAVING COUNT(*) > 2;
```
</details>

---

## Nivel 3: JOINs

**3.1** Lista cada boleto con el nombre del cliente y el nombre del sorteo.

<details><summary>Solución</summary>

```sql
SELECT b.numero, c.nombre AS cliente, s.nombre AS sorteo
FROM boletos b
JOIN clientes c ON c.id = b.cliente_id
JOIN sorteos  s ON s.id = b.sorteo_id;
```
</details>

**3.2** ¿Cuántos boletos compró cada cliente? Incluye a los que compraron 0.

<details><summary>Solución</summary>

```sql
SELECT c.nombre, COUNT(b.id) AS boletos
FROM clientes c
LEFT JOIN boletos b ON b.cliente_id = c.id
GROUP BY c.id, c.nombre
ORDER BY boletos DESC;
```
`COUNT(b.id)` y no `COUNT(*)`: así los clientes sin boletos cuentan 0.
</details>

**3.3** Clientes que **nunca** han comprado un boleto.

<details><summary>Solución</summary>

```sql
SELECT c.nombre
FROM clientes c
LEFT JOIN boletos b ON b.cliente_id = c.id
WHERE b.id IS NULL;
```
</details>

**3.4** Dinero recaudado por cada sorteo (boletos vendidos × precio).

<details><summary>Solución</summary>

```sql
SELECT s.nombre, COUNT(b.id) AS vendidos, COUNT(b.id) * s.precio_boleto AS recaudado
FROM sorteos s
LEFT JOIN boletos b ON b.sorteo_id = s.id
GROUP BY s.id, s.nombre, s.precio_boleto
ORDER BY recaudado DESC;
```
</details>

**3.5** El cliente que más dinero ha gastado.

<details><summary>Solución</summary>

```sql
SELECT c.nombre, SUM(s.precio_boleto) AS gastado
FROM clientes c
JOIN boletos b ON b.cliente_id = c.id
JOIN sorteos s ON s.id = b.sorteo_id
GROUP BY c.id, c.nombre
ORDER BY gastado DESC
LIMIT 1;
```
</details>

---

## Nivel 4: subconsultas, CTE y ventanas

**4.1** Sorteos cuyo premio está por encima del promedio.

<details><summary>Solución</summary>

```sql
SELECT nombre, premio FROM sorteos
WHERE premio > (SELECT AVG(premio) FROM sorteos);
```
</details>

**4.2** Clientes que participaron en el sorteo `Gran Sorteo Navidad` (usa `IN` o `EXISTS`).

<details><summary>Solución</summary>

```sql
SELECT nombre FROM clientes c
WHERE EXISTS (
  SELECT 1 FROM boletos b
  JOIN sorteos s ON s.id = b.sorteo_id
  WHERE b.cliente_id = c.id AND s.nombre = 'Gran Sorteo Navidad'
);
```
</details>

**4.3** Con un CTE, muestra los clientes que gastaron más de 100.

<details><summary>Solución</summary>

```sql
WITH gasto AS (
  SELECT b.cliente_id, SUM(s.precio_boleto) AS total
  FROM boletos b JOIN sorteos s ON s.id = b.sorteo_id
  GROUP BY b.cliente_id
)
SELECT c.nombre, g.total
FROM gasto g JOIN clientes c ON c.id = g.cliente_id
WHERE g.total > 100;
```
</details>

**4.4** Ranking de ciudades por número de boletos comprados (usa `RANK()`).

<details><summary>Solución</summary>

```sql
SELECT c.ciudad, COUNT(*) AS boletos,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS posicion
FROM boletos b JOIN clientes c ON c.id = b.cliente_id
GROUP BY c.ciudad;
```
</details>

---

## Nivel 5: modificar datos (dentro de una transacción)

**5.1** Dentro de una transacción, sube 10% el precio de todos los sorteos futuros. Revisa el resultado y deshazlo.

<details><summary>Solución</summary>

```sql
BEGIN;
UPDATE sorteos SET precio_boleto = precio_boleto * 1.10 WHERE fecha > CURRENT_DATE;
SELECT nombre, precio_boleto FROM sorteos;
ROLLBACK;
```
</details>

**5.2** Inserta un cliente nuevo y obtén su id con `RETURNING`.

<details><summary>Solución</summary>

```sql
INSERT INTO clientes (nombre, email, ciudad)
VALUES ('Sergio Prueba', 'sergio@example.com', 'CDMX')
RETURNING id;
```
</details>

**5.3** Intenta insertar un boleto con un `cliente_id` que no existe (por ejemplo, 999). ¿Qué pasa y por qué?

<details><summary>Solución</summary>

```sql
INSERT INTO boletos (cliente_id, sorteo_id, numero) VALUES (999, 1, 1234);
-- ERROR: violates foreign key constraint
```
La FK garantiza que solo existan boletos de clientes reales.
</details>

**5.4** Crea una tabla `premios_entregados` (id, boleto_id FK, monto, entregado_en) y agrégale un índice en `boleto_id`.

<details><summary>Solución</summary>

```sql
CREATE TABLE premios_entregados (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  boleto_id BIGINT NOT NULL REFERENCES boletos(id),
  monto NUMERIC(12,2) NOT NULL CHECK (monto > 0),
  entregado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_premios_boleto ON premios_entregados (boleto_id);
```
</details>

---

## Reto final

Haz un reporte por sorteo con:

- nombre del sorteo y fecha,
- boletos vendidos,
- clientes distintos,
- dinero recaudado,
- ganancia o pérdida (recaudado − premio).

Ordénalo por ganancia.

<details><summary>Solución</summary>

```sql
SELECT s.nombre, s.fecha,
       COUNT(b.id)                                AS vendidos,
       COUNT(DISTINCT b.cliente_id)               AS clientes,
       COUNT(b.id) * s.precio_boleto              AS recaudado,
       COUNT(b.id) * s.precio_boleto - s.premio   AS ganancia
FROM sorteos s
LEFT JOIN boletos b ON b.sorteo_id = s.id
GROUP BY s.id
ORDER BY ganancia DESC;
```
`GROUP BY s.id` basta porque `id` es la PK: Postgres sabe que las demás columnas de `s` dependen de ella.
</details>
