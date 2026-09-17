Purchasing 1.0 — Migration Plan

1. Purpose

เอกสารนี้กำหนดลำดับการสร้าง Migration สำหรับ Purchasing 1.0 หลังจากผ่านการออกแบบ:

Purchasing_1.0_Status_Workflow.md

Purchasing_1.0_Database_Architecture.md

Purchasing_1.0_Core_Schema.md

Purchasing_1.0_Schema_Review.md

เป้าหมายคือทำให้การสร้างฐานข้อมูลจริง:

มีลำดับ dependency ที่ชัดเจน

rollback ได้

test ได้เป็นช่วง

ลดความเสี่ยงจากการสร้าง object ข้ามลำดับ

รองรับ multi-company

รองรับ approval, partial PO, partial GR และ email approval

เอกสารนี้ยังไม่ใช่ SQL Migration Script

2. Migration Strategy

ใช้แนวคิด:

Small migrations
→ One responsibility per migration
→ Run in dependency order
→ Test after each logical group

ไม่ควรสร้างทุกอย่างในไฟล์ migration เดียว

3. Pre-Requisites

ก่อนเริ่ม Purchasing Migration ต้องยืนยันว่าระบบหลักมีอย่างน้อย:

companies
users

ถ้ามี Role / Permission system อยู่แล้ว ให้ใช้ของเดิม

ถ้ายังไม่มี:

approval_workflow_steps.approver_role_code

สามารถเก็บ role code เป็น string ไปก่อน

4. Migration Naming Convention

ตัวอย่าง:

202609160001_create_purchasing_foundation
202609160002_create_suppliers
202609160003_create_supplier_quotations
202609160004_create_purchase_requisitions
202609160005_create_approval_workflow
202609160006_create_purchase_orders
202609160007_create_goods_receipts
202609160008_create_purchasing_views
202609160009_create_purchasing_functions
202609160010_create_purchasing_triggers
202609160011_seed_purchasing_defaults

ถ้า ORM / migration tool มี naming convention ของตัวเอง ให้ใช้ convention ของโปรเจกต์ แต่คงลำดับ dependency เดิม

5. Migration 001 — Purchasing Foundation

สร้าง:

document_sequences
document_attachments
audit_logs

Purpose

เป็น shared infrastructure ที่ module อื่นจะใช้ได้ในอนาคตด้วย

document_sequences

ต้องมี:

id
company_id
document_type
year_no
month_no
last_number
updated_at

Constraint:

UNIQUE(company_id, document_type, year_no, month_no)

document_attachments

Generic attachment table:

entity_type
entity_id

ยังไม่มี FK ไปทุก document table

ต้อง validate ownership ผ่าน API

audit_logs

Generic immutable-ish business log

ยังไม่ใช้เป็น workflow source of truth

Test after Migration 001

✓ create document sequence row
✓ duplicate sequence key rejected
✓ attachment insert works
✓ audit JSONB insert works
✓ company FK works

6. Migration 002 — Suppliers

สร้าง:

suppliers

Constraints:

UNIQUE(company_id, supplier_code)
CHECK status IN ('ACTIVE', 'INACTIVE')
CHECK payment_term_days >= 0
CHECK lead_time_days >= 0
CHECK vat_rate BETWEEN 0 AND 100
CHECK char_length(currency_code) = 3
CHECK char_length(country_code) = 2

Indexes

(company_id, status)
(company_id, supplier_name)
(company_id, tax_id)

Test

✓ create supplier
✓ duplicate supplier code same company rejected
✓ same supplier code different company allowed
✓ invalid VAT rejected
✓ invalid currency code rejected
✓ inactive supplier retained

7. Migration 003 — Supplier Quotations

สร้าง:

supplier_quotations
supplier_quotation_items

Status persisted:

DRAFT
ACTIVE
CANCELLED

ไม่เก็บ:

EXPIRED

เพราะคำนวณจาก:

status = ACTIVE
AND valid_until < current_date

Important Constraints

UNIQUE(company_id, quotation_no)
UNIQUE(supplier_quotation_id, line_no)

CHECK line_no > 0
CHECK qty > 0
CHECK unit_price >= 0
CHECK vat_rate BETWEEN 0 AND 100
CHECK char_length(currency_code) = 3

Test

✓ create quotation
✓ quotation supplier must exist
✓ create multiple quotation items
✓ duplicate line no rejected
✓ invalid qty rejected
✓ attachment can be linked using entity_type

8. Migration 004 — Purchase Requisitions

สร้าง:

purchase_requisitions
purchase_requisition_items

PR Status:

DRAFT
PENDING_APPROVAL
APPROVED
REJECTED
PARTIALLY_ORDERED
FULLY_ORDERED
CANCELLED

Important Rules

PR Header ไม่เก็บ:

supplier_id

เพราะ PR เดียวสามารถทำ PO หลาย Supplier ได้

PR Item:

supplier_quotation_item_id nullable

Constraints

UNIQUE(company_id, pr_no)
UNIQUE(purchase_requisition_id, line_no)

CHECK line_no > 0
CHECK requested_qty > 0
CHECK estimated_unit_price IS NULL OR estimated_unit_price >= 0

Test

✓ create draft PR
✓ PR without supplier works
✓ PR item can reference quotation item
✓ PR item can exist without quotation
✓ duplicate PR number same company rejected
✓ same PR number different company allowed

9. Migration 005 — Approval Workflow

สร้าง:

approval_workflows
approval_workflow_steps
approval_instances
approval_instance_steps
approval_history
approval_action_tokens

10. approval_action_tokens

เพิ่มตาม Schema Review

Columns:

id
company_id
approval_instance_step_id
token_hash
action_scope
expires_at
used_at
revoked_at
created_at

Constraints:

UNIQUE(token_hash)

CHECK action_scope IN (
'APPROVE_REJECT',
'APPROVE_ONLY'
)

ห้ามเก็บ raw token

11. Approval History

ต้องออกแบบให้:

INSERT allowed
UPDATE blocked
DELETE blocked

Trigger จะสร้างใน migration trigger group ภายหลัง

12. Approval Test

ก่อน Functions:

✓ create workflow
✓ create workflow steps
✓ snapshot workflow into instance steps
✓ approval history insert works
✓ token hash unique
✓ expired token data structure works

13. Migration 006 — Purchase Orders

สร้าง:

purchase_orders
purchase_order_items
pr_po_allocations

PO Status:

DRAFT
ISSUED
PARTIALLY_RECEIVED
FULLY_RECEIVED
CANCELLED

Important Constraints

UNIQUE(company_id, po_no)
UNIQUE(purchase_order_id, line_no)
UNIQUE(pr_item_id, po_item_id)

CHECK line_no > 0
CHECK ordered_qty > 0
CHECK allocated_qty > 0
CHECK unit_price >= 0
CHECK vat_rate BETWEEN 0 AND 100

Important

ไม่เพิ่ม:

ordered_qty
remaining_qty

ใน PR Item

ใช้ allocation เป็น source of truth

Test

✓ create draft PO
✓ one PO has one supplier
✓ PO items created
✓ allocation links PR item and PO item
✓ same PR item can link multiple PO items
✓ same PO can contain multiple PR lines

14. Migration 007 — Goods Receipts

สร้าง:

goods_receipts
goods_receipt_items
po_gr_allocations

GR Status:

DRAFT
POSTED
CANCELLED

Constraints

UNIQUE(company_id, gr_no)
UNIQUE(goods_receipt_id, line_no)
UNIQUE(po_item_id, gr_item_id)

CHECK line_no > 0
CHECK received_qty > 0

Important

ไม่เก็บ:

received_qty_total
remaining_qty

ใน PO Item

ใช้ allocation เป็น source of truth

Test

✓ create draft GR
✓ GR item created
✓ allocation links PO item to GR item
✓ one PO item supports multiple GR
✓ one GR structure technically supports multiple PO

Application 1.0 ยังจำกัด UI:

1 GR → 1 PO

15. Migration 008 — Views

สร้าง:

vw_active_suppliers
vw_pr_item_remaining_qty
vw_po_item_remaining_qty
vw_pr_summary
vw_po_summary
vw_gr_summary
vw_pending_approvals
vw_purchasing_dashboard

16. View — PR Remaining Qty

Concept:

## requested_qty

# SUM(pr_po_allocations.allocated_qty)

remaining_qty

ต้องใช้:

COALESCE(..., 0)

17. View — PO Remaining Qty

Concept:

## ordered_qty

# SUM(po_gr_allocations.received_qty)

remaining_qty

18. View Test

✓ PR no allocation → remaining = requested
✓ PR partial allocation → remaining correct
✓ PR full allocation → remaining 0

✓ PO no receipt → remaining = ordered
✓ PO partial receipt → remaining correct
✓ PO full receipt → remaining 0

19. Migration 009 — Functions

สร้าง Function / Procedure ตามลำดับ:

fn_next_document_no
fn_submit_pr
fn_withdraw_pr
fn_revise_pr
fn_cancel_pr

fn_approve_pr
fn_reject_pr

fn_create_po_from_pr
fn_issue_po
fn_cancel_po

fn_post_gr
fn_cancel_gr

20. fn_next_document_no

ต้อง:

1. lock sequence row
2. create row if missing
3. increment last_number
4. format document number
5. return number

Format 1.0:

SQ-YYMM-####
PR-YYMM-####
PO-YYMM-####
GR-YYMM-####

21. fn_submit_pr

ต้อง:

Lock PR
Check company
Check status = DRAFT
Check PR has >= 1 item
Select active workflow
Create approval instance
Snapshot approval steps
Set PR = PENDING_APPROVAL
Insert approval history SUBMITTED
Insert audit

ถ้า workflow มี 0 step:

Decision สำหรับ 1.0:

Do not auto-approve silently
Return configuration error

22. fn_withdraw_pr

Allowed:

PENDING_APPROVAL → DRAFT

ต้อง:

cancel active approval instance
write WITHDRAWN history
write audit

Submit ใหม่ต้องสร้าง Approval Instance ใหม่

23. fn_revise_pr

Allowed:

REJECTED → DRAFT

ต้อง:

retain old approval instance
retain old history
set PR DRAFT
audit PR_REVISED

24. fn_approve_pr

ต้อง:

Lock approval instance
Lock current approval step
Check actor
Check company
Check token/channel if email
Prevent duplicate action
Approve current step
Move to next step

ถ้าเป็น final step:

approval instance = APPROVED
PR = APPROVED
approved_at = now()

25. fn_reject_pr

ต้อง:

validate approver
set step REJECTED
set instance REJECTED
set PR REJECTED
insert immutable history
audit

26. fn_create_po_from_pr

Critical Transaction

ต้องใช้:

FOR UPDATE

กับ PR Items ที่ถูกเลือก

Flow:

1. Check PR status APPROVED/PARTIALLY_ORDERED
2. Check company
3. Check supplier belongs to company
4. Lock selected PR items
5. calculate already allocated qty
6. calculate remaining qty
7. reject over-allocation
8. generate PO number
9. create PO header
10. create PO items
11. create pr_po_allocations
12. recalculate PR status
13. audit
14. commit

15. PR Status Recalculation

หลัง Create PO:

allocated = 0
→ APPROVED

0 < allocated < requested
→ PARTIALLY_ORDERED

allocated = requested for all lines
→ FULLY_ORDERED

ไม่ใช้ Trigger

28. fn_issue_po

Allowed:

DRAFT → ISSUED

ต้อง:

validate PO has item
validate supplier
validate totals
issued_at = now()
audit

29. fn_post_gr

Critical Transaction

ต้อง:

1. validate GR = DRAFT
2. validate PO = ISSUED/PARTIALLY_RECEIVED
3. validate supplier matches
4. lock PO items
5. calculate already received
6. reject over receipt
7. insert po_gr_allocations
8. set GR POSTED
9. recalculate PO status
10. audit
11. commit

12. PO Status Recalculation

received = 0
→ ISSUED

0 < received < ordered
→ PARTIALLY_RECEIVED

received = ordered for all lines
→ FULLY_RECEIVED

31. Migration 010 — Triggers

สร้างเฉพาะ:

trg_set_updated_at
trg_protect_approval_history

32. trg_set_updated_at

ใช้กับ:

suppliers
supplier_quotations
purchase_requisitions
purchase_orders
goods_receipts
approval_workflows

และ item tables ถ้าต้องการ

33. trg_protect_approval_history

Block:

UPDATE
DELETE

บน:

approval_history

Error message ควรชัดเจน:

approval_history is immutable

34. Migration 011 — Seed Purchasing Defaults

Seed แบบ minimum

ไม่ควร seed demo business data ใน production migration

Seed เฉพาะ configuration ที่จำเป็น

35. Seed — Document Types

ถ้า document type ใช้ string ใน sequence table:

ไม่ต้องมี master table

แต่ application ต้องรองรับ:

SQ
PR
PO
GR

36. Seed — Default Approval Workflow

สำหรับแต่ละ Company ไม่ควรสร้าง default โดย migration global แบบเดาสุ่ม user

เพราะไม่รู้ว่าใครเป็น Manager

ดังนั้น:

Migration ไม่ควร seed approver user อัตโนมัติ

แนวทาง:

ตอน Company เปิด Purchasing ครั้งแรก:

Setup Wizard
→ Configure Default PR Approval Workflow

37. Initial Approval Setup

ขั้นต่ำ:

workflow_code = PR_DEFAULT
entity_type = PR
status = ACTIVE

แต่ workflow step ต้องให้ Admin เลือกเอง

ถ้ายังไม่มี step:

Submit PR ต้อง fail ด้วย configuration error

เพื่อไม่ให้เอกสารผ่าน approval โดยไม่ได้ตั้งใจ

38. Permissions Seed

ถ้าระบบมี permission framework:

เพิ่ม permission:

purchasing.supplier.view
purchasing.supplier.create
purchasing.supplier.edit

purchasing.quotation.view
purchasing.quotation.create
purchasing.quotation.edit
purchasing.quotation.cancel

purchasing.pr.view
purchasing.pr.create
purchasing.pr.edit
purchasing.pr.submit
purchasing.pr.withdraw
purchasing.pr.cancel

purchasing.approval.view
purchasing.approval.approve
purchasing.approval.reject

purchasing.po.view
purchasing.po.create
purchasing.po.edit
purchasing.po.issue
purchasing.po.cancel

purchasing.gr.view
purchasing.gr.create
purchasing.gr.post
purchasing.gr.cancel

purchasing.report.view
purchasing.settings.manage

ถ้ายังไม่มี permission framework:

เก็บรายการนี้ไว้เป็น application contract ก่อน

39. Rollback Strategy

Migration Down ต้องทำ reverse dependency order

ตัวอย่าง:

Triggers
↓
Functions
↓
Views
↓
GR
↓
PO
↓
Approval
↓
PR
↓
Quotation
↓
Supplier
↓
Foundation

40. Production Rollback Warning

หลังมีข้อมูล production แล้ว:

DROP TABLE

ไม่ใช่ rollback strategy ที่เหมาะสมสำหรับ business deployment

จริง ๆ แล้วควรใช้:

forward fix migration

Rollback แบบ drop เหมาะกับ:

development
test
fresh environment

41. Migration Safety Rules

ทุก migration ต้อง:

1. ไม่ลบข้อมูล production โดยไม่จำเป็น
2. ไม่ rename column แบบ destructive โดยไม่มี data migration
3. ไม่เปลี่ยน type ที่เสี่ยง truncate
4. ไม่สร้าง default ที่ผิด business meaning
5. ไม่ seed user-specific approver
6. ไม่ disable FK เพื่อให้ migration ผ่าน

7. Testing Order

หลัง Migration ครบ ให้ test เป็น layer

Layer 1 — Schema

PK
FK
Unique
Check
Index

Layer 2 — Views

remaining qty
summary
dashboard

Layer 3 — Functions

document sequence
submit
approval
PO conversion
GR posting

Layer 4 — Concurrency

parallel document number
parallel PO create
parallel GR post
parallel approval

Layer 5 — Tenant Isolation

Company A cannot use Supplier B
Company A cannot approve Company B PR
Company A cannot allocate Company B PR
Company A cannot receive Company B PO

43. Critical Test Matrix

Document Number

✓ sequential number
✓ different company independent
✓ different month resets
✓ parallel generation no duplicate

PR

✓ draft create
✓ submit valid PR
✓ submit empty PR rejected
✓ withdraw pending PR
✓ rejected PR revise to draft
✓ resubmit creates new approval instance

Approval

✓ correct approver approves
✓ wrong approver rejected
✓ approve twice rejected
✓ reject flow correct
✓ history immutable
✓ expired email token rejected
✓ used token rejected
✓ revoked token rejected

PR → PO

✓ full conversion
✓ partial conversion
✓ multiple PO
✓ multiple suppliers
✓ over allocation rejected
✓ concurrent allocation safe

PO → GR

✓ full receipt
✓ partial receipt
✓ multiple GR
✓ over receipt rejected
✓ draft PO receipt rejected
✓ concurrent receipt safe

44. Migration Completion Definition

ถือว่า Database Purchasing 1.0 พร้อมเมื่อ:

[ ] all migrations run from empty DB
[ ] all migrations apply in CI
[ ] all FKs valid
[ ] all constraints pass
[ ] all views return expected results
[ ] critical functions tested
[ ] race condition tests pass
[ ] approval history cannot update/delete
[ ] tenant isolation tested
[ ] fresh rollback works in dev

45. Recommended Implementation Boundary

ตอนเริ่มเขียนจริง:

Codex / AI สามารถช่วย:

- generate migration draft
- generate SQL function draft
- generate test draft
- review constraints

แต่ต้องอ้างอิงเอกสารชุดนี้และห้าม invent business rule เพิ่มเอง

Prompt requirement:

If a business rule is not specified in the Purchasing 1.0 documents,
mark it as OPEN QUESTION instead of inventing behavior.

46. Suggested Development Sequence After Migration

หลัง Database Foundation พร้อม:

1. Supplier API
2. Supplier UI

3. Supplier Quotation API
4. Supplier Quotation UI

5. PR Draft API/UI

6. Approval Settings
7. PR Submit / Approval

8. Create PO from PR

9. PO UI

10. Create/Post GR

11. GR UI

12. Dashboard

13. Reports

14. Email Approval

แม้ schema รองรับ email approval ตั้งแต่ต้น แต่ UI/email sending สามารถทำหลัง core flow ทำงานแล้ว

47. Final Migration Order

001 Foundation
↓
002 Suppliers
↓
003 Supplier Quotations
↓
004 Purchase Requisitions
↓
005 Approval
↓
006 Purchase Orders
↓
007 Goods Receipts
↓
008 Views
↓
009 Functions
↓
010 Triggers
↓
011 Seeds / Permissions

48. Next Step

หลังเอกสารนี้ เราพร้อมเริ่ม implementation จริงแล้ว

แนะนำขั้นถัดไป:

Purchasing 1.0 — Migration 001 Foundation

สร้างของจริงเฉพาะ:

document_sequences
document_attachments
audit_logs

พร้อม:

migration up

migration down สำหรับ dev

indexes

constraints

schema tests

จากนั้นตรวจให้ผ่านก่อนขึ้น Migration 002
