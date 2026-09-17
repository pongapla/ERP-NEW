-- ERP-NEW
-- Seed: User Module 1.0
-- PostgreSQL
BEGIN;

INSERT INTO
    permissions (
        code,
        name,
        module,
        description
    )
VALUES (
        'USER_VIEW',
        'View Users',
        'USER',
        'View users'
    ),
    (
        'USER_CREATE',
        'Create Users',
        'USER',
        'Create users'
    ),
    (
        'USER_UPDATE',
        'Update Users',
        'USER',
        'Update user information'
    ),
    (
        'USER_DISABLE',
        'Disable Users',
        'USER',
        'Activate or deactivate users'
    ),
    (
        'USER_RESET_PASSWORD',
        'Reset User Password',
        'USER',
        'Reset another user password'
    ),
    (
        'ROLE_VIEW',
        'View Roles',
        'USER',
        'View roles'
    ),
    (
        'ROLE_CREATE',
        'Create Roles',
        'USER',
        'Create roles'
    ),
    (
        'ROLE_UPDATE',
        'Update Roles',
        'USER',
        'Update roles'
    ),
    (
        'ROLE_ASSIGN',
        'Assign Roles',
        'USER',
        'Assign roles to users'
    ),
    (
        'PERMISSION_VIEW',
        'View Permissions',
        'USER',
        'View system permissions'
    ),
    (
        'PERMISSION_ASSIGN',
        'Assign Permissions',
        'USER',
        'Assign permissions to roles'
    ) ON CONFLICT (code) DO NOTHING;

INSERT INTO
    roles (
        company_id,
        code,
        name,
        description,
        is_system,
        is_active
    )
SELECT NULL, 'SUPER_ADMIN', 'Super Administrator', 'System-level administrator', TRUE, TRUE
WHERE
    NOT EXISTS (
        SELECT 1
        FROM roles
        WHERE
            company_id IS NULL
            AND code = 'SUPER_ADMIN'
    );

INSERT INTO
    role_permissions (
        role_id,
        permission_id,
        assigned_by
    )
SELECT r.id, p.id, NULL
FROM roles r
    CROSS JOIN permissions p
WHERE
    r.company_id IS NULL
    AND r.code = 'SUPER_ADMIN' ON CONFLICT (role_id, permission_id) DO NOTHING;

COMMIT;