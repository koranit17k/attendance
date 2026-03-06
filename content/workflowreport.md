ทดสอบการใช้งานระบบ การนำ report ไปใช้งาน

1. clone or fork repository จาก https://github.com/swasin185/kxreport.git
2. หลังจากที่สร้างรายงานเสร็จจากไฟล์ .jrxml แล้ว compile ไฟล์ .jrxml ให้เป็นไฟล์ .jasper 
3. รัน script install.sh เพื่อ install program ที่ใช้ในการแสดง report
4. รัน script build.sh เพื่อสร้างโครสร้าง
5. ทดสอบเทสผ่าน api  http://localhost:8080/kxreport/
6. รัน script mem.sh หรือ stress.sh เพื่อทดสอบการใช้ ram
7. รัน script copyreport.sh เพื่อคัดลอกไฟล์ .jasper ไปยังโฟลเดอร์ payroll
8. ทดลองใช้ระบบผ่าน api http://localhost:8080/kxreport/getPDF?report=A02&db=payroll&startDate=2025-12-01&endDate=2025-12-31&&comCode=01


Note*
- สามารถทดสอบระบบ จากข้อที่ 5 โดนผ่าน parameter ในเว็บได้เลย ผ่าน url ตัวอย่างเช่น
http://localhost:8080/kxreport/getPDF?report=A02&db=payroll&startDate=2025-12-01&endDate=2025-12-31&&comCode=01 