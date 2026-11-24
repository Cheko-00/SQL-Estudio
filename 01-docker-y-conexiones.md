# 01. Docker y conexiones

## La idea principal

```
 Mi PC (Omarchy)                       Docker
 ┌───────────────────────┐            ┌──────────────────────────┐
 │ pgcli / DBeaver       │──────────▶ │ contenedor "postgres"    │
 │ localhost:5432        │   puerto   │ PostgreSQL escucha 5432  │
 └───────────────────────┘  publicado └──────────────────────────┘
                                                   ▲
                                      ┌────────────┴─────────────┐
                                      │ contenedor "lottery-app" │
                                      │ DB_HOST=postgres         │
                                      └──────────────────────────┘
```

- PostgreSQL corre **dentro** del contenedor.
- `-p 5432:5432` publica el puerto: lo que llega a `localhost:5432` de mi PC va al contenedor.
- **Desde mi PC** me conecto a `localhost`.
- **Desde otro contenedor** (la app de Laravel) se usa el **nombre del contenedor** (`postgres`), porque están en la misma red de Docker. Dentro de un contenedor, `localhost` es el propio contenedor.

## Los 5 datos de cualquier conexión

| Dato | Ejemplo | Nota |
|---|---|---|
| Host | `localhost` | o `postgres` desde otro contenedor |
| Puerto | `5432` | el estándar de PostgreSQL |
| Usuario | `admin` | `POSTGRES_USER` |
| Contraseña | `****` | `POSTGRES_PASSWORD` |
| Base de datos | `lotteries` | `POSTGRES_DB` o la que crees |

## Formatos de conexión

```bash
# Con parámetros
pgcli -h localhost -p 5432 -U admin -d lotteries

# Como URL (formato de muchos frameworks y archivos .env)
pgcli postgresql://admin:PASSWORD@localhost:5432/lotteries

# Sin instalar nada: el psql que viene dentro del contenedor
docker exec -it postgres psql -U admin -d lotteries
```

Para no escribir la contraseña cada vez, crea `~/.pgpass`:

```
localhost:5432:*:admin:TU_PASSWORD
```

```bash
chmod 600 ~/.pgpass    # obligatorio; si no, se ignora
```

## Comandos de Docker útiles

```bash
docker ps                               # contenedores en marcha
docker ps -a                            # todos, incluso los detenidos
docker start postgres                   # arrancar
docker stop postgres                    # detener
docker logs -f postgres                 # ver logs en vivo
docker inspect postgres                 # toda la configuración
docker exec -it postgres bash           # entrar a una shell del contenedor
```

## Crear un contenedor de Postgres desde cero

```bash
docker run -d \
  --name postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secreto \
  -e POSTGRES_DB=dev \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:17
```

- `-e`: variables de entorno, que crean el usuario y la base inicial.
- `-v pgdata:...`: **volumen**. Guarda los datos fuera del contenedor. Sin él, si borras el contenedor pierdes los datos.
- Las variables `POSTGRES_*` solo se aplican **la primera vez**, cuando el volumen está vacío.

## Con docker compose (lo habitual en proyectos)

```yaml
services:
  postgres:
    image: postgres:17
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secreto
      POSTGRES_DB: dev
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
docker compose up -d
docker compose down          # detiene (los datos quedan en el volumen)
docker compose down -v       # detiene Y BORRA los datos
```

## Copias de seguridad

```bash
# Exportar una base a un archivo .sql
docker exec postgres pg_dump -U admin lotteries > respaldo.sql

# Restaurar
docker exec -i postgres psql -U admin -d lotteries < respaldo.sql

# Crear o borrar una base
docker exec postgres createdb -U admin nueva
docker exec postgres dropdb -U admin nueva
```

## Errores comunes

| Error | Causa probable |
|---|---|
| `connection refused` | el contenedor no está corriendo o el puerto no está publicado |
| `password authentication failed` | contraseña incorrecta |
| `database "x" does not exist` | sin `-d`, psql usa una base con el nombre del usuario |
| `port is already allocated` | ya hay otro Postgres usando el 5432; usa `-p 5433:5432` |
