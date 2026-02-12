-- payroll.vAttendanceMinutes source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vAttendanceMinutes` AS
select a.status,
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
    CASE
        -- 1. No Lunch Scan: Deduct 300 mins (1h break + 4h penalty)
        WHEN a.lunch_case = '1.ไม่พักเที่ยง' THEN 300 -- 3. Single Lunch Scan: Deduct 180 mins (1h break + 2h penalty)
        WHEN a.lunch_case = '3.สแกนครั้งเดียว' THEN 180 -- Normal Case: Deduct actual duration (min 60 mins)
        WHEN a.lunch_out_min IS NOT NULL
        AND a.lunch_in_min IS NOT NULL THEN GREATEST(
            60,
            a.lunch_in_min - a.lunch_out_min
        ) -- Fallback
        ELSE 60
    END AS lunch_minutes,
    -- Late Morning
    CASE
        WHEN a.morning_min IS NOT NULL
        AND a.morning_min > 480 THEN a.morning_min - 480 -- 480 = 08:00
        ELSE 0
    END AS late_morning_minutes,
    -- Late Lunch
    (
        CASE
            WHEN a.day_case = '1.เช้า-เย็น'
            AND a.lunch_case = '1.ไม่พักเที่ยง' THEN 240
            WHEN a.day_case = '1.เช้า-เย็น'
            AND a.lunch_case = '3.สแกนครั้งเดียว' THEN 120
            WHEN a.lunch_out_min IS NOT NULL
            AND a.lunch_in_min IS NOT NULL
            AND (
                a.lunch_in_min - a.lunch_out_min
            ) > 60 THEN (
                a.lunch_in_min - a.lunch_out_min
            ) - 60
            ELSE 0
        END
    ) + (
        CASE
            -- Only if NOT Night shift and NOT Early shift (leaving next morning)
            WHEN a.night_min IS NULL
            AND a.early_min IS NULL
            AND (
                a.day_case = '1.เช้า-เย็น'
                OR a.day_case = '3.เย็นขาเดียว'
            )
            AND a.evening_min < 1020 THEN 1020 - a.evening_min -- 1020 = 17:00
            ELSE 0
        END
    ) AS late_lunch_minutes,
    -- Work Minutes
    CASE
        -- Case 1: Full Day (Morning - Evening/Night)
        WHEN a.day_case = '1.เช้า-เย็น' THEN GREATEST(
            0,
            (
                -- End Time (Capped at 17:00 = 1020)
                LEAST(
                    COALESCE(a.evening_min, a.night_min, 1020),
                    1020
                ) - -- Start Time (Capped at 08:00 = 480)
                GREATEST(COALESCE(a.morning_min, 480), 480)
            ) - -- Subtract Lunch Deduction
            (
                CASE
                    WHEN a.lunch_case = '1.ไม่พักเที่ยง' THEN 300
                    WHEN a.lunch_case = '3.สแกนครั้งเดียว' THEN 180
                    WHEN a.lunch_out_min IS NOT NULL
                    AND a.lunch_in_min IS NOT NULL THEN GREATEST(
                        60,
                        a.lunch_in_min - a.lunch_out_min
                    )
                    ELSE 60
                END
            )
        ) -- Case 2: Morning Only
        WHEN a.day_case = '2.เช้าขาเดียว' THEN CASE
            WHEN a.lunch_out_min IS NOT NULL THEN LEAST(
                240,
                a.lunch_out_min - GREATEST(a.morning_min, 480)
            )
            ELSE 0
        END -- Case 3: Evening Only
        WHEN a.day_case = '3.เย็นขาเดียว' THEN CASE
            WHEN a.lunch_in_min IS NOT NULL THEN LEAST(
                240,
                1020 - a.lunch_in_min -- 1020 = 17:00
            )
            WHEN a.lunch_out_min IS NOT NULL THEN -- Fallback
            LEAST(
                240,
                1020 - a.lunch_out_min
            )
            ELSE 0
        END
        ELSE 0
    END AS work_minutes,
    -- OT Total Minutes
    CASE
        -- Only count OT if worked in the morning and stayed late (Night or Early)
        WHEN a.morning_min IS NOT NULL
        AND (
            a.night_min IS NOT NULL
            OR a.early_min IS NOT NULL
        ) THEN CASE
            -- Early (Next Day 00:00-06:00): Full 6 hours (18-24) + Early Time
            WHEN a.early_min IS NOT NULL THEN 360 + a.early_min -- Night (19:00+): Time after 18:00 (1080)
            WHEN a.night_min IS NOT NULL
            AND a.night_min > 1080 THEN a.night_min - 1080
            ELSE 0
        END
        ELSE 0
    END AS ot_total_minutes
from vAttendance a
    left join employee e on a.scanCode = e.scanCode
    left join company c on e.comCode = c.comCode;