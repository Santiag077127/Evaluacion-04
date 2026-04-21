-- ============================================
-- DROP ROLES
-- ============================================

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_readonly') THEN
        DROP ROLE app_readonly;
    END IF;

    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        DROP ROLE app_user;
    END IF;

    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_admin') THEN
        DROP ROLE app_admin;
    END IF;
END$$;