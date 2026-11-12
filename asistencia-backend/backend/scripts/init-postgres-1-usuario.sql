-- Ejecutar en pgAdmin como usuario postgres, conectado a la base "postgres".

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_asistente') THEN
    CREATE ROLE admin_asistente LOGIN PASSWORD 'ecosistema';
  ELSE
    ALTER ROLE admin_asistente WITH LOGIN PASSWORD 'ecosistema';
  END IF;
END
$$;
