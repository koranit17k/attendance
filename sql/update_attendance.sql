-- อัพเดทค่าที่คำนวณได้จาก vAttendance กลับเข้า table attendance
	UPDATE attendance t
    JOIN vAttendance v ON t.comCode = v.comCode
    AND t.empCode = v.empCode
    AND t.dateAt = v.dateAt
SET
    t.status = v.status,
    t.lunch_minutes = v.lunchMin,
    t.late_morning_minutes = v.lateMin1,
    t.late_lunch_minutes = v.lateMin2,
    t.work_minutes = v.workMin,
    t.ot_total_minutes = v.otMin,
    t.modified_at = NOW(),
    t.modified_by = 'system'
WHERE t.status_check <> 'APPROVED'
    AND t.dateAt >= p_start;
    -- WHERE t.dateAt >= '2025-12-01'
    -- >= CURDATE() - INTERVAL 2 MONTH;
    -- กำหนดช่วงวันที่ตามต้องการ
