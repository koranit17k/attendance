DROP EVENT IF EXISTS payroll.event_update_attendance_0630;
DELIMITER $$ CREATE EVENT payroll.event_update_attendance_0630 ON SCHEDULE EVERY 1 DAY STARTS TIMESTAMP(CURDATE() + INTERVAL 1 DAY, '06:30:00') DO BEGIN
UPDATE attendance AS t
    JOIN vAttendance AS v ON t.comCode = v.comCode
    AND t.empCode = v.empCode
    AND t.dateAt = v.dateAt
SET t.status = v.status,
    t.day_case = v.day_case,
    t.lunch_case = v.lunch_case,
    t.night_case = v.night_case,
    t.lunch_minutes = v.lunch_minutes,
    t.late_morning_minutes = v.late_morning_minutes,
    t.late_lunch_minutes = v.late_lunch_minutes,
    t.work_minutes = v.work_minutes,
    t.ot_total_minutes = v.ot_total_minutes,
    t.modified_at = NOW(),
    t.modified_by = 'system'
WHERE t.dateAt >= CURDATE() - INTERVAL 2 MONTH;
END $$ DELIMITER;