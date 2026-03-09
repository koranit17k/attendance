create event transferAttendance on SCHEDULE EVERY 1 DAY STARTS '2026-02-23 12:30:00.000' on COMPLETION PRESERVE ENABLE DO
begin declare v_date DATE;

set
    v_date = curdate() - interval 2 DAY;

call runTimeCard (v_date);

call runAttendance (v_date);

end;
