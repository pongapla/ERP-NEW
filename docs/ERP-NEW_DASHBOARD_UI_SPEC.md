ERP-NEW Dashboard UI Specification

1. Objective

เอกสารนี้กำหนดทิศทางหน้าตา ERP-NEW Dashboard ให้ยึดตามภาพอ้างอิงที่ตกลงกันไว้

แนวทางหลัก:

Modern ERP

Sidebar สีเข้ม

Topbar สีขาว

Dashboard แบบ Card-based

รองรับหลาย Module

รองรับ Multi-company

รองรับ Permission-based menu

รองรับภาษาไทย/อังกฤษ

ใช้พื้นที่หน้าจอ Desktop ให้คุ้ม

เน้นอ่านง่าย ดูข้อมูลเร็ว และเข้าเมนูได้ไว

2. Overall Layout

โครงสร้างหลักของหน้าระบบ:

┌────────────────────────────────────────────────────────────────────┐
│ Sidebar │ Topbar │
│ ├───────────────────────────────────────────────────────────┤
│ │ Hero / Welcome Area │
│ ├───────────────────────────────────────────────────────────┤
│ │ KPI Cards │
│ ├───────────────────────────────────────────────────────────┤
│ │ Purchase Summary │ PO Status Chart │
│ ├───────────────────────────┼───────────────────────────────┤
│ │ Recent Documents │ Alerts / Follow-up │
│ └───────────────────────────┴───────────────────────────────┘
└────────────────────────────────────────────────────────────────────┘

3. Sidebar

ตำแหน่ง:

ด้านซ้ายเต็มความสูงของหน้าจอ

ลักษณะ:

Background สีกรม / navy เข้ม

Logo อยู่ด้านบน

Menu icon + text

Active menu ใช้พื้นหลังสีน้ำเงิน

Menu ที่มี submenu ใช้ arrow ด้านขวา

แบ่ง Main Menu และ System Menu

ด้านล่างแสดงชื่อบริษัทและ version

ตัวอย่าง:

TrainX ERP
Simple • Efficient • Together

Dashboard

Purchasing >
Sales >
Inventory >
Planning >
Production >
Quality Control >
Maintenance >
Accounting >
Reports >

---

Master Data
Settings

---

ABC Manufacturing Co., Ltd.
Version 1.0.0

Permission Behavior

Sidebar ต้องแสดงเมนูตาม Permission ของผู้ใช้

ตัวอย่าง:

User มี:

- purchasing.view
- pr.view
- po.view

User ไม่มี:

- accounting.view

ผลลัพธ์:

Purchasing -> แสดง
Accounting -> ไม่แสดง

4. Topbar

Topbar อยู่ด้านบนของ content area

องค์ประกอบ:

[Collapse Sidebar]

[Company Selector]

[Global Search]

[Notification]

[User Profile]

[Language Selector]

ตัวอย่าง:

บริษัท ตัวอย่าง จำกัด v

ค้นหาเมนู / เลขที่เอกสาร / สินค้า ...

🔔 3

Pong
Administrator v

TH v

5. Company Selector

ERP-NEW ต้องรองรับ Multi-company ในอนาคต

Topbar แสดงบริษัทปัจจุบัน เช่น:

บริษัท ตัวอย่าง จำกัด

เมื่อกด:

บริษัท ตัวอย่าง จำกัด
ABC Manufacturing Co., Ltd.
XYZ Trading Co., Ltd.

สิทธิ์การเห็นบริษัทขึ้นกับ User Permission

6. Global Search

ตำแหน่ง:

กลาง Topbar

Placeholder:

ค้นหาเมนู / เลขที่เอกสาร / สินค้า ...

Search ในอนาคตควรรองรับ:

Menu

PR

PO

GR

Quotation

Supplier

Item

Customer

Document number

7. Notification

ตัวอย่าง icon:

🔔

มี badge แสดงจำนวน:

3

Notification ที่ควรรองรับ:

PR รออนุมัติ

PR ถูกส่งกลับ

PO เลยกำหนด

GR รับของไม่ครบ

Quotation ใกล้หมดอายุ

Approval pending

System notification

8. User Profile

แสดง:

Pong
Administrator

Menu:

Profile
Change Password
Logout

อนาคตสามารถเพิ่ม:

My Approvals
My Tasks
Preferences

9. Language Selector

ตัวอย่าง:

🇹🇭 TH

รองรับอย่างน้อย:

TH
EN

UI และ label ของระบบควรรองรับ i18n ตั้งแต่โครงสร้างแรก

10. Welcome / Hero Area

บริเวณบน Dashboard

ตัวอย่าง:

สวัสดีครับ Pong

ยินดีต้อนรับสู่ระบบ ERP
จัดการธุรกิจของคุณให้ง่ายขึ้น ในที่เดียว

ด้านขวา:

วันอังคารที่ 16 กันยายน 2026
10:24

และข้อความสั้น:

“ควบคุมงานได้ดี
ธุรกิจเดินหน้าได้ไกลกว่า”

สามารถมี background image แบบโรงงาน / warehouse แบบจาง ๆ

11. Main KPI Cards

แถวบนของ Dashboard

จำนวนประมาณ:

5 Cards

ตัวอย่าง:

PR รออนุมัติ
5
↑ 2 จากเมื่อวาน

PR ถูกส่งกลับ
2
↑ 1 จากเมื่อวาน

PO รอออก
3
↓ 1 จากเมื่อวาน

รอรับของ (GR)
4
↑ 2 จากเมื่อวาน

เอกสารเลยกำหนด
6
↑ 3 จากเมื่อวาน

Card แต่ละใบประกอบด้วย:

Icon

Label

Number

Trend

Color status

12. Purchasing Summary

Section:

สรุปการจัดซื้อ (เดือนนี้)

มี Month Selector:

กันยายน 2026

ข้อมูล:

จำนวน PR
28
↑ 12%

จำนวน PO
18
↑ 8%

มูลค่าการสั่งซื้อ
฿1,245,000
↑ 15%

รับของแล้ว
65%

Progress bar:

█████████████░░░░░░
65%

13. PO Status Chart

หัวข้อ:

สัดส่วนสถานะ PO

ใช้ Donut Chart

ตัวอย่าง:

ทั้งหมด
24

สถานะ:

รออนุมัติ 3
ส่งแล้ว 12
รับบางส่วน 5
รับครบ 3
ยกเลิก 1

สีแต่ละสถานะควรแตกต่างกัน

14. Recent Documents

หัวข้อ:

เอกสารล่าสุด

ตัวอย่าง Table:

เลขที่เอกสาร | ประเภท | Supplier / ลูกค้า | สถานะ | วันที่

ตัวอย่าง:

PR-2609-0012 | PR | - | รออนุมัติ | 16/09/2026
PO-2609-0008 | PO | ABC Co., Ltd. | ส่งแล้ว | 16/09/2026
GR-2609-0003 | GR | ABC Co., Ltd. | รับครบ | 15/09/2026
PR-2609-0011 | PR | - | ถูกส่งกลับ | 15/09/2026
PO-2609-0007 | PO | XYZ Supply | รับบางส่วน | 14/09/2026

มีปุ่ม:

ดูทั้งหมด

15. Alert / Follow-up Panel

หัวข้อ:

แจ้งเตือน / สิ่งที่ต้องติดตาม

ตัวอย่าง:

🔴 PO เลยกำหนดส่ง
มี 3 รายการที่เลยกำหนดส่ง

🟠 Quotation ใกล้หมดอายุ
มี 2 รายการที่ใกล้หมดอายุภายใน 7 วัน

🔵 PR ค้างอนุมัติเกิน 3 วัน
มี 4 รายการ

⚪ รับของไม่ครบตาม PO
มี 5 รายการที่ยังรับไม่ครบ

แต่ละรายการสามารถกดเพื่อ Drill-down ได้

16. Visual Style

Sidebar

Dark Navy

Content Background

Light gray / light blue gray

Card

White
Rounded corner
Soft shadow
Thin border

Accent

ใช้สีตามประเภทข้อมูล:

Blue = Primary / Information
Green = Success
Yellow = Pending / Warning
Orange = Returned / Attention
Red = Critical / Overdue
Purple = Special status

17. Typography

เน้น:

อ่านง่าย

ภาษาไทยชัด

ตัวเลขเด่น

Header ใหญ่กว่าข้อมูลทั่วไป

ตัวอย่าง hierarchy:

Page Title
32px

Section Title
20px

Card Value
28–32px

Body
14–16px

Secondary Text
12–14px

18. Responsive Behavior

Desktop เป็นเป้าหมายหลัก

รองรับ:

1920 x 1080
1440 x 900
1366 x 768

Tablet:

Sidebar collapse

KPI cards 2 columns

Chart / table stack

Mobile:

Sidebar เป็น drawer

KPI cards 1 column

Table อาจใช้ horizontal scroll

19. Component Structure

แนะนำ component:

app/components/
├─ layout/
│ ├─ AppSidebar.vue
│ ├─ AppHeader.vue
│ ├─ AppCompanySelector.vue
│ ├─ AppGlobalSearch.vue
│ ├─ AppNotification.vue
│ └─ AppUserMenu.vue
│
├─ dashboard/
│ ├─ DashboardHero.vue
│ ├─ DashboardStatCard.vue
│ ├─ PurchasingSummary.vue
│ ├─ POStatusChart.vue
│ ├─ RecentDocuments.vue
│ └─ FollowUpPanel.vue
│
└─ common/
├─ StatusBadge.vue
├─ EmptyState.vue
└─ LoadingState.vue

20. Page Structure

app/pages/dashboard/index.vue

Composition:

Dashboard Page
├─ DashboardHero
├─ Dashboard KPI Cards
├─ PurchasingSummary
├─ POStatusChart
├─ RecentDocuments
└─ FollowUpPanel

21. Data State

ช่วงแรกใช้ Mock Data ได้

เช่น:

const stats = [
{
label: 'PR รออนุมัติ',
value: 5
},
{
label: 'PR ถูกส่งกลับ',
value: 2
}
]

ภายหลังค่อยเปลี่ยนเป็น API

GET /api/dashboard/summary
GET /api/dashboard/recent-documents
GET /api/dashboard/alerts

22. Important Architecture Rule

Dashboard เป็น Presentation Layer เท่านั้น

ห้าม:

เขียน business logic หนักใน component

query database โดยตรงจาก frontend

hardcode permission เป็น logic กระจายหลายหน้า

ต้องใช้:

Frontend
↓
API
↓
Service / Business Logic
↓
Database

23. Permission Integration

Dashboard card ต้องเคารพ Permission

ตัวอย่าง:

ถ้าไม่มี pr.view
→ ไม่แสดง PR card

ถ้าไม่มี po.view
→ ไม่แสดง PO status chart

ถ้าไม่มี purchasing.dashboard
→ ไม่แสดง Purchasing Summary

เช่นเดียวกับ Sidebar

24. Target Dashboard

Dashboard เป้าหมายของ ERP-NEW:

เปิดระบบ
↓
เห็นงานที่ต้องทำทันที
↓
เห็นสิ่งที่ค้าง
↓
เห็นสิ่งที่ผิดปกติ
↓
กด Drill-down
↓
ไปยังเอกสารหรือ Module ที่เกี่ยวข้อง

Dashboard ไม่ควรเป็นแค่หน้าตัวเลข แต่ต้องเป็นหน้าสำหรับช่วยตัดสินใจและเข้าสู่งานประจำวัน

25. Current Design Status

[x] Dashboard visual direction defined
[x] Sidebar direction defined
[x] Topbar direction defined
[x] KPI card direction defined
[x] Purchasing Summary defined
[x] PO status chart defined
[x] Recent document table defined
[x] Follow-up panel defined
[x] Permission behavior concept defined

[ ] Implement full UI
[ ] Connect authentication
[ ] Connect permission
[ ] Connect dashboard API
[ ] Connect notification
[ ] Connect global search
[ ] Connect company selector

26. Implementation Priority

ลำดับทำ Frontend:

1. App Layout
2. Sidebar
3. Topbar
4. Dashboard Hero
5. KPI Cards
6. Purchasing Summary
7. PO Status Chart
8. Recent Documents
9. Follow-up Panel
10. Permission-based visibility
11. Responsive behavior
12. API integration

13. Design Reference Rule

ภาพ Dashboard ที่ตกลงกันไว้ให้ถือเป็น Visual Reference หลัก ของ ERP-NEW เวอร์ชันแรก

เป้าหมายคือ:

รักษา layout

รักษา visual hierarchy

รักษาความรู้สึกของ Modern ERP

ไม่จำเป็นต้อง pixel-perfect

สามารถปรับข้อความ, icon, spacing และ component ตามความเหมาะสมของระบบจริง

ระบบจริงต้องออกแบบให้ maintainable และรองรับการขยาย module ในอนาคต
