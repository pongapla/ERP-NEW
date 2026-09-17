ERP — User Module 1.0

Status: Draft / Foundation Module
Version: 1.0
Purpose: วางระบบ User, Role, Permission และ Company/Tenant ให้เป็นฐานกลางของ ERP ก่อนพัฒนา Module อื่นต่อ

1. เป้าหมาย

User Module 1.0 เป็น Module พื้นฐานของระบบ ERP ใช้สำหรับจัดการ:

ผู้ใช้งานระบบ

บริษัท / Tenant ที่ผู้ใช้สังกัด

Role

Permission

การเปิด / ปิดผู้ใช้งาน

การเข้าสู่ระบบ

การควบคุมสิทธิ์ในแต่ละ Module

Audit ข้อมูลสำคัญเกี่ยวกับ User

แนวทางหลักคือ:

ทุก Module เช่น Purchasing, Sales, Inventory, Accounting หรือ Production จะไม่กำหนดสิทธิ์แบบ hard-code แยกกัน แต่จะอ้างอิง Permission จาก User Module กลาง

2. Scope ของ User Module 1.0

Included

Authentication

Login

Logout

Session / Token

ตรวจสอบสถานะ User

เปลี่ยน Password

Reset Password โดย Admin

User Management

Create User

Edit User

View User

Activate User

Deactivate User

Assign Role

กำหนด Company

Role Management

Create Role

Edit Role

Activate / Deactivate Role

Assign Permission ให้ Role

Permission Management

Permission เป็นค่าที่ระบบกำหนด

ใช้ Permission ครอบการทำงานในแต่ละ Module

รองรับเพิ่ม Permission ตาม Module ใหม่ในอนาคต

Company / Tenant

User ต้องสังกัด Company

ข้อมูลของแต่ละ Company ต้องแยกจากกัน

User ปกติไม่สามารถเห็นข้อมูลข้าม Company ได้

Audit

created_at

created_by

updated_at

updated_by

last_login_at

password_changed_at

3. Out of Scope สำหรับ Version 1.0

ยังไม่ทำในรอบแรก:

SSO

Microsoft / Google Login

LDAP / Active Directory

MFA / OTP

IP Restriction

Advanced Approval Delegation

Temporary Permission

Permission ตาม Branch / Department แบบละเอียด

User impersonation

External Customer Portal Account

สิ่งเหล่านี้สามารถเพิ่มใน Version ถัดไปได้

4. แนวคิด Multi-Tenant

ERP จะรองรับหลายบริษัท

ตัวอย่าง:

ERP System
│
├── Company A
│ ├── Users
│ ├── Roles
│ ├── PR
│ ├── PO
│ └── GR
│
├── Company B
│ ├── Users
│ ├── Roles
│ ├── PR
│ ├── PO
│ └── GR
│
└── Company C

ข้อมูล Transaction ของแต่ละ Company ต้องแยกจากกัน

หลักสำคัญ:

User
↓
Company
↓
Role
↓
Permission

5. User Model

ข้อมูลหลักของ User ควรมีอย่างน้อย:

Field

Description

id

Primary Key

company_id

บริษัทที่ User สังกัด

username

Username

email

Email

password_hash

Password Hash

first_name

ชื่อ

last_name

นามสกุล

employee_code

รหัสพนักงาน

phone

เบอร์โทร

is_active

เปิด / ปิด User

last_login_at

Login ล่าสุด

password_changed_at

วันที่เปลี่ยน Password

created_at

วันที่สร้าง

created_by

ผู้สร้าง

updated_at

วันที่แก้ไข

updated_by

ผู้แก้ไข

หมายเหตุ:

ห้ามเก็บ Password แบบ plain text

Password ต้อง hash ก่อนบันทึก

Email / Username ควรมี Unique Constraint ตามกติกาที่กำหนด

User ที่ถูก Disable ต้อง Login ไม่ได้

6. Company Model

ข้อมูลเบื้องต้น:

Field

Description

id

Primary Key

code

Company Code

name

ชื่อบริษัท

tax_id

เลขประจำตัวผู้เสียภาษี

is_active

สถานะ

created_at

วันที่สร้าง

updated_at

วันที่แก้ไข

ในอนาคต Company จะเชื่อมกับ:

Document Settings

Running Number

Purchasing

Sales

Inventory

Accounting

Approval Flow

7. Role Model

Role คือกลุ่มสิทธิ์ของ User

ตัวอย่าง:

SUPER_ADMIN
COMPANY_ADMIN
PURCHASING_MANAGER
PURCHASING_USER
APPROVER
VIEWER

Field เบื้องต้น:

Field

Description

id

Primary Key

company_id

Company

code

Role Code

name

Role Name

description

รายละเอียด

is_system

Role ระบบหรือไม่

is_active

สถานะ

created_at

วันที่สร้าง

created_by

ผู้สร้าง

updated_at

วันที่แก้ไข

updated_by

ผู้แก้ไข

8. Permission Model

Permission ควรใช้รูปแบบ:

MODULE_ACTION

หรือ

module.resource.action

ตัวอย่าง Version แรก:

USER_VIEW
USER_CREATE
USER_UPDATE
USER_DISABLE

ROLE_VIEW
ROLE_CREATE
ROLE_UPDATE

PURCHASE_PR_VIEW
PURCHASE_PR_CREATE
PURCHASE_PR_UPDATE
PURCHASE_PR_CANCEL
PURCHASE_PR_APPROVE

PURCHASE_PO_VIEW
PURCHASE_PO_CREATE
PURCHASE_PO_UPDATE
PURCHASE_PO_CANCEL

PURCHASE_GR_VIEW
PURCHASE_GR_CREATE
PURCHASE_GR_UPDATE

Permission ไม่ควรผูกตรงกับชื่อหน้า UI

ควรผูกกับ "ความสามารถ" ของระบบ

ตัวอย่าง:

PURCHASE_PR_APPROVE

หมายถึงมีสิทธิ์ Approve PR ไม่ว่าผู้ใช้จะเข้าจากหน้าใดก็ตาม

9. User ↔ Role

Version 1.0 แนะนำให้รองรับ:

1 User สามารถมีได้หลาย Role

ตัวอย่าง:

Somchai
├── PURCHASING_USER
└── APPROVER

ตารางเชื่อม:

user_roles

Field:

Field

Description

user_id

User

role_id

Role

assigned_at

วันที่ Assign

assigned_by

ผู้ Assign

10. Role ↔ Permission

ใช้ตารางกลาง:

role_permissions

Field:

Field

Description

role_id

Role

permission_id

Permission

assigned_at

วันที่ Assign

assigned_by

ผู้ Assign

Flow:

User
↓
User Roles
↓
Roles
↓
Role Permissions
↓
Permissions

11. ER Diagram — Draft

erDiagram

    COMPANY ||--o{ USER : has
    COMPANY ||--o{ ROLE : has

    USER ||--o{ USER_ROLE : assigned
    ROLE ||--o{ USER_ROLE : contains

    ROLE ||--o{ ROLE_PERMISSION : has
    PERMISSION ||--o{ ROLE_PERMISSION : contains

    COMPANY {
        uuid id
        string code
        string name
        boolean is_active
    }

    USER {
        uuid id
        uuid company_id
        string username
        string email
        string password_hash
        string first_name
        string last_name
        string employee_code
        boolean is_active
        datetime last_login_at
        datetime created_at
        datetime updated_at
    }

    ROLE {
        uuid id
        uuid company_id
        string code
        string name
        boolean is_system
        boolean is_active
    }

    PERMISSION {
        uuid id
        string code
        string name
        string module
    }

    USER_ROLE {
        uuid user_id
        uuid role_id
        datetime assigned_at
    }

    ROLE_PERMISSION {
        uuid role_id
        uuid permission_id
        datetime assigned_at
    }

12. System Roles เบื้องต้น

SUPER_ADMIN

สำหรับเจ้าของระบบ SaaS

สามารถ:

จัดการ Company

จัดการ Company Admin

ดูสถานะระบบ

จัดการระบบกลาง

ไม่ควรใช้เป็น User ปฏิบัติงานทั่วไปในบริษัทลูกค้า

COMPANY_ADMIN

Administrator ของแต่ละบริษัท

สามารถ:

Manage Users

Manage Roles

Assign Permissions

ดู Module ของ Company

ตั้งค่าระบบบริษัท

USER

ไม่มีสิทธิ์โดยอัตโนมัติ

สิทธิ์ขึ้นอยู่กับ Role ที่ถูก Assign

13. Permission Resolution

Backend ต้องเป็นผู้ตัดสิน Permission

Frontend มีหน้าที่:

ซ่อน Menu

Disable Button

ปรับ UX ตาม Permission

แต่ Backend ต้องตรวจอีกครั้งทุก Request

ตัวอย่าง:

Frontend:
ไม่มี PURCHASE_PR_APPROVE
→ ไม่แสดงปุ่ม Approve

Backend:
POST /purchase/pr/:id/approve
→ ตรวจ PURCHASE_PR_APPROVE อีกครั้ง

ห้ามเชื่อ Permission จาก Frontend อย่างเดียว

14. Login Flow

User กรอก Username / Email + Password
↓
ตรวจ User
↓
ตรวจ is_active
↓
ตรวจ Password
↓
โหลด Company
↓
โหลด Roles
↓
โหลด Permissions
↓
สร้าง Session / Token
↓
Login สำเร็จ

15. User Status

Version 1.0 ใช้สถานะพื้นฐาน:

ACTIVE
INACTIVE

ในอนาคตอาจเพิ่ม:

LOCKED
SUSPENDED
PENDING

แต่ Version 1.0 ยังไม่จำเป็น

16. Delete Policy

User ไม่ควรถูก Hard Delete หลังจากมี Transaction

ใช้:

is_active = false

เหตุผล:

User อาจเคย:

สร้าง PR

Approve PR

สร้าง PO

รับสินค้า

แก้ข้อมูล

ออกเอกสาร

หากลบ User จริง Audit Trail จะเสีย

17. Audit Principle

Transaction สำคัญควรเก็บ:

created_by
updated_by
approved_by
cancelled_by

และอ้างอิง user.id

ตัวอย่าง Purchasing:

PR
├── created_by → User
├── updated_by → User
├── submitted_by → User
├── approved_by → User
└── cancelled_by → User

ดังนั้น User Module ต้องทำก่อน Purchasing เพื่อไม่ต้องย้อนโครงสร้างภายหลัง

18. User Management UI

Menu:

Administration
├── Users
├── Roles
└── Permissions

User List

แสดง:

Employee Code

Name

Username

Email

Role

Status

Last Login

Action:

View

Edit

Activate

Deactivate

Reset Password

Create User

Fields:

Employee Code
First Name
Last Name
Username
Email
Phone
Password / Temporary Password
Role
Status

Edit User

สามารถแก้:

Name

Email

Phone

Employee Code

Role

Status

ไม่ควรแสดง Password เดิม

19. Role Management UI

Role List:

Role Code
Role Name
Description
Status
Users Count

Role Detail:

Role Information

Permissions
├── User Management
├── Purchasing
├── Sales
├── Inventory
├── Accounting
└── Reports

Permission UI แนะนำใช้ Checkbox Matrix

ตัวอย่าง:

Permission

View

Create

Update

Cancel

Approve

PR

✓

✓

✓

✓

✓

PO

✓

✓

✓

✓

-

GR

✓

✓

✓

-

-

20. Purchasing Integration

เมื่อ User Module เสร็จ Purchasing จะใช้ Permission เช่น:

Supplier Quotation

PURCHASE_QUOTATION_VIEW
PURCHASE_QUOTATION_CREATE
PURCHASE_QUOTATION_UPDATE
PURCHASE_QUOTATION_DELETE

Purchase Requisition

PURCHASE_PR_VIEW
PURCHASE_PR_CREATE
PURCHASE_PR_UPDATE
PURCHASE_PR_SUBMIT
PURCHASE_PR_APPROVE
PURCHASE_PR_REJECT
PURCHASE_PR_CANCEL

Purchase Order

PURCHASE_PO_VIEW
PURCHASE_PO_CREATE
PURCHASE_PO_UPDATE
PURCHASE_PO_CANCEL

Goods Receipt

PURCHASE_GR_VIEW
PURCHASE_GR_CREATE
PURCHASE_GR_UPDATE
PURCHASE_GR_CANCEL

21. Approval Integration

Approval Flow ต้องอ้างอิง User

ตัวอย่าง:

PR Submitted
↓
Approval Step
↓
Approver User / Role
↓
Approved / Rejected

Approval History ต้อง Immutable

ตัวอย่าง:

approval_history

id
company_id
document_type
document_id
step_no
approver_user_id
action
comment
acted_at

ห้ามแก้ Approval History เดิมหลังบันทึก Action แล้ว

22. Security Principles

User Module 1.0 ต้องยึดหลัก:

Password ต้อง Hash

Backend ตรวจ Permission ทุก Action สำคัญ

ทุก Query Transaction ต้อง Scope ด้วย Company

ห้าม User ปกติเข้าถึงข้อมูล Company อื่น

User Disable แล้ว Login ไม่ได้

Session ต้อง Expire

Permission ห้ามเชื่อจาก Frontend อย่างเดียว

ห้าม Hard Delete User ที่มี Transaction

Audit field ต้องเก็บ User ID

SUPER_ADMIN ต้องแยกจาก Company User

23. Suggested Database Tables

Version 1.0:

companies

users

roles

permissions

user_roles

role_permissions

Optional:

user_sessions

password_reset_tokens

audit_logs

24. Development Order

แนะนำทำตามลำดับนี้:

01 Company foundation
↓
02 User table
↓
03 Role
↓
04 Permission
↓
05 User Role
↓
06 Role Permission
↓
07 Login / Session
↓
08 Permission middleware
↓
09 User Management UI
↓
10 Role Management UI
↓
11 Audit
↓
12 Purchasing Integration

25. Definition of Done — User Module 1.0

ถือว่า User 1.0 พร้อมเมื่อ:

Company สามารถมี User ได้

Create User ได้

Edit User ได้

Disable / Enable User ได้

Login / Logout ได้

Change Password ได้

Admin Reset Password ได้

Create Role ได้

Assign Role ให้ User ได้

Permission ถูกกำหนดให้ Role ได้

Backend ตรวจ Permission ได้

Frontend ซ่อน Menu / Action ตาม Permission ได้

User ข้าม Company ไม่ได้

Audit created_by / updated_by ใช้งานได้

User ที่มี Transaction ไม่ถูก Hard Delete

Purchasing สามารถนำ Permission Model นี้ไปใช้ต่อได้

26. หลักการสำหรับ Version 1.0

User Module รอบแรกควรเน้น:

Simple
Secure
Reusable
Multi-tenant
Auditable

ไม่ควรรีบเพิ่มระบบซับซ้อน เช่น:

Permission ราย Field

Permission ราย Record

Dynamic Policy Engine

Workflow Builder

AD / LDAP

SSO

จนกว่าจะมี Requirement จริง

27. Next Step

หลังเอกสารนี้ยืนยันแล้ว ขั้นต่อไปคือ:

ออกแบบ Database Schema จริง
↓
ตรวจ Relationship
↓
สร้าง Migration
↓
สร้าง Backend User Module
↓
ทำ Authentication
↓
ทำ Permission Middleware
↓
ทำ User / Role UI
↓
Test
↓
กลับไปต่อ Purchasing 1.0

Decision

ERP จะหยุดการพัฒนา Purchasing ชั่วคราว และสร้าง User Module 1.0 ก่อน เพื่อให้ Authentication, Role, Permission, Company Scope และ Audit เป็น Foundation กลางของทุก Module ตั้งแต่ต้น

28. Database Schema Draft 1 — Prisma

ส่วนนี้เป็น Draft สำหรับนำไปตรวจสอบก่อนสร้าง Migration จริง

model Company {
id String @id @default(uuid()) @db.Uuid
code String @unique
name String
taxId String? @map("tax_id")
isActive Boolean @default(true) @map("is_active")
createdAt DateTime @default(now()) @map("created_at")
updatedAt DateTime @updatedAt @map("updated_at")

users User[]
roles Role[]

@@map("companies")
}

model User {
id String @id @default(uuid()) @db.Uuid
companyId String @map("company_id") @db.Uuid
username String
email String?
passwordHash String @map("password_hash")
firstName String @map("first_name")
lastName String @map("last_name")
employeeCode String? @map("employee_code")
phone String?
isActive Boolean @default(true) @map("is_active")
lastLoginAt DateTime? @map("last_login_at")
passwordChangedAt DateTime? @map("password_changed_at")
createdAt DateTime @default(now()) @map("created_at")
createdBy String? @map("created_by") @db.Uuid
updatedAt DateTime @updatedAt @map("updated_at")
updatedBy String? @map("updated_by") @db.Uuid

company Company @relation(fields: [companyId], references: [id])
userRoles UserRole[]

@@unique([companyId, username])
@@unique([companyId, email])
@@index([companyId])
@@map("users")
}

model Role {
id String @id @default(uuid()) @db.Uuid
companyId String? @map("company_id") @db.Uuid
code String
name String
description String?
isSystem Boolean @default(false) @map("is_system")
isActive Boolean @default(true) @map("is_active")
createdAt DateTime @default(now()) @map("created_at")
createdBy String? @map("created_by") @db.Uuid
updatedAt DateTime @updatedAt @map("updated_at")
updatedBy String? @map("updated_by") @db.Uuid

company Company? @relation(fields: [companyId], references: [id])
userRoles UserRole[]
rolePermissions RolePermission[]

@@unique([companyId, code])
@@index([companyId])
@@map("roles")
}

model Permission {
id String @id @default(uuid()) @db.Uuid
code String @unique
name String
module String
description String?
createdAt DateTime @default(now()) @map("created_at")
updatedAt DateTime @updatedAt @map("updated_at")

rolePermissions RolePermission[]

@@index([module])
@@map("permissions")
}

model UserRole {
userId String @map("user_id") @db.Uuid
roleId String @map("role_id") @db.Uuid
assignedAt DateTime @default(now()) @map("assigned_at")
assignedBy String? @map("assigned_by") @db.Uuid

user User @relation(fields: [userId], references: [id], onDelete: Cascade)
role Role @relation(fields: [roleId], references: [id], onDelete: Cascade)

@@id([userId, roleId])
@@index([roleId])
@@map("user_roles")
}

model RolePermission {
roleId String @map("role_id") @db.Uuid
permissionId String @map("permission_id") @db.Uuid
assignedAt DateTime @default(now()) @map("assigned_at")
assignedBy String? @map("assigned_by") @db.Uuid

role Role @relation(fields: [roleId], references: [id], onDelete: Cascade)
permission Permission @relation(fields: [permissionId], references: [id], onDelete: Cascade)

@@id([roleId, permissionId])
@@index([permissionId])
@@map("role_permissions")
}

29. Schema Decisions To Confirm Before Migration

ก่อนสร้าง Migration จริง ต้องยืนยันประเด็นต่อไปนี้:

29.1 SUPER_ADMIN

แนวทาง Draft:

SUPER_ADMIN เป็น System Role

Role.company_id สามารถเป็น NULL

Role ที่ผูกกับบริษัท เช่น COMPANY_ADMIN, PURCHASING_USER ต้องมี company_id

เหตุผล:

SUPER_ADMIN
↓
System Level

COMPANY_ADMIN
↓
Company Level

29.2 Email Uniqueness

Draft ปัจจุบันใช้:

@@unique([companyId, email])

หมายความว่า Email เดียวกันสามารถอยู่หลาย Company ได้

ตัวอย่าง:

company A → user@example.com
company B → user@example.com

ก่อน Migration ต้องตัดสินใจว่าจะ:

Unique เฉพาะ Company

หรือ Unique ทั้งระบบ

29.3 created_by / updated_by

Draft ปัจจุบันเก็บเป็น UUID:

created_by
updated_by
assigned_by

แต่ยังไม่ได้ผูก Foreign Key กลับ users.id

มี 2 แนวทาง:

Option A — FK จริง

ข้อดี:

Referential integrity

Join หา User ได้ตรง

ข้อควรระวัง:

ต้องจัดการ User ที่ถูก Disable

Self-reference ใน User table เพิ่มความซับซ้อน

Option B — เก็บ UUID สำหรับ Audit

ข้อดี:

Schema ง่าย

Audit record ไม่เสียแม้มีการเปลี่ยนสถานะ User

ข้อควรระวัง:

Database ไม่บังคับว่า UUID ต้องมีอยู่จริงใน users

Draft 1 ยังไม่ตัดสินใจประเด็นนี้

30. Migration Gate

ห้ามสร้าง Migration จนกว่าจะตรวจครบ:

ยืนยัน SUPER_ADMIN model

ยืนยัน Email uniqueness

ยืนยัน created_by / updated_by strategy

ตรวจ Multi-Tenant isolation

ตรวจ User ↔ Role relationship

ตรวจ Role ↔ Permission relationship

ตรวจ Delete policy

ตรวจ Naming convention

ตรวจ Index / Unique constraint

หลังผ่านทั้งหมดแล้วจึงไป:

Database Schema Approved
↓
Create Prisma Migration
↓
Seed System Permissions
↓
Seed Initial Roles
↓
Backend User Module
