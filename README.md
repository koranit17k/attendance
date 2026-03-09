# Project Attendance System

## โครงการ ระบบบันทึกเวลาเข้า-ออกงาน

## Database Project Structure

```
./attendance
  ├── README.md                  # README for Dev & Ai
  ├──/fonts                      # Thai fonts used in report
  ├──/docs                       # Content
  │   ├── 1.workflow.md          # Workflow
  │   ├── 2.reportdetails.md     # Report Details
  │   ├── 3.exampledata.md       # Example Data
  │   ├── 4.vitest.md            # how to use test
  │   └── 5.workflowreport.md    # Report workflow
  ├──/report                     # Jasper Report
  │   ├── *.jrxml                # JRXML Source Files
  │   ├── *.jasper               # Jasper Report Files
  │   ├── A01.jrxml              # Check Daily Time
  │   ├── A02.jrxml              # Check summary persoanl
  │   └── A03.jrxml              # Check monthly summary
  ├──/sql                        # SQL Script
  │   ├── /sqltest               # test accuracy by sql
  |   |   ├── 1.seed_test_data.sql   # Create test data
  │   |   ├── 2.check_results.sql    # Check test data
  │   |   └── 3.cleartest.sql        # Clear test data
  │   ├── /storage                           # Storage sql
  │   |   ├── insert_attendance.sql          # insert time data 
  │   |   ├── insert_and_clean_emp.sql  # insert new employee, update all emp to 1, clean who aren't working.
  │   |   ├── myviewtranslate.sql            # calculate view before myview
  │   |   └── update_attendance.sql          # update calculate view to attendance
  │   ├── 1.database.sql         # Create Database & User
  │   ├── 2.table.sql            # Create Table
  │   ├── 3.view.sql             # Create View
  │   ├── 4.myview.sql           # Create view for use calculator
  │   ├── 5.procedure.sql        # Procedure sql before autorun
  │   ├── 6.setup_autorun.sql    # Setup autorun
  │   └── 7.check_autorun.sql    # Check autorun
  ├──/script                     # Script
  │   ├── restore.sh             # Restore Database
  │   ├── runtest.sh             # runtest by sql
  │   ├── backup.sh              # Backup Database
  │   └── copyreport.sh          # copy-paste report.jasper file for use 
  ├──/test                       # accuracy test
  │   ├── sum.js                 # mock-up for test
  │   ├── sum.test.js            # mock-up for test
  │   └── att.tes.js             # attendance test
  ├──.prettierrc                 # Prettier config format
  └──.gitignore                  # don't commit this file
```

## . Attendance Rules

## การคำนวณเวลางาน

> การสแกนเวลางานไม่ระบุเข้าหรือออก ใช้ช่วงเวลาสแกนเป็นตัวกำหนด พิจารณาแค่หลักวินาที

- วันทำงาน จันทร์ - เสาร์
- วันหยุด ทุกวันอาทิตย์ หรือวันหยุดประจำปี (13 วัน)
- เวลางานประจำวัน 8:00 - 17:00
- ช่วงเวลาสแกน แยกแยะเข้า/ออกตามช่วงเวลาต่างๆ _ถ้ามีหลายครั้ง ใช้ครั้งสุดท้าย/max_
  - morning เวลาเข้า เช้า 06:00 - 10:00
  - lunch out เวลา พักเที่ยง 11:00 - 13:30 _หลายครั้ง ใช้ครั้งแรก/min_
  - lunch in เวลา กลับเที่ยง 11:30 - 15:00
  - evening เวลาออก เย็น 16:00 - 18:00
  - night เวลาออก ค่ำ 19:00 - 24:00
  - early เวลาออก ข้ามวัน 00:00 - 06:00 ใช้วันที่เมื่อวาน
- หักเวลาพักเที่ยง 1 ชั่วโมง บังคับสแกนเที่ยง ไม่ว่าจะพักหรือไม่
  > มีพักเที่ยง 2 รอบ 11:00 และ 12:00
  - ไม่สแกนเที่ยง - หักเพิ่ม 4 ชั่วโมง
  - สแกนเที่ยงไม่ครบ - หักเพิ่ม 2 ชั่วโมง
  - สแกนออกเข้าเที่ยงเกิน - หักเพิ่มตามนาทีสาย
- เวลา OT คิดเมื่อ เข้าเช้าและมีเวลาออก ข้ามวัน หรือค่ำ
  - หักช่วงพักเลิกงาน 1 ชั่วโมง เริ่มหลัง 18:00
  - เวลา OT ที่คำนวณได้ อาจจะจ่าย OT หรือไม่ขึ้นอยู่กับผู้อนุมัติ

### <span style="color:green">1 กรณีเต็มวัน</span> (มีเวลาเข้างาน และ มีเวลาออกงาน)

> คำนวณเวลางาน เวลาสาย และ OT

- เงื่อนไข มีเวลาเข้าตอนเช้า และ (มีเวลาออกเย็น หรือ ค่ำ หรือ ข้ามวัน)
- (morning is not null and not (evening is null and night is null and early is null))

### <span style="color:yellow">2 กรณีครึ่งวัน</span> (มีแค่เวลาเข้า หรือ มีแค่เวลาออก) และ มีเวลาพักเที่ยง

> ตรวจสอบการลา ครึ่งวัน จากข้อมูลใบลาประเภทต่างๆ

- เงื่อนไข มีการสแกนช่วงเที่ยง และ (มีเวลาเข้าตอนเช้า หรือ-xor (มีเวลาออกเย็น หรือ ค่ำ หรือ ข้ามวัน))
- (lunch_out is not null or lunch_in is not null) and
  (morning is not null xor not (evening is null and night is null and early is null))
- ใช้ xor เพื่อตัดกรณีที่ (ไม่เช้า และ ไม่มีออกงาน)

### <span style="color:red">3 กรณีอื่นๆ</span> (ไม่นับวันเวลาทำงาน)

> ตรวจสอบการลาเต็มวันทุกประเภท หรือไม่ก็นับว่าเป็นการขาดงาน

- เงื่อนไข นอกเหนือจากแบบเต็มวัน หรือ ครึ่งวัน บันทึกสถานะเป็นขาดงาน
- เช็คข้อมูลการลา ถ้ามี บันทึกประเภทการลา

### การแก้ไขปรับปรุง เวลางานจากเจ้าหน้าที่

> เจ้าหน้าที่ สามารถแก้ไขวันเวลาในตาราง `attendance`

- ข้อมูลเวลาสแกนจะถูกย้ายไปยังตาราง `attendance`
- มีการประมวลผลเวลางานจากตาราง `attendance`
- มี event ประจำวันที่ย้ายเวลาและทำการประมวลผลเวลางาน อัตโนมัติทุกวัน
- เมื่อมีการแก้ไขโดยเจ้าหน้าที่ ต้องเรียกประมวลผลเวลางานเฉพาะกิจทุกครั้ง



### สรุปเคสการคำนวณเวลาทำงาน (แบ่ง 3 เคสใหญ่)

---

### ✅ เคสเขียว — ทำงานปกติ (08:00–17:00)

- มีการสแกน **เข้า** และ **ออก** ครบถ้วน
- เวลาการทำงานอยู่ในช่วงเวลาที่บริษัทกำหนด
- การพักเที่ยงมีความชัดเจน
  - ไม่สแกนพักเที่ยง → ระบบหักเวลาพัก 1 ชั่วโมงอัตโนมัติ
  - หรือสแกนพักเที่ยง **เป็นคู่** (ออกพักและกลับจากพัก)
- ข้อมูลครบถ้วน ชัดเจน และสามารถคำนวณเวลาทำงานได้โดยตรง

**สรุป:** พนักงานสแกนเข้างานและออกงานครบถ้วน มีข้อมูลพร้อมสำหรับการคำนวณ

<details>
<summary>กดเพื่อดูคำสัง SQL เคสเขียว</summary>

```sql
-- เคสเขียว
select day_case, lunch_case, night_case, count(*) as count
from vAttendance
where dateAt between '2025-01-01' and '2025-12-31' and
      morning is not null and
          (evening is not null || night is not null || early is not null)
group by day_case, lunch_case, night_case;
```

</details>

---

### 🟡 เคสเหลือง — ทำงานครึ่งวัน / ข้อมูลไม่ครบ

- มีการทำงานครึ่งวัน หรือ ข้อมูลไม่ครบถ้วน
  - เช้าอย่างเดียว หรือ บ่ายอย่างเดียว แต่มีการสแกนเที่ยง
- ไม่สามารถยืนยันการทำงานเต็มวันได้

**สรุป:** พนักงานทำงานครึ่งวัน จึงต้องตรวจสอบใบลา หรือสอบถามข้อมูลเพิ่มเติม

<details>
<summary>กดเพื่อดูคำสัง SQL เคสเหลือง</summary>

```sql
-- เคสเหลือง
select day_case, lunch_case, night_case, count(*) as count
from vAttendance
where dateAt between '2025-01-01' and '2025-12-31' and
    (
    (lunch_out is not null or lunch_in is not null)  and
    (morning is null xor  (evening is null and night is null and early is null))
    )
group by day_case, lunch_case, night_case;
```

</details>

---

### 🔴 เคสแดง — คำนวณยาก ต้องแก้ไขข้อมูล

- ข้อมูลการสแกนผิดปกติหรือไม่เป็นรูปแบบ
- มีสแกนเพียงช่วงเวลาเดียว หรือไมได้สแกนในช่วงเวลางาน
- ข้อมูลขาดหายหรือมีความคลุมเครือสูง

**สรุป:** ไม่สามารถนำข้อมูลไปคำนวณได้อย่างถูกต้อง จึงต้องมีการตรวจสอบและแก้ไขข้อมูลก่อนใช้งาน

<details>
<summary>กดเพื่อดูคำสัง SQL เคสแดง</summary>

```sql
-- เคสแดง
select day_case, lunch_case, night_case, count(*) as count
from vAttendance
where dateAt between '2025-01-01' and '2025-12-31' and
(
    lunch_out is null and lunch_in is null and
    (morning is null or  (evening is null and night is null and early is null)) or
    (morning is null && evening is null && night is null && early is null)
)
group by day_case, lunch_case, night_case;
```

</details>

---

### สรุปภาพรวม

- **เคสเขียว:** ทำงานปกติเต็มวัน ข้อมูลครบ คำนวณได้ทันที
- **เคสเหลือง:** ทำงานครึ่งวัน หรือสแกนเที่ยงครั้งเดียว
- **เคสแดง:** ข้อมูลผิดปกติ ต้องแก้ไขก่อนนำไปคำนวณ

---

## ตารางสุปภาพรวม

### 🟢 เคสเขียว — สามารถคำนวณได้เลย

|     NO. | day_case      | lunch_case       | night_case |      count |
| ------: | ------------- | ---------------- | ---------- | ---------: |
|     111 | 1.เช้า-เย็น   | 1.ไม่พักเที่ยง   | 1.ไม่มีค่ำ |     17,679 |
|     113 | 1.เช้า-เย็น   | 1.ไม่พักเที่ยง   | 3.ข้ามวัน  |          1 |
|     121 | 1.เช้า-เย็น   | 2.มีพักเที่ยง    | 1.ไม่มีค่ำ |     31,459 |
|     122 | 1.เช้า-เย็น   | 2.มีพักเที่ยง    | 2.ออกค่ำ   |          3 |
|     131 | 1.เช้า-เย็น   | 3.สแกนครั้งเดียว | 1.ไม่มีค่ำ |      7,147 |
|     132 | 1.เช้า-เย็น   | 3.สแกนครั้งเดียว | 2.ออกค่ำ   |          1 |
|     212 | 2.เช้าขาเดียว | 1.ไม่พักเที่ยง   | 2.ออกค่ำ   |        164 |
|     213 | 2.เช้าขาเดียว | 1.ไม่พักเที่ยง   | 3.ข้ามวัน  |          1 |
|     222 | 2.เช้าขาเดียว | 2.มีพักเที่ยง    | 2.ออกค่ำ   |         51 |
|     232 | 2.เช้าขาเดียว | 3.สแกนครั้งเดียว | 2.ออกค่ำ   |         11 |
| **รวม** |               |                  |            | **56,517** |

### 🟡 เคสเหลือง — รอสอบถามเพิ่มเติม / ใบลา

|     NO. | day_case      | lunch_case       | night_case |     count |
| ------: | ------------- | ---------------- | ---------- | --------: |
|     221 | 2.เช้าขาเดียว | 2.มีพักเที่ยง    | 1.ไม่มีค่ำ |       654 |
|     231 | 2.เช้าขาเดียว | 3.สแกนครั้งเดียว | 1.ไม่มีค่ำ |       822 |
|     321 | 3.เย็นขาเดียว | 2.มีพักเที่ยง    | 1.ไม่มีค่ำ |       237 |
|     331 | 3.เย็นขาเดียว | 3.สแกนครั้งเดียว | 1.ไม่มีค่ำ |       312 |
|     422 | 4.ไม่มี       | 2.มีพักเที่ยง    | 2.ออกค่ำ   |         3 |
| **รวม** |               |                  |            | **2,028** |

---

### 🔴 เคสแดง — รอแก้ไขข้อมูล

|     NO. | day_case      | lunch_case       | night_case |     count |
| ------: | ------------- | ---------------- | ---------- | --------: |
|     211 | 2.เช้าขาเดียว | 1.ไม่พักเที่ยง   | 1.ไม่มีค่ำ |     1,461 |
|     311 | 3.เย็นขาเดียว | 1.ไม่พักเที่ยง   | 1.ไม่มีค่ำ |       353 |
|     312 | 3.เย็นขาเดียว | 1.ไม่พักเที่ยง   | 2.ออกค่ำ   |         1 |
|     411 | 4.ไม่มี       | 1.ไม่พักเที่ยง   | 1.ไม่มีค่ำ |         2 |
|     412 | 4.ไม่มี       | 1.ไม่พักเที่ยง   | 2.ออกค่ำ   |         7 |
|     421 | 4.ไม่มี       | 2.มีพักเที่ยง    | 1.ไม่มีค่ำ |        37 |
|     431 | 4.ไม่มี       | 3.สแกนครั้งเดียว | 1.ไม่มีค่ำ |        26 |
| **รวม** |               |                  |            | **1,887** |

---

## 📊 สรุปรวมทั้งหมด

| สถานะ          |      จำนวน |
| -------------- | ---------: |
| เคสเขียว       |     56,517 |
| เคสเหลือง      |      2,028 |
| เคสแดง         |      1,887 |
| **รวมทั้งหมด** | **60,432** |

---

