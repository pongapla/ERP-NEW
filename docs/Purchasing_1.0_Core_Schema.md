Purchasing 1.0 — Database Architecture

1. Purpose

เอกสารนี้กำหนดแนวทาง Database Architecture สำหรับโมดูล Purchasing 1.0 โดยต่อยอดจากเอกสาร:

Purchasing_1.0_Status_Workflow.md

เป้าหมายคือกำหนดขอบเขตให้ชัดว่า Business Logic ส่วนใดควรอยู่ที่:

Go API

PostgreSQL Tables

PostgreSQL Views

PostgreSQL Functions / Stored Procedures

PostgreSQL Triggers

เพื่อให้ระบบ:

อ่านและดูแลรักษาง่าย

Debug ได้ง่าย

รองรับ Transaction ที่ปลอดภัย

ไม่ซ่อน Business Logic ไว้ใน Trigger มากเกินไป

รองรับการขยายไปยังโมดูล Accounting / Inventory / Production ในอนาคต

2. High-Level Architecture

Nuxt Frontend
│
▼
Go API
│
▼
PostgreSQL
├── Tables
├── Views
├── Functions / Stored Procedures
└── Triggers

หลักสำคัญ:

Frontend ห้ามเชื่อม Database โดยตรง

ทุกคำขอจาก Frontend ต้องผ่าน Go API

3. Responsibility by Layer

3.1 Nuxt Frontend

รับผิดชอบ:

UI / UX

Form Validation เบื้องต้น

Display Status

Search / Filter UI

Confirmation Dialog

Error Message

Permission-based UI Visibility

Frontend ไม่ควรเป็นตัวตัดสิน Business Rule ที่สำคัญเพียงชั้นเดียว

ตัวอย่าง:

Frontend อาจปิดปุ่ม Create PO ถ้า PR ยังไม่ Approved

แต่ Backend / Database ต้องตรวจซ้ำเสมอ

3.2 Go API

Go API เป็นตัวควบคุม Business Flow หลัก

รับผิดชอบ:

Authentication

Authorization

Request Validation

Permission Check

Business Validation ระดับ Application

เรียก Database Function / SP

CRUD ทั่วไป

API Transaction

Logging

Error Mapping

Attachment Handling

ตัวอย่าง:

POST /api/purchasing/pr
POST /api/purchasing/pr/:id/submit
POST /api/purchasing/pr/:id/approve
POST /api/purchasing/po/from-pr
POST /api/purchasing/gr/post

4. Database Object Strategy

4.1 Tables

ใช้ Table สำหรับ Source of Truth

ตัวอย่าง:

suppliers
supplier_quotations
supplier_quotation_items

purchase_requisitions
purchase_requisition_items

approval_workflows
approval_steps
approval_history

purchase_orders
purchase_order_items

goods_receipts
goods_receipt_items

document_attachments
audit_logs

4.2 Views

ใช้ View สำหรับ:

Dashboard

Report

Search

Summary

Document Progress

Remaining Quantity

Data ที่ต้อง Join หลาย Table บ่อย

View ไม่ควรทำการแก้ข้อมูล

ตัวอย่าง:

vw_pr_summary
vw_pr_remaining_qty
vw_po_summary
vw_po_remaining_qty
vw_gr_summary
vw_pending_approvals
vw_purchasing_dashboard

4.3 Functions / Stored Procedures

ใน PostgreSQL สามารถใช้ Function / Procedure สำหรับ Transaction ที่มีหลายขั้นตอน

เหมาะกับงานประเภท:

Submit PR

Approve / Reject PR

Create PO from PR

Post GR

Cancel Document

Reversal

Generate Document Number

ข้อดี:

ทำหลายคำสั่งใน Transaction เดียว

ลด Race Condition

ตรวจ Quantity ก่อนเขียนข้อมูล

บังคับ Workflow ได้ที่ Database Boundary

4.4 Triggers

Trigger ใช้เฉพาะกรณีที่จำเป็นจริง

เหมาะกับ:

updated_at

immutable protection

database-level audit บางประเภท

safety guard

ไม่ควรใช้ Trigger เป็นตัวควบคุม Business Workflow หลัก

ตัวอย่างที่ไม่แนะนำ:

INSERT PO ITEM
→ Trigger เปลี่ยน PR status
→ Trigger สร้าง Audit
→ Trigger สร้าง Approval
→ Trigger ส่งต่อ Logic อื่น

เพราะจะ Debug ยากและมี Logic ซ่อนอยู่ใน Database

5. Supplier Architecture

5.1 Tables

suppliers

ข้อมูลหลัก:

id
company_id
supplier_code
supplier_name
tax_id
branch_code
contact_name
phone
email
address
province
postal_code
country
payment_term_days
currency_code
lead_time_days
vat_registered
vat_rate
status
created_at
created_by
updated_at
updated_by

5.2 Views

อาจมี:

vw_active_suppliers

สำหรับใช้ใน Dropdown / Search

แต่ใน 1.0 สามารถ Query Table ตรงผ่าน API ได้ก่อนถ้า Query ไม่ซับซ้อน

5.3 Functions / SP

Supplier CRUD ปกติไม่จำเป็นต้องใช้ SP

ใช้:

Go API + pgx

ตัวอย่าง:

Create Supplier
Update Supplier
Set Supplier Inactive

5.4 Triggers

สามารถใช้ Trigger:

set_updated_at

ถ้าเราต้องการให้ Database เป็นตัวอัปเดตเวลา

แต่ไม่จำเป็นต้องมี Trigger ธุรกิจอื่นใน Supplier 1.0

6. Supplier Quotation Architecture

6.1 Tables

supplier_quotations
supplier_quotation_items

ตัวอย่าง Header:

id
company_id
quotation_no
supplier_id
supplier_reference_no
quotation_date
valid_until
currency_code
subtotal
discount_amount
vat_amount
total_amount
status
remark
created_at
created_by
updated_at
updated_by

Items:

id
supplier_quotation_id
line_no
item_code
description
qty
unit
unit_price
discount_amount
vat_rate
line_total

6.2 Attachments

ใบเสนอราคาจาก Supplier ควรเก็บผ่าน:

document_attachments

ไม่ควรฝังไฟล์ Binary ใน Table หลัก

ควรเก็บ:

entity_type
entity_id
file_name
file_path
mime_type
file_size
uploaded_by
uploaded_at

6.3 Functions / SP

CRUD ปกติ:

Go API + pgx

ถ้ามีขั้นตอน Confirm Quotation ในอนาคตค่อยเพิ่ม Function

7. Purchase Requisition Architecture

7.1 Tables

purchase_requisitions
purchase_requisition_items

Header:

id
company_id
pr_no
request_date
requested_by
department_id
status
purpose
remark
submitted_at
approved_at
cancelled_at
cancel_reason
created_at
created_by
updated_at
updated_by

Items:

id
purchase_requisition_id
line_no
item_code
description
requested_qty
unit
required_date
estimated_unit_price
supplier_quotation_item_id
created_at
updated_at

7.2 PR Functions / SP

แนะนำให้มี:

fn_submit_pr(...)
fn_withdraw_pr(...)
fn_cancel_pr(...)

เหตุผล:

การ Submit PR อาจต้องทำหลายขั้น:

1. Lock PR
2. ตรวจ PR status
3. ตรวจว่ามี Item
4. ตรวจ Requirement
5. สร้าง Approval Instance
6. สร้าง Approval Steps
7. เปลี่ยน PR status
8. เขียน Audit Log
9. Commit

จึงเหมาะกับ Database Function / Transaction

8. Approval Architecture

8.1 Tables

approval_workflows
approval_workflow_steps
approval_instances
approval_instance_steps
approval_history

แนวคิดแยก:

Workflow Definition
↓
Approval Instance
↓
Approval History

8.2 Approval History

approval_history ต้อง Immutable

ตัวอย่าง Columns:

id
company_id
entity_type
entity_id
approval_instance_id
approval_step_id
action
approver_user_id
comment
channel
action_at
metadata

8.3 Approval Functions / SP

ควรมี:

fn_approve_document(...)
fn_reject_document(...)

หรือแยกเฉพาะ PR ใน 1.0:

fn_approve_pr(...)
fn_reject_pr(...)

Function ต้องตรวจ:

Current Status
Current Approval Step
Approver Permission
Duplicate Approval
Approval Sequence

แล้วทำทุกอย่างใน Transaction เดียว

8.4 Trigger

ใช้ Trigger หรือ Rule เพื่อป้องกัน:

UPDATE approval_history
DELETE approval_history

หลักคือ:

approval_history = INSERT ONLY

นี่เป็น Trigger ที่เหมาะสมเพราะเป็นกฎระดับ Database จริง

9. Purchase Order Architecture

9.1 Tables

purchase_orders
purchase_order_items
pr_po_allocations

ควรมี Table กลาง:

pr_po_allocations

เพื่อเก็บว่าจำนวน PR Line ถูกนำไป PO เท่าไร

ตัวอย่าง:

id
pr_item_id
po_item_id
allocated_qty
created_at

ข้อดีคือรองรับ:

PR 10
├── PO1 = 4
└── PO2 = 6

ได้อย่างชัดเจน

9.2 PO Function / SP

แนะนำ:

fn_create_po_from_pr(...)
fn_issue_po(...)
fn_cancel_po(...)

โดยเฉพาะ:

fn_create_po_from_pr

ต้องทำ Transaction:

1. ตรวจ PR = APPROVED/PARTIALLY_ORDERED
2. Lock PR Items
3. คำนวณ Remaining Qty
4. ตรวจ Requested PO Qty
5. สร้าง PO Header
6. สร้าง PO Items
7. สร้าง pr_po_allocations
8. คำนวณ PR Progress
9. Update PR Status
10. Audit
11. Commit

12. PR Remaining Quantity View

แนะนำ View:

vw_pr_item_remaining_qty

Concept:

## requested_qty

# SUM(pr_po_allocations.allocated_qty)

remaining_qty

ตัวอย่าง Output:

pr_item_id
pr_no
line_no
requested_qty
ordered_qty
remaining_qty
progress_percent

View นี้จะใช้ใน:

PR Detail

Create PO

Dashboard

Reports

11. Goods Receipt Architecture

11.1 Tables

goods_receipts
goods_receipt_items
po_gr_allocations

Table:

po_gr_allocations

ใช้เก็บ Quantity ที่รับจาก PO Item

ตัวอย่าง:

id
po_item_id
gr_item_id
received_qty
created_at

รองรับ:

PO 10
├── GR1 = 4
├── GR2 = 3
└── GR3 = 3

11.2 GR Function / SP

ควรมี:

fn_post_gr(...)
fn_cancel_gr(...)

fn_post_gr ทำ:

1. ตรวจ PO status
2. Lock PO Items
3. คำนวณ Remaining Qty
4. ตรวจ Received Qty
5. สร้าง/ยืนยัน GR
6. สร้าง po_gr_allocations
7. Update PO Progress
8. Update PO Status
9. Audit
10. Commit

11. PO Remaining Quantity View

vw_po_item_remaining_qty

Concept:

## ordered_qty

# SUM(po_gr_allocations.received_qty)

remaining_qty

Output เช่น:

po_item_id
po_no
line_no
ordered_qty
received_qty
remaining_qty
progress_percent

13. Dashboard Views

Dashboard ไม่ควร Query Logic ซับซ้อนจาก Frontend

แนะนำ:

vw_purchasing_dashboard
vw_pending_approvals
vw_open_pr
vw_open_po
vw_waiting_receipt

ตัวอย่าง Metric:

Open PR
Pending Approval
Approved PR Waiting PO
Open PO
Partially Received PO
Waiting Receipt

Go API อ่าน View แล้วส่ง JSON ให้ Nuxt

14. Audit Architecture

14.1 Table

audit_logs

ตัวอย่าง:

id
company_id
entity_type
entity_id
action
user_id
previous_data
new_data
metadata
created_at

ใน PostgreSQL สามารถเก็บ:

previous_data JSONB
new_data JSONB
metadata JSONB

14.2 Audit Strategy

ไม่ควรใช้ Trigger สำหรับ Audit ทุก Table โดยอัตโนมัติใน 1.0

แนะนำให้ Business Action สำคัญเขียน Audit จาก Function/SP หรือ API อย่างชัดเจน

เช่น:

PR_SUBMITTED
PR_APPROVED
PR_REJECTED
PO_ISSUED
GR_POSTED
DOCUMENT_CANCELLED

Trigger Audit อาจใช้เฉพาะ Object ที่ต้องการ Database-level protection จริง ๆ

15. Document Number Generation

เอกสารต้องมีเลข:

PR-YYMM-####
PO-YYMM-####
GR-YYMM-####

หรือรูปแบบ Configurable ภายหลัง

ควรมี Table เช่น:

document_sequences

ตัวอย่าง:

company_id
document_type
year
month
last_number

และใช้ Function:

fn_next_document_no(...)

เพื่อป้องกันเลขซ้ำจาก Concurrent Requests

ไม่ควร Generate เลขเอกสารจาก Frontend

16. Multi-Company Rule

ทุก Business Table ต้องมี:

company_id

เช่น:

suppliers
purchase_requisitions
purchase_orders
goods_receipts
approval_history
audit_logs

Unique Constraint ต้องผูกกับ Company

ตัวอย่าง:

UNIQUE(company_id, supplier_code)
UNIQUE(company_id, pr_no)
UNIQUE(company_id, po_no)

ห้ามใช้เลขเอกสาร Unique ทั้งระบบถ้าระบบรองรับหลายบริษัท

17. Database Constraints

ถึงแม้ Go API จะ Validate แล้ว Database ต้องมี Constraint สำคัญซ้ำ

เช่น:

qty > 0
unit_price >= 0
vat_rate >= 0
allocated_qty > 0
received_qty > 0

รวมถึง Foreign Key และ Unique Constraint

Database ต้องไม่ยอมรับข้อมูลผิดรูปแบบแม้ API มี Bug

18. Concurrency

Transaction ที่เกี่ยวกับ Quantity ต้อง Lock Record ที่เกี่ยวข้อง

ตัวอย่าง:

ผู้ใช้ A และ B เปิด PR เดียวกันและสร้าง PO พร้อมกัน

ถ้าไม่ Lock:

PR Qty = 10

A เห็น Remaining = 10
B เห็น Remaining = 10

A สร้าง PO 10
B สร้าง PO 10

Total = 20 ❌

Function ต้องใช้ Row Lock เช่น:

SELECT ...
FOR UPDATE

ก่อนคำนวณ Remaining Quantity

หลักเดียวกันใช้กับ:

PR → PO
PO → GR
Approval Step
Document Sequence

19. Trigger Policy

Allowed

Trigger ที่แนะนำ:

set_updated_at
protect_approval_history

อาจมีเพิ่มเติมภายหลัง:

protect_posted_document

ถ้าพบว่าจำเป็น

Avoid

ไม่ควรใช้ Trigger ทำ:

Auto Create PO
Auto Create GR
Auto Approve
Auto Change PR Status จากการ Insert Item
Auto Change PO Status แบบซ่อน Logic
ส่ง Email
เรียก External API

งานเหล่านี้ควรผ่าน API / Function ที่ชัดเจน

20. Initial Database Objects

Baseline สำหรับ Purchasing 1.0:

Tables

suppliers

supplier_quotations
supplier_quotation_items

purchase_requisitions
purchase_requisition_items

approval_workflows
approval_workflow_steps
approval_instances
approval_instance_steps
approval_history

purchase_orders
purchase_order_items
pr_po_allocations

goods_receipts
goods_receipt_items
po_gr_allocations

document_attachments
document_sequences
audit_logs

Views

vw_active_suppliers

vw_pr_summary
vw_pr_item_remaining_qty

vw_po_summary
vw_po_item_remaining_qty

vw_gr_summary

vw_pending_approvals
vw_purchasing_dashboard

Functions / Procedures

fn_next_document_no

fn_submit_pr
fn_withdraw_pr
fn_cancel_pr

fn_approve_pr
fn_reject_pr

fn_create_po_from_pr
fn_issue_po
fn_cancel_po

fn_post_gr
fn_cancel_gr

Triggers

trg_set_updated_at
trg_protect_approval_history

จำนวน Trigger ต้องคงให้น้อยที่สุด

21. CRUD vs Function Matrix

Operation

Implementation

Create Supplier

Go API + pgx

Update Supplier

Go API + pgx

Disable Supplier

Go API + pgx

Create Quotation

Go API + Transaction

Update Draft Quotation

Go API + pgx

Create Draft PR

Go API + Transaction

Update Draft PR

Go API + Transaction

Submit PR

Function / SP

Withdraw PR

Function / SP

Approve PR

Function / SP

Reject PR

Function / SP

Create PO from PR

Function / SP

Update Draft PO

Go API + Transaction

Issue PO

Function / SP

Create Draft GR

Go API + Transaction

Post GR

Function / SP

Dashboard

View

Reports

View / Read-only Query

Approval History

Table, Insert-only

Audit Log

API / Function writes

22. What We Should Not Build Yet

Purchasing 1.0 ยังไม่ควรใส่:

3-way Matching
Supplier Invoice
Accounts Payable
Payment Voucher
General Ledger Posting
Inventory Costing
Warehouse Bin Management
Landed Cost
MRP
Production Material Issue
Complex Workflow Designer
Dynamic SQL Report Builder

เหตุผลคือจะทำ Scope ใหญ่เกิน MVP

ควรให้ Flow นี้ทำงานสมบูรณ์ก่อน:

Quotation
↓
PR
↓
Approval
↓
PO
↓
GR

23. Recommended Development Order

1. Common Database Foundation
   - company_id
   - users / permissions references
   - audit_logs
   - document_sequences
   - attachments

1. Supplier Master

1. Supplier Quotation

1. Purchase Requisition

1. Approval Workflow

1. PR → PO Conversion

1. Purchase Order

1. PO → GR Receipt

1. Goods Receipt

1. Views / Dashboard

1. Reports

1. Integration Tests

1. Testing Requirements

Functions ที่ทำ Transaction สำคัญต้องมี Test Case

ตัวอย่าง:

PR → PO

✓ Create PO full quantity
✓ Create PO partial quantity
✓ Create multiple PO from one PR
✓ Reject quantity greater than remaining
✓ Reject PO from unapproved PR
✓ Handle concurrent PO creation

PO → GR

✓ Receive full quantity
✓ Receive partial quantity
✓ Multiple GR from one PO
✓ Reject over receipt
✓ Reject receipt from cancelled PO
✓ Handle concurrent GR posting

Approval

✓ Correct approver can approve
✓ Unauthorized user cannot approve
✓ Cannot approve twice
✓ Cannot edit approval history
✓ Approval sequence is enforced

25. Architecture Decision Summary

Purchasing 1.0 ใช้แนวทาง:

CRUD ธรรมดา
→ Go API + pgx

Business Transaction หลายขั้น
→ PostgreSQL Function / Stored Procedure

Dashboard / Report / Summary
→ PostgreSQL View

Database Safety Rule
→ Trigger เฉพาะที่จำเป็น

Workflow Orchestration
→ Go API + Explicit Function Calls

หลักสำคัญที่สุดคือ:

Business Logic ต้องมองเห็นได้และตาม Debug ได้ ไม่ควรซ่อน Workflow จำนวนมากไว้ใน Trigger

26. Next Step

หลังจากเอกสารนี้ล็อกแล้ว ขั้นถัดไปคือออกแบบ:

Purchasing_1.0_Core_Schema.md

โดยกำหนด:

Table จริง

Column

Data Type

Primary Key

Foreign Key

Unique Constraint

Check Constraint

Index

Relationship

Mermaid ER Diagram

จากนั้นจึงเริ่มสร้าง Migration ของ Purchasing 1.0
