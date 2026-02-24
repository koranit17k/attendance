DROP PROCEDURE IF EXISTS payroll.runTimeCard;

DELIMITER $$
$$
CREATE PROCEDURE payroll.runTimeCard(in p_start DATE)
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

END
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS payroll.runAttendance;

DELIMITER $$
$$
CREATE DEFINER=`koranit`@`%` PROCEDURE `payroll`.`runAttendance`(
	IN p_start DATE)
BEGIN
	UPDATE attendance t
    JOIN vAttendance v ON t.comCode = v.comCode
    AND t.empCode = v.empCode
    AND t.dateAt = v.dateAt
SET t.lunch_minutes = v.lunchMin,
    t.late_morning_minutes = v.lateMin1,
    t.late_lunch_minutes = v.lateMin2,
    t.work_minutes = v.workMin,
    t.ot_total_minutes = v.otMin,
    t.modified_at = NOW(),
    t.modified_by = 'system'
WHERE t.status_check <> 'APPROVED'
    AND t.dateAt >= p_start;

END
$$
DELIMITER ;

