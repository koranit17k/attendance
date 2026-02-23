drop procedure if exists payroll.runTimeCard;

-- insert attendance
DELIMITER $$$$
create procedure payroll.runTimeCard (in p_start DATE)
begin
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

end $$ DELIMITER;

drop procedure if exists payroll.runAttendance;

--update attendance
DELIMITER $$$$
create procedure payroll.runAttendance (in p_start DATE)
begin
update attendance t
join vAttendance v on t.comCode = v.comCode
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
where
    t.status_check <> 'APPROVED'
    and t.dateAt >= p_start;

end $$ DELIMITER;
