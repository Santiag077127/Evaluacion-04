-- ============================================
-- DOMAIN: SECURITY
-- ============================================

-- ROLE
CREATE TABLE role (
    role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name varchar(50) NOT NULL,
    description varchar(200),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_role_name UNIQUE (role_name)
);

-- USER
CREATE TABLE app_user (
    user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id uuid NOT NULL REFERENCES role(role_id),
    username varchar(80) NOT NULL,
    email varchar(150) NOT NULL,
    password_hash text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_username UNIQUE (username),
    CONSTRAINT uq_user_email UNIQUE (email)
);

-- PERMISSION
CREATE TABLE permission (
    permission_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_name varchar(80) NOT NULL,
    description varchar(200),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_permission_name UNIQUE (permission_name)
);

-- ROLE_PERMISSION (PIVOTE)
CREATE TABLE role_permission (
    role_id uuid NOT NULL REFERENCES role(role_id),
    permission_id uuid NOT NULL REFERENCES permission(permission_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (role_id, permission_id)
);

-- USER_SESSION
CREATE TABLE user_session (
    session_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES app_user(user_id),
    token text NOT NULL,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- AUDIT_LOG
CREATE TABLE audit_log (
    audit_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES app_user(user_id),
    action varchar(100) NOT NULL,
    table_name varchar(100),
    record_id uuid,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- PASSWORD_RESET
CREATE TABLE password_reset (
    reset_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES app_user(user_id),
    reset_token text NOT NULL,
    expires_at timestamptz NOT NULL,
    used boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);