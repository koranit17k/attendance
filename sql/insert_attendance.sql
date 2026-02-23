-- insert_attendance.sql
-- Insert ข้อมูลจาก vDailyTime เข้า table attendance
insert ignore into
    attendance (
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
select
    e.comCode,
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
from
    vDailyTime v
    join employee e on v.scanCode = e.scanCode
    -- WHERE v.dateAt >= CURDATE() - INTERVAL 2 month -- กำหนดช่วงวันที่ตามต้องการ
    -- truncate table attendance; -- ลบข้อมูลทั้งหมดในtable
