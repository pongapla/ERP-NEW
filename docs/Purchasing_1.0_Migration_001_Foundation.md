Purchasing 1.0 — Migration 001 Foundation

1. Purpose

Migration 001 เป็นฐานกลางของ Purchasing 1.0 และเตรียม object ที่โมดูลอื่นสามารถนำไปใช้ซ้ำได้ในอนาคต

สร้าง:

document_sequences
document_attachments
audit_logs

Migration นี้ต้องเกิดก่อน:

Suppliers
Supplier Quotations
PR
Approval
PO
GR

2. Assumptions

ระบบหลักมี Table:

companies
users

โดยใช้:

companies.id UUID
users.id UUID

ถ้าชื่อ Table หรือ Primary Key ในโปรเจกต์จริงต่างจากนี้ ต้อง map ให้ตรงก่อนสร้าง migration

ห้ามเดาชื่อ table ของระบบจริง หากยังไม่ได้ตรวจ schema ปัจจุบัน

3. PostgreSQL Requirements

แนะนำ PostgreSQL 17 ตาม architecture ปัจจุบัน

UUID สามารถสร้างจาก Application หรือ Database

ถ้าต้องการให้ PostgreSQL generate UUID:

CREATE EXTENSION IF NOT EXISTS pgcrypto;

และใช้:

gen_random_uuid()

อย่างไรก็ตาม หากระบบหลักมี UUID strategy อยู่แล้ว ให้ใช้ strategy เดียวกับโปรเจกต์

4. Migration UP

4.1 document_sequences

Purpose:

สร้าง Running Number แบบปลอดภัยต่อ concurrent request

รองรับ:

SQ-YYMM-####
PR-YYMM-####
PO-YYMM-####
GR-YYMM-####

SQL

CREATE TABLE document_sequences (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
document_type VARCHAR(30) NOT NULL,
year_no INTEGER NOT NULL,
month_no INTEGER NOT NULL,
last_number INTEGER NOT NULL DEFAULT 0,
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_document_sequences_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT uq_document_sequences_scope
        UNIQUE (company_id, document_type, year_no, month_no),

    CONSTRAINT chk_document_sequences_month
        CHECK (month_no BETWEEN 1 AND 12),

    CONSTRAINT chk_document_sequences_last_number
        CHECK (last_number >= 0),

    CONSTRAINT chk_document_sequences_year
        CHECK (year_no >= 2000)

);

Index Review

ไม่ต้องสร้าง index ซ้ำสำหรับ:

(company_id, document_type, year_no, month_no)

เพราะ UNIQUE สร้าง index ให้อยู่แล้ว

5. document_attachments

Purpose:

เก็บ metadata ของไฟล์แนบแบบ generic

ใช้กับ:

SUPPLIER_QUOTATION
PR
PO
GR

ไฟล์จริงไม่เก็บ binary ใน PostgreSQL

เก็บเฉพาะ:

storage_key
file_name
mime_type
file_size

SQL

CREATE TABLE document_attachments (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
entity_type VARCHAR(50) NOT NULL,
entity_id UUID NOT NULL,
file_name VARCHAR(255) NOT NULL,
storage_key VARCHAR(500) NOT NULL,
mime_type VARCHAR(100),
file_size BIGINT,
uploaded_by UUID NOT NULL,
uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_document_attachments_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT fk_document_attachments_uploaded_by
        FOREIGN KEY (uploaded_by)
        REFERENCES users(id),

    CONSTRAINT chk_document_attachments_file_size
        CHECK (file_size IS NULL OR file_size >= 0),

    CONSTRAINT chk_document_attachments_entity_type
        CHECK (
            entity_type IN (
                'SUPPLIER_QUOTATION',
                'PR',
                'PO',
                'GR'
            )
        )

);

Indexes

CREATE INDEX idx_document_attachments_entity
ON document_attachments (
company_id,
entity_type,
entity_id
);

Optional:

CREATE INDEX idx_document_attachments_uploaded_by
ON document_attachments (company_id, uploaded_by);

สำหรับ 1.0 ยังไม่จำเป็นถ้ายังไม่มี query ตาม uploader

6. Attachment Security Rule

entity_id เป็น Generic Reference

ดังนั้น Database ไม่สามารถสร้าง FK เช่น:

entity_id → PR / PO / GR / Quotation

ได้โดยตรง

Go API ต้องตรวจ:

1. entity มีอยู่จริง
2. entity.company_id ตรงกับ authenticated company
3. user มี permission บน document นั้น

ห้ามรับ company_id จาก request body แล้วเชื่อทันที

ควร derive จาก authenticated context

7. audit_logs

Purpose:

บันทึก Business Event สำคัญ

ตัวอย่าง:

PR_CREATED
PR_SUBMITTED
PR_APPROVED
PR_REJECTED

PO_CREATED
PO_ISSUED

GR_CREATED
GR_POSTED

Audit Log ไม่ใช่ Source of Truth ของ Workflow

SQL

CREATE TABLE audit_logs (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
entity_type VARCHAR(50) NOT NULL,
entity_id UUID NOT NULL,
action VARCHAR(80) NOT NULL,
user_id UUID,
previous_data JSONB,
new_data JSONB,
metadata JSONB,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_audit_logs_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)

);

8. Audit Indexes

CREATE INDEX idx_audit_logs_entity
ON audit_logs (
company_id,
entity_type,
entity_id,
created_at
);

CREATE INDEX idx_audit_logs_action
ON audit_logs (
company_id,
action,
created_at
);

Optional Future:

CREATE INDEX idx_audit_logs_metadata_gin
ON audit_logs USING GIN (metadata);

ยังไม่ควรสร้างใน 1.0 จนกว่าจะมี use case ที่ query JSONB จริง

9. UUID Generation Decision

มี 2 ทางเลือก

Option A — Application generates UUID

Go:

uuid.New()

Database:

id UUID PRIMARY KEY

ข้อดี:

- consistent application behavior
- test ง่าย
- ไม่ต้องพึ่ง DB default

Option B — PostgreSQL generates UUID

id UUID PRIMARY KEY DEFAULT gen_random_uuid()

สำหรับ ERP นี้แนะนำ:

Application generates UUID

เพราะ Go API เป็นเจ้าของ write flow หลักอยู่แล้ว

10. Migration UP — Combined Script

ตัวอย่าง combined SQL:

BEGIN;

CREATE TABLE document_sequences (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
document_type VARCHAR(30) NOT NULL,
year_no INTEGER NOT NULL,
month_no INTEGER NOT NULL,
last_number INTEGER NOT NULL DEFAULT 0,
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_document_sequences_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT uq_document_sequences_scope
        UNIQUE (company_id, document_type, year_no, month_no),

    CONSTRAINT chk_document_sequences_month
        CHECK (month_no BETWEEN 1 AND 12),

    CONSTRAINT chk_document_sequences_last_number
        CHECK (last_number >= 0),

    CONSTRAINT chk_document_sequences_year
        CHECK (year_no >= 2000)

);

CREATE TABLE document_attachments (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
entity_type VARCHAR(50) NOT NULL,
entity_id UUID NOT NULL,
file_name VARCHAR(255) NOT NULL,
storage_key VARCHAR(500) NOT NULL,
mime_type VARCHAR(100),
file_size BIGINT,
uploaded_by UUID NOT NULL,
uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_document_attachments_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT fk_document_attachments_uploaded_by
        FOREIGN KEY (uploaded_by)
        REFERENCES users(id),

    CONSTRAINT chk_document_attachments_file_size
        CHECK (file_size IS NULL OR file_size >= 0),

    CONSTRAINT chk_document_attachments_entity_type
        CHECK (
            entity_type IN (
                'SUPPLIER_QUOTATION',
                'PR',
                'PO',
                'GR'
            )
        )

);

CREATE INDEX idx_document_attachments_entity
ON document_attachments (
company_id,
entity_type,
entity_id
);

CREATE TABLE audit_logs (
id UUID PRIMARY KEY,
company_id UUID NOT NULL,
entity_type VARCHAR(50) NOT NULL,
entity_id UUID NOT NULL,
action VARCHAR(80) NOT NULL,
user_id UUID,
previous_data JSONB,
new_data JSONB,
metadata JSONB,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_audit_logs_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)

);

CREATE INDEX idx_audit_logs_entity
ON audit_logs (
company_id,
entity_type,
entity_id,
created_at
);

CREATE INDEX idx_audit_logs_action
ON audit_logs (
company_id,
action,
created_at
);

COMMIT;

11. Migration DOWN

ใช้สำหรับ Dev/Test เท่านั้น

ต้อง Drop Reverse Dependency:

BEGIN;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS document_attachments;
DROP TABLE IF EXISTS document_sequences;

COMMIT;

หลัง Production มีข้อมูลแล้ว ไม่ควรใช้ destructive rollback แบบนี้

ให้ใช้ Forward Fix Migration แทน

12. Important Review Before Running

ก่อนนำ SQL นี้ไปใช้จริง ต้องตรวจ schema ของโปรเจกต์ว่า:

companies table ชื่อจริงคืออะไร
users table ชื่อจริงคืออะไร

companies.id type = UUID ?
users.id type = UUID ?

มี schema namespace หรือไม่ เช่น:
public.companies
core.companies

มี existing audit table หรือ attachment table อยู่แล้วหรือไม่

ถ้าของเดิมมีอยู่แล้ว ห้ามสร้างซ้ำ

13. Schema Tests

13.1 document_sequences

Insert valid

INSERT INTO document_sequences (
id,
company_id,
document_type,
year_no,
month_no,
last_number
)
VALUES (
:id,
:company_id,
'PR',
2026,
9,
0
);

Expected:

PASS

Duplicate sequence

Insert:

same company
same document_type
same year
same month

Expected:

FAIL UNIQUE CONSTRAINT

Invalid month

month_no = 13

Expected:

FAIL CHECK CONSTRAINT

Negative last number

last_number = -1

Expected:

FAIL CHECK CONSTRAINT

14. Attachment Tests

Valid PR attachment

entity_type = PR
file_size = 50000

Expected:

PASS

Invalid entity type

entity_type = SOMETHING

Expected:

FAIL

Negative file size

file_size = -1

Expected:

FAIL

15. Audit Tests

Insert:

{
"action": "PR_CREATED",
"previous_data": null,
"new_data": {
"status": "DRAFT"
}
}

Expected:

PASS

JSONB ต้องอ่านกลับได้ถูกต้อง

16. Tenant Isolation Test

สร้าง:

Company A
Company B

ต้องทดสอบใน API ภายหลังว่า:

Company A ห้ามอ่าน attachment ของ Company B
Company A ห้ามอ่าน audit ของ Company B
Company A ห้ามใช้ sequence ของ Company B

Database Schema มี company_id

แต่ Authorization หลักยังต้องอยู่ที่ API / Function Layer

17. Concurrency Preparation

Migration 001 ยังไม่ได้สร้าง:

fn_next_document_no()

ดังนั้นยังไม่ควรให้ API ทำ:

SELECT MAX(last_number) + 1

เด็ดขาด

Document Number จะพร้อมจริงเมื่อสร้าง Function:

fn_next_document_no()

ใน Migration 009

จนกว่าจะถึงตอนนั้น document_sequences เป็นเพียง storage structure

18. Why MAX()+1 Is Forbidden

ตัวอย่าง:

Request A อ่าน max = 10
Request B อ่าน max = 10

A → 11
B → 11

เกิดเลขซ้ำ

ของจริงต้อง:

Lock sequence row
Increment
Return number

ภายใน transaction

19. Migration 001 Acceptance Criteria

ถือว่า Migration 001 ผ่านเมื่อ:

[ ] migration UP ผ่านบน empty test DB
[ ] migration DOWN ผ่านบน dev DB
[ ] company FK ถูกต้อง
[ ] user FK ถูกต้อง
[ ] sequence unique constraint ผ่าน
[ ] sequence check constraints ผ่าน
[ ] attachment entity index ถูกสร้าง
[ ] attachment invalid entity rejected
[ ] audit JSONB insert/read ผ่าน
[ ] audit indexes ถูกสร้าง
[ ] migration rerun behavior ถูกจัดการโดย migration framework

20. What Must Not Be Added Yet

Migration 001 ห้ามเพิ่ม:

Supplier
Quotation
PR
Approval
PO
GR

fn_next_document_no
Approval Trigger
Business Views
Demo Data

เพื่อรักษา migration responsibility ให้เล็กและตรวจสอบง่าย

21. Next Migration

หลัง Migration 001 ผ่าน:

Migration 002 — Suppliers

จะสร้าง:

suppliers

พร้อม:

constraints
indexes
ACTIVE / INACTIVE
tenant-safe unique supplier code

22. Implementation Rule for Codex

ถ้าจะให้ Codex นำเอกสารนี้ไปสร้าง migration จริง ให้กำหนด:

1. Inspect the existing project schema first.
2. Do not assume table names for companies/users.
3. Do not modify existing tables unless required.
4. Do not create duplicate audit/attachment infrastructure.
5. Do not invent business rules.
6. Only implement Migration 001.
7. Add tests.
8. Do not proceed to Supplier migration.
9. Report any schema mismatch as an OPEN QUESTION.

ก่อนให้ Codex เขียนจริง ควรให้มันตรวจ repository/schema ปัจจุบันก่อนเสมอ
