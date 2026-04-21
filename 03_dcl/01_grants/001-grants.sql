-- ============================================
-- GRANTS
-- ============================================

-- ADMIN (todo)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;

-- USER (lectura + escritura)
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_user;

-- READONLY (solo lectura)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;