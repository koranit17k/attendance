ls /home/koranit/kxreport/report/payroll  #เช็คว่ามีไฟล์ payroll ไหม 
mkdir -p /home/koranit/kxreport/report/payroll #ถ้าไม่มีให้สร้างไฟล์ payroll
find /home/koranit/attendance/report -type f -name "*.jasper" -exec cp -t /home/koranit/kxreport/report/payroll {} + #คัดลอกไฟล์ payroll ไปยังโฟลเดอร์ payroll

