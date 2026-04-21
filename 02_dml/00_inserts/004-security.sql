INSERT INTO user_status (status_code, status_name)
VALUES ('ACTIVE', 'Activo');

INSERT INTO security_role (role_code, role_name)
VALUES ('ADMIN', 'Administrador');

INSERT INTO security_permission (permission_code, permission_name)
VALUES ('FULL', 'Acceso total');

INSERT INTO user_account (person_id, user_status_id, username, password_hash)
SELECT p.person_id, us.user_status_id, 'juanp', 'hash123'
FROM person p, user_status us;

INSERT INTO user_role (user_account_id, security_role_id)
SELECT ua.user_account_id, sr.security_role_id
FROM user_account ua, security_role sr;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT sr.security_role_id, sp.security_permission_id
FROM security_role sr, security_permission sp;