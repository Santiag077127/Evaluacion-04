-- ============================================
-- REVOKE
-- ============================================

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM app_admin;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM app_admin;

REVOKE SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public FROM app_user;

REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM app_readonly;