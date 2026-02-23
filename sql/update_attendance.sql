-- อัพเดทค่าที่คำนวณได้จาก vAttendance กลับเข้า table attendance
update attendance as t
join vAttendance as v on t.comCode = v.comCode
and t.empCode = v.empCode
and t.dateAt = v.dateAt
set
    t.status = v.status,
    t.day_case = v.day_case,
    t.lunch_case = v.lunch_case,
    t.night_case = v.night_case,
    t.lunch_minutes = v.lunch_minutes,
    t.late_morning_minutes = v.late_morning_minutes,
    t.late_lunch_minutes = v.late_lunch_minutes,
    t.work_minutes = v.work_minutes,
    t.ot_total_minutes = v.ot_total_minutes,
    t.modified_at = now(),
    t.modified_by = 'system'
    -- WHERE t.dateAt >= '2025-12-01'
    -- >= CURDATE() - INTERVAL 2 MONTH;
    -- กำหนดช่วงวันที่ตามต้องการ
