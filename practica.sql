-- Base de práctica para los ejercicios.
-- Uso (desde la terminal):
--   docker exec postgres createdb -U admin practica
--   docker exec -i postgres psql -U admin -d practica < ~/Documents/SQL-Estudio/practica.sql
-- Se puede volver a ejecutar: borra y recrea las tablas.

DROP TABLE IF EXISTS premios_entregados, boletos, sorteos, clientes CASCADE;

CREATE TABLE clientes (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         VARCHAR(100) NOT NULL,
  email          VARCHAR(150) NOT NULL UNIQUE,
  ciudad         VARCHAR(60)  NOT NULL,
  fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE sorteos (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre        VARCHAR(100) NOT NULL UNIQUE,
  fecha         DATE NOT NULL,
  precio_boleto NUMERIC(10,2) NOT NULL CHECK (precio_boleto > 0),
  premio        NUMERIC(12,2) NOT NULL CHECK (premio > 0)
);

CREATE TABLE boletos (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cliente_id  BIGINT NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  sorteo_id   BIGINT NOT NULL REFERENCES sorteos(id),
  numero      INTEGER NOT NULL CHECK (numero BETWEEN 0 AND 9999),
  comprado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (sorteo_id, numero)
);

CREATE INDEX idx_boletos_cliente ON boletos (cliente_id);
CREATE INDEX idx_boletos_sorteo  ON boletos (sorteo_id);

INSERT INTO clientes (nombre, email, ciudad, fecha_registro) VALUES
  ('María López',      'maria@example.com',     'CDMX',        '2024-03-10'),
  ('Juan Pérez',       'juan@example.com',      'Guadalajara', '2024-07-22'),
  ('Ana Torres',       'ana@example.com',       'Monterrey',   '2025-01-05'),
  ('Luis Hernández',   'luis@example.com',      'CDMX',        '2025-02-14'),
  ('Marta Ruiz',       'marta@example.com',     'Puebla',      '2025-04-30'),
  ('Carlos Gómez',     'carlos@example.com',    'Guadalajara', '2025-06-18'),
  ('Sofía Díaz',       'sofia@example.com',     'CDMX',        '2025-08-02'),
  ('Miguel Castro',    'miguel@example.com',    'Mérida',      '2025-09-12'),
  ('Laura Morales',    'laura@example.com',     'Monterrey',   '2025-11-25'),
  ('Diego Vargas',     'diego@example.com',     'Guadalajara', '2026-01-08'),
  ('Elena Ramos',      'elena@example.com',     'CDMX',        '2026-03-19'),
  ('Pablo Ortiz',      'pablo@example.com',     'Querétaro',   '2026-06-01'),
  ('Valeria Silva',    'valeria@example.com',   'Puebla',      '2026-08-15'),
  ('Martín Navarro',   'martin@example.com',    'Mérida',      '2026-10-03');

INSERT INTO sorteos (nombre, fecha, precio_boleto, premio) VALUES
  ('Sorteo Primavera',     '2026-03-21', 20.00,   5000.00),
  ('Sorteo Verano',        '2026-06-21', 35.00,  10000.00),
  ('Sorteo Patrio',        '2026-09-15', 50.00,  20000.00),
  ('Gran Sorteo Navidad',  '2026-12-24', 100.00, 100000.00),
  ('Sorteo Año Nuevo',     '2027-01-01', 75.00,  50000.00);

INSERT INTO boletos (cliente_id, sorteo_id, numero, comprado_en) VALUES
  (1, 1,  123, '2026-03-01 10:00'), (1, 2,  456, '2026-06-01 11:30'),
  (1, 4, 7777, '2026-11-01 09:15'), (1, 4, 7778, '2026-11-01 09:16'),
  (2, 1, 1001, '2026-03-05 18:20'), (2, 3, 2002, '2026-09-01 12:00'),
  (3, 2, 3003, '2026-06-10 08:45'), (3, 4, 1224, '2026-11-05 20:10'),
  (3, 5, 2027, '2026-11-10 21:00'), (4, 1,   42, '2026-03-15 16:00'),
  (4, 2,   43, '2026-06-15 16:00'), (4, 3,   44, '2026-09-10 16:00'),
  (4, 4,   45, '2026-11-12 16:00'), (5, 3, 9999, '2026-09-12 07:30'),
  (6, 4, 5555, '2026-11-08 13:40'), (6, 5, 5556, '2026-11-09 13:40'),
  (7, 1, 8080, '2026-03-18 22:00'), (7, 4, 8081, '2026-11-11 22:00'),
  (8, 2, 1500, '2026-06-18 10:10'), (9, 3, 1600, '2026-09-14 19:50'),
  (9, 4, 1601, '2026-11-13 19:50'), (9, 5, 1602, '2026-11-13 19:51'),
  (10, 4, 3333, '2026-11-02 15:25'), (11, 5,  100, '2026-11-14 08:00');
-- Clientes 12, 13 y 14 no tienen boletos (útil para practicar LEFT JOIN).
