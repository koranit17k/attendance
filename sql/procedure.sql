DROP PROCEDURE IF EXISTS payroll.runTimeCard;

DELIMITER $$
$$
CREATE DEFINER=`koranit`@`%` PROCEDURE `payroll`.`runTimeCard`(in p_start DATE)
BEGIN
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


UPDATE employee e
SET e.timeCode = NULL
WHERE e.timeCode IS NOT NULL
  AND e.endDate IS NULL
  AND NOT EXISTS (
        SELECT 1
        FROM attendance a
        WHERE a.comCode = e.comCode
          AND a.empCode = e.empCode
          AND a.dateAt >= '2025-01-01'
          AND a.dateAt < CURDATE() + INTERVAL 1 DAY
  );


INSERT IGNORE INTO attendance (
        comCode, 
        empCode, 
        dateAt, 
        status,
        modified_by ,
        modified_at
    )
WITH RECURSIVE dates AS (
    SELECT '2025-01-01' AS dateAt
    UNION ALL
    SELECT dateAt + INTERVAL 1 DAY
    FROM dates
    WHERE dateAt < CURDATE() 
)
SELECT e.comCode,e.empCode ,dateAt,"Absent" ,"system",now()
FROM dates
join employee e  
where DAYOFWEEK(dateAt) <> 1 and e.timeCode is not null and e.endDate is null;
END$$
DELIMITER ;



DELIMITER $$
$$
CREATE DEFINER=`koranit`@`%` PROCEDURE `payroll`.`runAttendance`(
	IN p_start DATE)
BEGIN
	UPDATE attendance t
    JOIN vAttendance v ON t.comCode = v.comCode
    AND t.empCode = v.empCode
    AND t.dateAt = v.dateAt
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
    
END$$
DELIMITER ;


