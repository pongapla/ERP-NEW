Purchasing 1.0 — Status & Workflow

1. Purpose

เอกสารนี้กำหนดสถานะ (Status), การเปลี่ยนสถานะ (Transition), สิทธิ์การทำงาน (Permission) และ Business Rules สำหรับโมดูล Purchasing 1.0

เป้าหมายคือให้ระบบรองรับ Workflow หลักตั้งแต่การขอซื้อจนถึงรับสินค้า โดยยังไม่รวม Accounting, AP, Inventory Costing และ Production

Workflow หลัก:

Supplier Quotation
↓
Purchase Requisition (PR)
↓
Approval
↓
Purchase Order (PO)
↓
Goods Receipt (GR)

2. Design Principles

ระบบ Purchasing 1.0 ใช้หลักดังนี้:

ชื่อสถานะต้องอ่านและเข้าใจได้ง่าย

Approval History ต้องเป็น Immutable

ต้องรองรับ Partial Conversion

ต้องรองรับ Partial Receipt

ห้ามจำนวนที่ทำต่อเกินจำนวนเอกสารต้นทาง

การยกเลิกต้องมีประวัติและเหตุผล

เอกสารที่เข้าสู่ Workflow แล้วต้องไม่ถูกแก้ไขย้อนหลังโดยไม่มีหลักฐาน

ทุกการเปลี่ยนสถานะสำคัญต้องมี Audit Log

3. Purchase Requisition (PR)

3.1 PR Status

Status

ความหมาย

DRAFT

เอกสารยังอยู่ระหว่างจัดทำ สามารถแก้ไขได้

PENDING_APPROVAL

ส่งเอกสารเข้าสู่กระบวนการอนุมัติแล้ว

APPROVED

ได้รับการอนุมัติ สามารถนำไปสร้าง PO ได้

REJECTED

ผู้อนุมัติไม่อนุมัติ

PARTIALLY_ORDERED

มีการนำรายการใน PR ไปสร้าง PO แล้วบางส่วน

FULLY_ORDERED

จำนวนใน PR ถูกนำไปสร้าง PO ครบทั้งหมดแล้ว

CANCELLED

PR ถูกยกเลิก

3.2 PR Workflow

DRAFT
│
├── Submit
↓
PENDING_APPROVAL
│
├── Approve ─────────────→ APPROVED
│ │
│ ├── Create partial PO
│ ↓
│ PARTIALLY_ORDERED
│ │
│ ├── Complete remaining PO
│ ↓
│ FULLY_ORDERED
│
└── Reject ──────────────→ REJECTED

PR สามารถถูกยกเลิกได้ตาม Business Rule ที่กำหนด โดยต้องตรวจสอบก่อนว่าเอกสารถูกนำไปสร้าง PO แล้วหรือไม่

3.3 PR Transition Matrix

Current Status

Action

Next Status

DRAFT

Submit

PENDING_APPROVAL

DRAFT

Cancel

CANCELLED

PENDING_APPROVAL

Approve

APPROVED

PENDING_APPROVAL

Reject

REJECTED

PENDING_APPROVAL

Withdraw

DRAFT

APPROVED

Create Partial PO

PARTIALLY_ORDERED

APPROVED

Create Full PO

FULLY_ORDERED

PARTIALLY_ORDERED

Create Remaining PO

FULLY_ORDERED

4. Purchase Order (PO)

4.1 PO Status

Status

ความหมาย

DRAFT

PO อยู่ระหว่างจัดทำ

ISSUED

PO ถูกออกและถือว่าเป็นเอกสารใช้งานแล้ว

PARTIALLY_RECEIVED

รับสินค้าแล้วบางส่วน

FULLY_RECEIVED

รับสินค้าครบทั้งหมด

CANCELLED

PO ถูกยกเลิก

4.2 PO Workflow

DRAFT
│
├── Issue
↓
ISSUED
│
├── Partial GR
↓
PARTIALLY_RECEIVED
│
├── Receive Remaining
↓
FULLY_RECEIVED

4.3 PO Transition Matrix

Current Status

Action

Next Status

DRAFT

Issue

ISSUED

DRAFT

Cancel

CANCELLED

ISSUED

Receive Partial

PARTIALLY_RECEIVED

ISSUED

Receive Full

FULLY_RECEIVED

PARTIALLY_RECEIVED

Receive Remaining

FULLY_RECEIVED

5. Goods Receipt (GR)

5.1 GR Status

Status

ความหมาย

DRAFT

เอกสารรับสินค้ายังอยู่ระหว่างจัดทำ

POSTED

ยืนยันการรับสินค้าแล้ว

CANCELLED

เอกสารถูกยกเลิกหรือกลับรายการตาม Workflow

5.2 GR Workflow

DRAFT
│
├── Post
↓
POSTED

การยกเลิก GR หลัง POSTED ไม่ควรใช้การลบข้อมูล แต่ควรใช้ Cancel/Reversal พร้อมบันทึกเหตุผลและ Audit Log

6. Partial Conversion Rules

6.1 PR → PO

ระบบต้องรองรับการออก PO หลายครั้งจาก PR เดียว

ตัวอย่าง:

PR Item
Requested Qty = 10

PO #1 = 4
PO #2 = 6

ผลลัพธ์:

Ordered Qty = 10 / 10
PR Status = FULLY_ORDERED

ถ้ามีเพียง:

PO #1 = 4

ผลลัพธ์:

Ordered Qty = 4 / 10
Remaining Qty = 6
PR Status = PARTIALLY_ORDERED

Rule

SUM(PO Qty) <= PR Qty

ระบบต้องไม่อนุญาตให้สร้าง PO เกินจำนวน PR

6.2 PO → GR

ระบบต้องรองรับการรับสินค้าหลายครั้งจาก PO เดียว

ตัวอย่าง:

PO Qty = 10

GR #1 = 4
GR #2 = 3
GR #3 = 3

ผลลัพธ์:

Received Qty = 10 / 10
PO Status = FULLY_RECEIVED

ถ้ารับเพียง:

GR #1 = 4

ผลลัพธ์:

Received Qty = 4 / 10
Remaining Qty = 6
PO Status = PARTIALLY_RECEIVED

Rule

SUM(GR Qty) <= PO Qty

ระบบต้องไม่อนุญาตให้รับสินค้าเกินจำนวน PO

7. Approval Rules

7.1 Approval History

Approval History ต้องเป็น Immutable

หมายความว่า:

ห้ามลบ Approval History

ห้ามแก้ผู้อนุมัติย้อนหลัง

ห้ามแก้ผลการอนุมัติย้อนหลัง

ห้ามแก้เวลาที่อนุมัติย้อนหลัง

หากเกิดการแก้ไข Workflow ให้สร้าง Event ใหม่แทน

ตัวอย่าง:

Submitted
Approved by Manager
Rejected by Director
Revised
Submitted Again
Approved by Manager
Approved by Director

ทุก Event ต้องยังคงอยู่ในระบบ

7.2 Approval Channels

Purchasing 1.0 เตรียมรองรับการอนุมัติได้อย่างน้อย 2 ช่องทาง:

In-App Approval
Email Approval

ไม่ว่าผู้ใช้จะอนุมัติผ่านช่องทางใด ต้องบันทึกลง Approval History เดียวกัน

ควรเก็บข้อมูลอย่างน้อย:

Approver

Action

Comment

Date/Time

Approval Step

Channel

IP / Request Metadata ตามความเหมาะสม

8. Document Editing Rules

DRAFT

สามารถ:

เพิ่มรายการ

ลบรายการ

แก้จำนวน

แก้ Supplier

เพิ่ม/ลบ Attachment

แก้หมายเหตุ

PENDING_APPROVAL

โดยปกติห้ามแก้ข้อมูลหลัก

ถ้าต้องแก้:

Withdraw → DRAFT → Edit → Submit Again

เพื่อรักษาประวัติ Workflow

APPROVED / ISSUED / POSTED

ไม่ควรแก้ข้อมูลหลักโดยตรง

หากมีความผิดพลาดควรใช้:

Cancel

Reversal

Revision

Replacement Document

ตามประเภทเอกสาร

9. Cancellation Rules

ทุกการยกเลิกต้องมี:

Cancel Reason

Cancelled By

Cancelled At

Previous Status

Audit Log

ห้าม Hard Delete เอกสารธุรกิจที่เคย Submit / Approve / Issue / Post แล้ว

ตัวอย่าง:

PR-2609-001
Status: CANCELLED
Reason: Request duplicated
Cancelled By: user@example.com

10. Permission Concept

Purchasing 1.0 ควรออกแบบ Permission จาก Action ไม่ใช่แค่หน้าเมนู

ตัวอย่าง Permission:

purchasing.pr.view
purchasing.pr.create
purchasing.pr.edit
purchasing.pr.submit
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

11. Audit Log

Event สำคัญที่ต้องบันทึก เช่น:

PR_CREATED
PR_UPDATED
PR_SUBMITTED
PR_WITHDRAWN
PR_APPROVED
PR_REJECTED
PR_CANCELLED

PO_CREATED
PO_ISSUED
PO_CANCELLED

GR_CREATED
GR_POSTED
GR_CANCELLED

Audit Log ควรเก็บอย่างน้อย:

Entity Type

Entity ID

Action

User

Timestamp

Previous Value

New Value

Metadata

12. Purchasing 1.0 Scope

Purchasing 1.0 ครอบคลุม:

Supplier
Supplier Quotation
Purchase Requisition
Approval
Purchase Order
Goods Receipt
Attachments
Approval History
Audit Log
Reports

ยังไม่รวม:

Accounts Payable
Invoice Matching
Payment
General Ledger
Inventory Costing
Production
Sales Order

โมดูลเหล่านี้สามารถต่อเพิ่มภายหลังโดยอาศัยเอกสาร Purchasing ที่มีอยู่

13. Reference From Legacy ERP Analysis

จากการวิเคราะห์ Legacy ERP พบแนวคิดสถานะเดิมประมาณ:

PR / Request

R = Requested
A = Approved
D = Disapproved
S = Stopped
C = Converted
H = History

PO

P = Planned
O = Ordered
F = Filled
C = Complete

Purchasing 1.0 ไม่จำเป็นต้องใช้ Code เดิม แต่ใช้ความหมายเหล่านี้เป็น Reference และเปลี่ยนเป็นชื่อที่อ่านง่ายกว่า

ตัวอย่าง:

Requested → PENDING_APPROVAL
Approved → APPROVED
Converted → PARTIALLY_ORDERED / FULLY_ORDERED
Filled → PARTIALLY_RECEIVED
Complete → FULLY_RECEIVED

หมายเหตุ: สถานะ Legacy ที่ยังไม่ได้รับการยืนยันจาก Source หรือ Runtime Trace ไม่ควรถูกนำมาใช้เป็น Business Rule โดยอัตโนมัติ

14. Final Workflow

Supplier
│
↓
Supplier Quotation
│
↓
PR
DRAFT
│
↓
PENDING_APPROVAL
│
├── REJECTED
│
└── APPROVED
│
↓
PARTIALLY_ORDERED
│
↓
FULLY_ORDERED
│
↓
PO
DRAFT
│
↓
ISSUED
│
↓
PARTIALLY_RECEIVED
│
↓
FULLY_RECEIVED
│
↓
GR
POSTED

15. Next Step

หลังจากล็อก Status & Workflow ชุดนี้แล้ว ลำดับการพัฒนาที่แนะนำคือ:

1. Supplier Master
2. Supplier Quotation
3. Purchase Requisition
4. Approval Workflow
5. Purchase Order
6. Goods Receipt
7. Reports
8. Purchasing Dashboard

เอกสารนี้ควรถือเป็น Baseline ของ Purchasing 1.0 ก่อนออกแบบ Database Schema และ API Contract
