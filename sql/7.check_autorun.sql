-- ดูสิทธิ์ user event และเช็ค event ที่มีอยู่
-- ดูสิทธิ์
select
    USER (),
    current_user (),
    @@hostname;

show grants for current_user;

-- ให้สิทธิ์ ใน terminal ผ่าน root
sudo mysql
grant EVENT on *.* to 'koranit' @'%';

-- in terminal root , 
set
    GLOBAL event_scheduler = on;

-- in terminal root after grant event
-- เช็ค event_scheduler
show variables like 'event_scheduler';

-- เช็ค event ที่มีอยู่
show events
from
    payroll;

-- เช็ค event ว่าการทำงานเป้นอย่างไร
select
    EVENT_NAME,
    STATUS,
    STARTS,
    LAST_EXECUTED
from
    information_schema.EVENTS
where
    EVENT_SCHEMA = 'payroll'
    and EVENT_NAME = 'transferAttendance';

-- and run in antigravity (sql ที่อยู่ใน antigravity)
