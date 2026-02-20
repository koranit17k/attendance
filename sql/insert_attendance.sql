-- insert_attendance.sql
-- Insert ข้อมูลจาก vDailyTime เข้า table attendance
INSERT IGNORE INTO attendance (
        comCode,
        empCode,
        dateAt,
        early,
        morning,
        lunch_out,
        lunch_in,
        evening,
        night,
        count,
        rawTime
    )
SELECT e.comCode,
    e.empCode,
    v.dateAt,
    v.early,
    v.morning,
    v.lunch_out,
    v.lunch_in,
    v.evening,
    v.night,
    v.count,
    v.rawTime
FROM vDailyTime v
    JOIN employee e ON v.scanCode = e.scanCode
-- WHERE v.dateAt >= CURDATE() - INTERVAL 2 month -- กำหนดช่วงวันที่ตามต้องการ
    -- truncate table attendance; -- ลบข้อมูลทั้งหมดในtable