-- payroll.vAttendanceMinutes source
create
or
replace
    ALGORITHM = UNDEFINED VIEW `vAttendanceMinutes` as
select
    a.status,
    e.comcode,
    e.name as employee_name,
    c.comName as company_name,
    a.scanCode,
    a.dateAt,
    a.day_case,
    a.lunch_case,
    a.night_case,
    a.early,
    a.morning,
    a.lunch_out,
    a.lunch_in,
    a.evening,
    a.night,
    -- Lunch Minutes (Deduction)
    case
        when a.status = '3' then 0 -- ถ้าเป็น 3(Red) แล้วหัก 0
        when a.lunch_case = '1.ไม่พักเที่ยง' then 300 -- ถ้าเป็น 1.ไม่พักเที่ยง แล้วหัก 300
        when a.lunch_case = '3.สแกนครั้งเดียว' then 180 -- ถ้าเป็น 3.สแกนครั้งเดียว แล้วหัก 180
        when a.lunch_out_min is not null
        and a.lunch_in_min is not null then greatest(60, a.lunch_in_min - a.lunch_out_min) -- เมื่อมีพักเที่ยงเลือกหักเวลาพัก 60 นาที หรือพักตามจริง (ถ้าพักน้อยกว่า60นาที ระบบบังคับหัก 60 นาที เพื่อคำนวนเวลาทำงานได้ง่าย และเป็นกฎบริษัท)
        else 60 -- ถ้าไม่มีพักเที่ยง หรือไม่เข้าเงื่อนไขไหน แล้วหัก 60
    end as lunch_minutes,
    -- Late Morning (Late1)
    case
        when a.status = '3' then 0 -- เมื่อ ... เป็นจริง ค่าจะ = 0
        when a.morning_min is not null
        and a.morning_min > 480 then a.morning_min - 480 -- เมื่อเข้าเช้ามากกว่า 480 นาที(8.00น) จะนำมาลบกับ 480 เพื่อคำนวนเวลาที่สาย
        else 0 -- ถาไม่เข้าเงื่อนไข(เช้า>480) ให้ = 0
    end as late_morning_minutes,
    -- Late Lunch / Early Departure (Late2)
    case
        when a.status = '3' then 0
        else (
            case
            -- แยกเป็นเคสเลยในการหา Late2
                when a.day_case = '1.เช้า-เย็น'
                and a.lunch_case = '1.ไม่พักเที่ยง' then 240 -- เมื่อ เช้า-เย็น และ ไม่พักเที่ยง ให้ late = 240
                when a.day_case = '1.เช้า-เย็น'
                and a.lunch_case = '3.สแกนครั้งเดียว' then 120 -- เมื่อ เช้า-เย็น และ สแกนครั้งเดียว ให้ late = 120
                when a.lunch_out_min is not null
                and a.lunch_in_min is not null
                and (a.lunch_in_min - a.lunch_out_min) > 60 then (a.lunch_in_min - a.lunch_out_min) - 60 -- เมื่อพักเที่ยงมากกว่า 60 นาที ให้แสดงค่าเวลา late(พักเที่ยง-60 เช่น(72-60 = 12 นาที))
                when a.day_case = '3.เย็นขาเดียว'
                and a.lunch_in_min > 780 then a.lunch_in_min - 780 -- คือสาย เมื่อเย็นขาเดียวและเข้างานหลัง 13.00 น. ให้แสดงค่าเวลา late(เข้างาน-780 เช่น เข้า 13.20(800-780 = 20 นาที))
                else 0 -- ถ้าไม่เข้าเงื่อนไขไหนให้ = 0 (พักปกติ,ถ้าไม่พักเกิน 60 นาทีหรือ ไม่เข้างานสาย )
            end
        ) + (
            case
                when a.night_min is null
                and a.early_min is null
                and (
                    a.day_case = '1.เช้า-เย็น'
                    or a.day_case = '3.เย็นขาเดียว' -- บอกกฎว่า ต้องมีเช้า-เย็น หรือ เย็นขาเดียว
                )
                and a.evening_min < 1020 then 1020 - a.evening_min -- คือสาย เมื่อ ออกก่อนเวลา17.00น.(1020นาที) คำนวนโดย (17.00(1020)-ออกงาน16.30(990) = 30 นาที)
                when a.day_case = '2.เช้าขาเดียว' then greatest(
                    0,
                    greatest(720, a.morning_min + 240) - a.lunch_out_min -- ** ครึ่งวันเช้า รอดูข้อมูล ว่า เข้างานออกงานเป้นอย่างไร ต้องเข้า 08.00 ออก 12.00 เพราะต้องใช้กฎเดียวกันห้ามเลื่อมล้ำเวลา (แต่ถ้าใช้โค้ดนี้เหมือนว่าเข้ากีโมงก็ได้ แต่ให้ครบ 4 ชม เช่น เข้า 9 ออกบ่าย โมง ซึ่งมันผิด)
                )
                else 0 -- ถ้าไม่สายหรืออกก่อนเวลา ก็ = 0 ใน late
            end
        )
    end as late_lunch_minutes,
    -- Work Minutes (Potential - Late1 - Late2)
    case
    -- แบ่งเคสคิด work minutes
        when a.status = '3'
        or a.day_case = '4.ไม่มี' then 0 -- ถ้าเคสคิดไม่ได้ขึ้น 0
        when a.day_case = '1.เช้า-เย็น' then greatest(
            0,
            -- ทำให้ค่าไม่ต่ำกว่า 0 (ไม่ติดลบ ซึ่งในความจริงไม่ควรมีอยู่แล้ว)
            480 - (
                -- เวลาไม่เกิน 480 นาที (480 = 8ชม)
                case
                -- late1
                    when a.morning_min is not null
                    and a.morning_min > 480 then a.morning_min - 480 -- คิด late ถ้าเข้าหลัง 8.00 ก็จะได้เวลาที่ late 
                    else 0 -- ถ้าไม่สาย ค่า = 0
                end
            ) - (
                -- คิด late จากข้างบน แล้วก็ค่อยมา - กับ เวลาทำงานข้างล่าง
                (
                    case
                        when a.day_case = '1.เช้า-เย็น'
                        and a.lunch_case = '1.ไม่พักเที่ยง' then 240 -- เข้าออกเช้าเย็น ไม่พักเที่ยงหัก 240
                        when a.day_case = '1.เช้า-เย็น'
                        and a.lunch_case = '3.สแกนครั้งเดียว' then 120 -- เข้าออกเช้าเย็น สแกนครั้งเดียวหัก 120
                        when a.lunch_out_min is not null
                        and a.lunch_in_min is not null
                        and (a.lunch_in_min - a.lunch_out_min) > 60 then (a.lunch_in_min - a.lunch_out_min) - 60 -- เมื่อมีพักเที่ยง>60 นาที ให้คำนวนlate พักเที่ยง (เวลาพักเที่ยง - 60 =เวลาที่late)
                        else 0 -- ถ้าไม่เข้าเคสไหนหรือพักเที่ยงไม่เกิน 60 นาที ค่า = 0
                    end
                ) + (
                    case
                        when a.night_min is null
                        and a.early_min is null
                        and (
                            a.day_case = '1.เช้า-เย็น' -- เช้าเย็นปกติ
                            or a.day_case = '3.เย็นขาเดียว' -- หรือเย็นขาเดียว
                        )
                        and a.evening_min < 1020 then 1020 - a.evening_min -- คิด late ถ้าออกก่อน 17.00 น. (1020นาที)
                        else 0 -- ถ้าไม่ออกก่อน 17.00 น. ค่า = 0 คือไม่lateนั้นแหละ
                    end
                )
            )
        )
        when a.day_case = '2.เช้าขาเดียว' then greatest(
            -- ทำงานครึ่งวันเช้า (ไม่มีเย็น)
            0,
            -- ทำให้ค่าไม่ต่ำกว่า 0 (ไม่ติดลบ ซึ่งในความจริงไม่ควรมีอยู่แล้ว)
            240 - (
                -- จำกัดเวลาที่แสดงไม่เกิน 240 นาที หรือ 4ชม ครึ่งวันพอดี
                case
                    when a.morning_min is not null
                    and a.morning_min > 480 then a.morning_min - 480 -- คิดlateเช้าหากเข้าหลัง 8 โมง(a.morning_min > 480)
                    else 0 -- ถ้าเข้าก่อน 8 โมง,ไม่ late ค่า = 0
                end
            ) - (
                greatest(
                    0,
                    -- ไม่ต่ำกว่า 0
                    greatest(720, a.morning_min + 240) - a.lunch_out_min -- 720 คือ 12.00 คิดเวลาทำงานถึงเที่ยง 4 ชม (ทำงานหลังเวลา 12.00 ไม่คิดเวลาทำงาน) 
                ) -- - a.lunch_out_min ไว้คำนวน ออกก่อน หรือ late ถ้าหาก - กันไม่ลง 0 พอดี เช่นเข้า 8.01(481) ออก 12.00(720) ตามสูตร (481+240)720=1
            )
        )
        when a.day_case = '3.เย็นขาเดียว' then greatest(
            0,
            240 - (
                case
                    when a.lunch_in_min is not null
                    and a.lunch_in_min > 780 then a.lunch_in_min - 780
                    else 0
                end
            ) - (
                case
                    when a.night_min is null
                    and a.early_min is null
                    and (
                        a.day_case = '1.เช้า-เย็น'
                        or a.day_case = '3.เย็นขาเดียว'
                    )
                    and a.evening_min < 1020 then 1020 - a.evening_min
                    else 0
                end
            )
        )
        else 0
    end as work_minutes,
    -- OT Total Minutes
    case
        when a.status = '3'
        or a.day_case = '4.ไม่มี' then 0
        when a.morning_min is not null
        and (
            a.night_min is not null
            or a.early_min is not null
        ) then case
            when a.early_min is not null then 360 + a.early_min
            when a.night_min is not null
            and a.night_min > 1080 then a.night_min - 1080
            else 0
        end
        else 0
    end as ot_total_minutes
from
    vAttendance a
    left join employee e on a.scanCode = e.scanCode
    left join company c on e.comCode = c.comCode;
