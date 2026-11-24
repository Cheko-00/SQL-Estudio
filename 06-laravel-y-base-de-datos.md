# 06. Laravel y la base de datos

## Conexión (.env de la app)

```env
DB_CONNECTION=pgsql
DB_HOST=postgres        # nombre del contenedor (la app corre en Docker)
DB_PORT=5432
DB_DATABASE=lotteries
DB_USERNAME=admin
DB_PASSWORD=...
```

Si la app corriera **fuera** de Docker (`php artisan serve` en tu PC), usarías `DB_HOST=127.0.0.1`.

## Ejecutar artisan en Docker

Todos los comandos van con el prefijo `docker exec -it lottery-app`:

```bash
docker exec -it lottery-app php artisan migrate:status
```

Puedes crear un alias en `~/.bashrc` para escribir menos:

```bash
alias art='docker exec -it lottery-app php artisan'
# uso: art migrate
```

## Migraciones (la estructura de la base, versionada en código)

```bash
php artisan make:migration create_sorteos_table      # crear archivo nuevo
php artisan migrate                                  # ejecutar pendientes
php artisan migrate:status                           # cuáles se ejecutaron
php artisan migrate:rollback                         # deshacer el último lote
php artisan migrate:fresh                            # ⚠️ BORRA TODO y vuelve a migrar
php artisan migrate:fresh --seed                     # ⚠️ lo mismo + seeders
```

Ejemplo de migración (`database/migrations/xxxx_create_sorteos_table.php`):

```php
Schema::create('sorteos', function (Blueprint $table) {
    $table->id();                                   // BIGINT IDENTITY PRIMARY KEY
    $table->string('nombre');                       // VARCHAR(255) NOT NULL
    $table->date('fecha');
    $table->decimal('precio_boleto', 10, 2);        // NUMERIC(10,2)
    $table->decimal('premio', 12, 2);
    $table->boolean('activo')->default(true);
    $table->timestamps();                           // created_at, updated_at
});

Schema::create('boletos', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();   // FK a users.id
    $table->foreignId('sorteo_id')->constrained('sorteos');
    $table->unsignedInteger('numero');
    $table->unique(['sorteo_id', 'numero']);        // no repetir número en un sorteo
    $table->timestamps();
});
```

| Laravel | SQL generado |
|---|---|
| `$table->id()` | `id BIGINT ... PRIMARY KEY` |
| `->nullable()` | quita `NOT NULL` |
| `->unique()` | `UNIQUE` |
| `->default(x)` | `DEFAULT x` |
| `->index()` | `CREATE INDEX` |
| `foreignId()->constrained()` | `REFERENCES tabla(id)` |

**Regla:** nunca edites una migración ya ejecutada en producción. Crea una nueva que haga el cambio.

## Seeders y factories (datos de prueba)

```bash
php artisan make:factory SorteoFactory
php artisan make:seeder SorteoSeeder
php artisan db:seed                         # ejecuta DatabaseSeeder
php artisan db:seed --class=SorteoSeeder    # uno en concreto
```

```php
// database/seeders/DatabaseSeeder.php
User::factory(20)->create();
```

## Tinker: consola interactiva de Laravel

```bash
docker exec -it lottery-app php artisan tinker
```

```php
User::count();
User::first();
User::find(1);
User::where('email', 'like', '%.net')->get();
User::factory(5)->create();
```

## Eloquent vs SQL: equivalencias

| Eloquent | SQL |
|---|---|
| `User::all()` | `SELECT * FROM users;` |
| `User::find(1)` | `SELECT * FROM users WHERE id = 1 LIMIT 1;` |
| `User::where('id', '>', 5)->get()` | `SELECT * FROM users WHERE id > 5;` |
| `User::orderBy('name')->limit(5)->get()` | `SELECT * FROM users ORDER BY name LIMIT 5;` |
| `User::count()` | `SELECT COUNT(*) FROM users;` |
| `User::create([...])` | `INSERT INTO users (...) VALUES (...);` |
| `$user->update([...])` | `UPDATE users SET ... WHERE id = ?;` |
| `$user->delete()` | `DELETE FROM users WHERE id = ?;` |
| `User::with('boletos')->get()` | 2 consultas: users + boletos `WHERE user_id IN (...)` |
| `DB::select('SELECT ...')` | SQL directo |

### Ver el SQL que genera Eloquent

```php
User::where('id', '>', 5)->toSql();       // muestra el SQL con ?
User::where('id', '>', 5)->toRawSql();    // con los valores reales (Laravel 10.15+)
DB::enableQueryLog(); /* ... */ DB::getQueryLog();
```

Es una excelente forma de aprender SQL: escribe en Eloquent y mira qué SQL produce.

## El problema N+1

```php
// ❌ 1 consulta de usuarios + 1 consulta POR CADA usuario
foreach (User::all() as $u) { $u->boletos; }

// ✅ 2 consultas en total
foreach (User::with('boletos')->get() as $u) { $u->boletos; }
```
