ERP-NEW Frontend Structure

1. Purpose

This document records the initial frontend structure of ERP-NEW.

The frontend is intentionally separated from the legacy PHP Portal.
The PHP Portal and Infor ERP are treated as references only.
ERP-NEW is developed as a new standalone system.

Current frontend stack:

Nuxt

TypeScript

Nuxt UI

pnpm

Node.js 22 via .nvmrc

2. Project Root Structure

ERP-NEW/
├─ backend/
├─ database/
├─ docs/
├─ frontend/
└─ references/

Folder responsibility

Folder

Responsibility

backend/

API, authentication, authorization, business logic

database/

Database schema, migrations, seed data, SQL documentation

docs/

Requirements, architecture, workflows, design decisions

frontend/

ERP web application

references/

Legacy PHP Portal / Infor screenshots, notes, schema references

3. Frontend Structure

Current planned structure:

frontend/
├─ app/
│ ├─ components/
│ │ └─ layout/
│ │ ├─ AppHeader.vue
│ │ └─ AppSidebar.vue
│ │
│ ├─ layouts/
│ │ └─ default.vue
│ │
│ ├─ pages/
│ │ ├─ login.vue
│ │ └─ dashboard/
│ │ └─ index.vue
│ │
│ └─ app.vue
│
├─ public/
├─ .nvmrc
├─ nuxt.config.ts
├─ package.json
├─ pnpm-lock.yaml
└─ tsconfig.json

4. Initial Application Flow

/login
│
│ mock login during UI development
▼
/dashboard
│
▼
Default Layout
├─ AppSidebar
├─ AppHeader
└─ Page Content

The backend authentication flow is not connected yet.

The current goal is to stabilize:

Login UI

Main ERP layout

Sidebar navigation

Header / user menu

Dashboard

Permission-based menu

5. Login Page

File:

app/pages/login.vue

Initial responsibility:

Username / email input

Password input

Login button

Loading state

Temporary mock login

Redirect to /dashboard

Future responsibilities:

Backend authentication

Session handling

Invalid credential messages

Account lock handling

Forgot password

Password reset

Force logout handling

Login audit logging

6. Default ERP Layout

File:

app/layouts/default.vue

Purpose:

Provide the shared layout for authenticated ERP pages.

Structure:

Default Layout
├─ Sidebar
├─ Header
└─ Main Content

Current layout concept:

┌─────────────────────────────────────────────┐
│ Sidebar │ Header │
│ ├───────────────────────────────────┤
│ │ │
│ │ Main Page Content │
│ │ │
│ │ │
└─────────────────────────────────────────────┘

7. Sidebar

File:

app/components/layout/AppSidebar.vue

Initial menu structure:

Dashboard

Purchasing
├─ Supplier Quotation
├─ Purchase Requisition
├─ Purchase Order
└─ Goods Receipt

Master Data

Users & Permissions

Audit Log

Important:

The current menu is static only.

Future implementation must load or filter menus based on permission.

Example:

pr.view
pr.create
pr.approve

po.view
po.create
po.approve

gr.view
gr.create

user.view
user.manage

audit.view

A user must not see menu items that they do not have permission to access.

Backend authorization must still protect the API independently.

8. Header

File:

app/components/layout/AppHeader.vue

Initial responsibility:

Application title

Notification button

Current user display

Profile menu

Change Password

Logout

Initial user menu:

Administrator
├─ Profile
├─ Change Password
└─ Logout

Future data will come from the authenticated user session.

9. Dashboard

File:

app/pages/dashboard/index.vue

Initial cards:

Pending PR

Waiting Approval

Open PO

Pending GR

Current values are placeholders.

Example:

Dashboard

┌────────────────┐
│ Pending PR │
│ 0 │
└────────────────┘

┌────────────────┐
│ Waiting │
│ Approval: 0 │
└────────────────┘

┌────────────────┐
│ Open PO │
│ 0 │
└────────────────┘

┌────────────────┐
│ Pending GR │
│ 0 │
└────────────────┘

The Dashboard also contains:

Recent Activity

This will later display recent ERP actions according to the user's permission scope.

10. Core Security Direction

Before developing purchasing modules deeply, ERP-NEW will require the following shared core:

User
↓
Role
↓
Permission
↓
Login
↓
Session
↓
Authorization
↓
Audit Log
↓
Approval Authority

These components must be reusable by every ERP module.

11. Permission Principle

ERP-NEW should avoid a simple hardcoded user-level model.

Target model:

User
└─ UserRole
└─ Role
└─ RolePermission
└─ Permission

Example:

ROLE: PURCHASING_USER

Permissions:

- quotation.view
- quotation.create
- pr.view
- pr.create
- po.view

Example:

ROLE: PURCHASING_MANAGER

Permissions:

- quotation.view
- quotation.create
- quotation.edit
- pr.view
- pr.create
- pr.approve
- po.view
- po.create
- po.approve

Final permission rules will be designed together with backend and database structures.

12. Audit Log Principle

Audit Log is separate from Approval History.

Audit Log

Used to record system actions such as:

LOGIN
LOGOUT
CREATE
UPDATE
DELETE
VIEW
EXPORT
APPROVE
REJECT
PERMISSION_DENIED
PASSWORD_RESET
FORCE_LOGOUT

Expected information:

User
Timestamp
Module
Action
Record ID
Old Value
New Value
IP
User Agent
Result

Audit records should not be editable from the normal ERP UI.

Approval History

Used as business evidence for document approval.

Example:

PR-2026-0001

Level 1
Approved by Purchasing Manager
2026-09-16 10:30

Level 2
Approved by General Manager
2026-09-16 11:15

Approval History should be immutable.

13. Purchasing Modules Planned After Core UI

Initial purchasing lifecycle:

Supplier Quotation
↓
Purchase Requisition
↓
Approval
↓
Purchase Order
↓
Goods Receipt

These modules should not duplicate authentication, permissions, or audit logic.

All modules will use the same core services.

14. Legacy System Reference Policy

ERP-NEW is a new system.

Legacy PHP Portal and Infor ERP may be used for:

Workflow reference

Business terminology

Existing operational behavior

UI reference

Permission behavior analysis

Database relationship analysis

They must not automatically be treated as the target architecture.

Any behavior derived from a legacy system should be classified as:

VERIFIED
PARTIAL
UNKNOWN
NEW DESIGN

Do not invent legacy behavior when it cannot be verified.

15. Current Development Status

As of the current frontend setup:

ERP-NEW root created

Frontend separated from legacy PHP project

Nuxt project created

Nuxt UI template installed

Node 22 selected for ERP-NEW

pnpm development server working

Initial Login page planned/created

Initial Dashboard page planned/created

Sidebar structure defined

Header structure defined

Backend authentication

Session management

Role and Permission API

Permission-based menu

Audit Log integration

Approval authority

Purchasing module implementation

16. Next Frontend Tasks

Next implementation sequence:

1. Stabilize Login page
2. Stabilize Default Layout
3. Improve Sidebar UX
4. Improve Header / User Menu
5. Improve Dashboard
6. Add route protection
7. Add mock user + mock permission
8. Convert menu to permission-based menu
9. Connect Authentication API
10. Start Purchasing module

The next UI work should still focus on the shell of the ERP system before building detailed PR / PO / GR forms.
