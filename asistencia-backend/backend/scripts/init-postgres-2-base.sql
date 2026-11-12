-- Ejecutar en pgAdmin como usuario postgres, conectado a la base "postgres".
-- Si dice que la base ya existe, está bien.

CREATE DATABASE asistencia_escolar OWNER admin_asistente;

-- Después abre la base asistencia_escolar y ejecuta:
-- GRANT ALL ON SCHEMA public TO admin_asistente;
-- ALTER SCHEMA public OWNER TO admin_asistente;
