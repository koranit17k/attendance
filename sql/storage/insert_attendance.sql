-- insert_attendance.sql
-- Insert ข้อมูลจาก vDailyTime เข้า table attendance
	insert ignore into
    attendance (comCode, empCode, dateAt, early, morning, lunch_out, lunch_in, evening, night, count, rawTime)
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
where
    v.dateAt >= p_start;

-- Insert ข้อมูลวันหยุด ที่พนักงานไม่ได้มาทำงาน 
INSERT IGNORE INTO attendance (
        comCode, 
        empCode, 
        dateAt, 
        status,
        modified_by ,
        modified_at
    )
WITH RECURSIVE dates AS (
    SELECT p_start AS dateAt
    UNION ALL
    SELECT dateAt + INTERVAL 1 DAY
    FROM dates
    WHERE dateAt < CURDATE() 
)
SELECT e.comCode,e.empCode ,dateAt,"Absent" ,"system",now()
FROM dates
join employee e 
left join holiday h on e.comCode = h.comCode and dates.dateAt = h.`day` 
where DAYOFWEEK(dateAt) <> 1 and e.timeCode is not null and e.endDate is null and day is null;
    -- truncate table attendance; -- ลบข้อมูลทั้งหมดในtable
