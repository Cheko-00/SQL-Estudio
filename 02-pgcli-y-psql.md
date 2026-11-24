# 02. pgcli y psql: comandos de la terminal

`pgcli` y `psql` son clientes de terminal. Entienden dos tipos de comandos:

- **Meta-comandos**: empiezan con `\`. Son del cliente, no son SQL, y no llevan `;`.
- **SQL**: consultas normales. **Terminan en `;`.**

## Navegación

| Comando | Qué hace |
|---|---|
| `\l` | listar bases de datos |
| `\c nombre` | conectarse a otra base |
| `\dn` | listar esquemas |
| `\dt` | listar tablas |
| `\dt+` | tablas con tamaño |
| `\d tabla` | columnas, tipos, índices y relaciones de una tabla |
| `\d+ tabla` | lo mismo, con más detalle |
| `\di` | listar índices |
| `\dv` | listar vistas |
| `\df` | listar funciones |
| `\du` | listar usuarios y roles |
| `\conninfo` | a qué estoy conectado |
| `\q` | salir |
| `\?` | ayuda de meta-comandos |
| `\h SELECT` | ayuda de sintaxis SQL |

## Utilidades

| Comando | Qué hace |
|---|---|
| `\x` | modo expandido: una columna por línea (útil con tablas anchas) |
| `\timing` | mostrar cuánto tarda cada consulta |
| `\i archivo.sql` | ejecutar un archivo SQL |
| `\e` | abrir la consulta en tu editor (`$EDITOR`) |
| `\! comando` | ejecutar un comando de shell |

## Extras de pgcli

- **Autocompletado** de tablas, columnas y palabras clave con `Tab`.
- **F3**: activa o desactiva el modo multilínea.
- **F4**: alterna modo vi/emacs.
- `\dt` y `\d` con resaltado de colores.
- Historial con flecha arriba y `Ctrl+R` para buscar.
- Configuración en `~/.config/pgcli/config`. Ahí puedes cambiar el tema con `syntax_style = monokai`.

## Atajos de teclado

| Tecla | Acción |
|---|---|
| `Ctrl+C` | cancelar la línea o consulta actual |
| `Ctrl+D` | salir |
| `Ctrl+R` | buscar en el historial |
| `Ctrl+L` | limpiar pantalla |

## Ejecutar SQL sin entrar al cliente

```bash
# Una consulta suelta
psql -h localhost -U admin -d lotteries -c "SELECT COUNT(*) FROM users;"

# Usando el psql del contenedor
docker exec postgres psql -U admin -d lotteries -c "\dt"

# Ejecutar un archivo
docker exec -i postgres psql -U admin -d practica < practica.sql
```
