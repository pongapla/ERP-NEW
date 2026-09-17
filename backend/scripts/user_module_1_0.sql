-- ERP-NEW - User Module 1.0
-- PostgreSQL

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS companies (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(50)  NOT NULL UNIQUE,
    name        VARCHAR(255) NOT NULL,
    tax_id      VARCHAR(50),
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_companies_is_active
    ON companies (is_active);

CREATE TABLE IF NOT EXISTS users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID,
    username            VARCHAR(100) NOT NULL UNIQUE,
    email               VARCHAR(255) UNIQUE,
    password_hash       TEXT         NOT NULL,
    first_name          VARCHAR(150) NOT NULL,
    last_name           VARCHAR(150) NOT NULL,
    employee_code       VARCHAR(100),
    phone               VARCHAR(50),
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    last_login_at       TIMESTAMPTZ,
    password_changed_at TIMESTAMPTZ,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by          UUID,
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by          UUID,

    CONSTRAINT fk_users_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_users_company_id
    ON users (company_id);

CREATE INDEX IF NOT EXISTS idx_users_is_active
    ON users (is_active);

CREATE INDEX IF NOT EXISTS idx_users_employee_code
    ON users (company_id, employee_code);

CREATE TABLE IF NOT EXISTS roles (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id   UUID,
    code         VARCHAR(100) NOT NULL,
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    is_system    BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by   UUID,
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by   UUID,

    CONSTRAINT fk_roles_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_roles_company_code
    ON roles (company_id, code)
    WHERE company_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_roles_system_code
    ON roles (code)
    WHERE company_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_roles_company_id
    ON roles (company_id);

CREATE INDEX IF NOT EXISTS idx_roles_is_active
    ON roles (is_active);

CREATE TABLE IF NOT EXISTS permissions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code         VARCHAR(150) NOT NULL UNIQUE,
    name         VARCHAR(200) NOT NULL,
    module       VARCHAR(100) NOT NULL,
    description  TEXT,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_permissions_module
    ON permissions (module);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id       UUID        NOT NULL,
    role_id       UUID        NOT NULL,
    assigned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by   UUID,

    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_roles_role_id
    ON user_roles (role_id);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id        UUID        NOT NULL,
    permission_id  UUID        NOT NULL,
    assigned_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by    UUID,

    CONSTRAINT pk_role_permissions PRIMARY KEY (role_id, permission_id),

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permission
        FOREIGN KEY (permission_id)
        REFERENCES permissions(id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id
    ON role_permissions (permission_id);

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS fk_users_created_by,
    ADD CONSTRAINT fk_users_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS fk_users_updated_by,
    ADD CONSTRAINT fk_users_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

ALTER TABLE roles
    DROP CONSTRAINT IF EXISTS fk_roles_created_by,
    ADD CONSTRAINT fk_roles_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

ALTER TABLE roles
    DROP CONSTRAINT IF EXISTS fk_roles_updated_by,
    ADD CONSTRAINT fk_roles_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

ALTER TABLE user_roles
    DROP CONSTRAINT IF EXISTS fk_user_roles_assigned_by,
    ADD CONSTRAINT fk_user_roles_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

ALTER TABLE role_permissions
    DROP CONSTRAINT IF EXISTS fk_role_permissions_assigned_by,
    ADD CONSTRAINT fk_role_permissions_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES users(id)
        ON UPDATE RESTRICT
        ON DELETE SET NULL;

INSERT INTO permissions (code, name, module, description)
VALUES
    ('USER_VIEW', 'View Users', 'USER', 'View users'),
    ('USER_CREATE', 'Create Users', 'USER', 'Create users'),
    ('USER_UPDATE', 'Update Users', 'USER', 'Update user information'),
    ('USER_DISABLE', 'Disable Users', 'USER', 'Activate or deactivate users'),
    ('USER_RESET_PASSWORD', 'Reset User Password', 'USER', 'Reset another user password'),
    ('ROLE_VIEW', 'View Roles', 'USER', 'View roles'),
    ('ROLE_CREATE', 'Create Roles', 'USER', 'Create roles'),
    ('ROLE_UPDATE', 'Update Roles', 'USER', 'Update roles'),
    ('ROLE_ASSIGN', 'Assign Roles', 'USER', 'Assign roles to users'),
    ('PERMISSION_VIEW', 'View Permissions', 'USER', 'View system permissions'),
    ('PERMISSION_ASSIGN', 'Assign Permissions', 'USER', 'Assign permissions to roles')
ON CONFLICT (code) DO NOTHING;

INSERT INTO roles (
    company_id,
    code,
    name,
    description,
    is_system,
    is_active
)
SELECT
    NULL,
    'SUPER_ADMIN',
    'Super Administrator',
    'System-level administrator',
    TRUE,
    TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM roles
    WHERE company_id IS NULL
      AND code = 'SUPER_ADMIN'
);

INSERT INTO role_permissions (
    role_id,
    permission_id,
    assigned_by
)
SELECT
    r.id,
    p.id,
    NULL
FROM roles r
CROSS JOIN permissions p
WHERE r.company_id IS NULL
  AND r.code = 'SUPER_ADMIN'
ON CONFLICT (role_id, permission_id) DO NOTHING;

COMMIT;

-- Notes:
-- 1. This script does not create the first SUPER_ADMIN user.
--    The backend should generate password_hash using the chosen password hashing algorithm.
-- 2. Application logic must prevent cross-company role assignment.
-- 3. Normal users should be deactivated instead of hard-deleted.
