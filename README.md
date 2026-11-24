# SQL y PostgreSQL: material de estudio

Apuntes para aprender SQL con PostgreSQL usando Docker, pgcli y Laravel.

## Índice

| Archivo | Tema |
|---|---|
| [01-docker-y-conexiones.md](01-docker-y-conexiones.md) | Cómo funciona Postgres en Docker y cómo conectarse |
| [02-pgcli-y-psql.md](02-pgcli-y-psql.md) | Comandos de la terminal (`\dt`, `\d`, `\c`...) |
| [03-sql-basico.md](03-sql-basico.md) | SELECT, WHERE, ORDER BY, INSERT, UPDATE, DELETE |
| [04-sql-intermedio.md](04-sql-intermedio.md) | JOINs, GROUP BY, subconsultas, CTE, transacciones |
| [05-crear-tablas-y-tipos.md](05-crear-tablas-y-tipos.md) | CREATE TABLE, tipos de datos, restricciones, índices |
| [06-laravel-y-base-de-datos.md](06-laravel-y-base-de-datos.md) | Migraciones, seeders, factories, tinker |
| [07-ejercicios.md](07-ejercicios.md) | Ejercicios con soluciones |
| [practica.sql](practica.sql) | Script que crea una base `practica` con datos para los ejercicios |

## Mi entorno

| Dato | Valor |
|---|---|
| Contenedor | `postgres` (imagen `postgres:17`) |
| Host desde mi PC | `localhost` |
| Host desde otro contenedor | `postgres` (nombre del contenedor) |
| Puerto | `5432` |
| Usuario | `admin` |
| Contraseña | `docker inspect postgres \| grep POSTGRES_PASSWORD` |
| Bases | `dev`, `lotteries` (Laravel), `practica` (ejercicios) |

## Empezar rápido

```bash
# Conectarme a la base de Laravel
pgcli -h localhost -U admin -d lotteries

# Crear la base de práctica (una sola vez)
docker exec postgres createdb -U admin practica
docker exec -i postgres psql -U admin -d practica < ~/Documents/SQL-Estudio/practica.sql

# Conectarme a la base de práctica
pgcli -h localhost -U admin -d practica
```

## Orden sugerido de estudio

1. Lee `01` y `02` y conéctate.
2. Practica `03` con la tabla `users` de `lotteries`.
3. Carga `practica.sql` y estudia `04` y `05`.
4. Resuelve `07-ejercicios.md` sin mirar las soluciones.
5. Lee `06` para conectar lo aprendido con Laravel.

## Recursos extra

- Documentación oficial: https://www.postgresql.org/docs/current/
- Tutorial interactivo: https://www.postgresqltutorial.com/
- Ejercicios en el navegador: https://pgexercises.com/
- Juego para aprender SQL: https://mystery.knightlab.com/
