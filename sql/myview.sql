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
        -- 1. No Lunch Scan: Deduct 240 mins (4 hours)
        WHEN a.lunch_case = '1.ไม่พักเที่ยง' THEN 240 -- 3. Single Lunch Scan: Deduct 120 mins (2 hours)
        WHEN a.lunch_case = '3.สแกนครั้งเดียว' THEN 120 -- Normal Case: Deduct actual duration (min 60 mins)
        WHEN a.lunch_out IS NOT NULL
        AND a.lunch_in IS NOT NULL THEN GREATEST(
            60,
            TIME_TO_SEC(TIMEDIFF(a.lunch_in, a.lunch_out)) / 60
        ) -- Fallback
        ELSE 60
    END AS lunch_minutes,
    -- Late Morning
    CASE
        WHEN a.morning IS NOT NULL
        AND a.morning > '08:00:00' THEN TIME_TO_SEC(TIMEDIFF(a.morning, '08:00:00')) / 60
        ELSE 0
    END AS late_morning_minutes,
    -- Late Lunch
    CASE
        WHEN a.lunch_out IS NOT NULL
        AND a.lunch_in IS NOT NULL
        AND (
            TIME_TO_SEC(TIMEDIFF(a.lunch_in, a.lunch_out)) / 60
        ) > 60 THEN (
            TIME_TO_SEC(TIMEDIFF(a.lunch_in, a.lunch_out)) / 60
        ) - 60
        ELSE 0
    END AS late_lunch_minutes,
    -- Work Minutes
    CASE
        -- Case 1: Full Day (Morning - Evening/Night)
        WHEN a.day_case = '1.เช้า-เย็น' THEN GREATEST(
            0,
            (
                TIME_TO_SEC(
                    TIMEDIFF(
                        -- End Time (Capped at 17:00)
                        LEAST(
                            COALESCE(a.evening, a.night, a.early, '17:00:00'),
                            '17:00:00'
                        ),
                        -- Start Time (Capped at 08:00)
                        GREATEST(a.morning, '08:00:00')
                    )
                ) / 60
            ) - -- Subtract Lunch Deduction
            (
                CASE
                    WHEN a.lunch_case = '1.ไม่พักเที่ยง' THEN 240
                    WHEN a.lunch_case = '3.สแกนครั้งเดียว' THEN 120
                    WHEN a.lunch_out IS NOT NULL
                    AND a.lunch_in IS NOT NULL THEN GREATEST(
                        60,
                        TIME_TO_SEC(TIMEDIFF(a.lunch_in, a.lunch_out)) / 60
                    )
                    ELSE 60
                END
            )
        ) -- Case 2: Morning Only
        WHEN a.day_case = '2.เช้าขาเดียว' THEN CASE
            WHEN a.lunch_out IS NOT NULL THEN LEAST(
                240,
                GREATEST(
                    0,
                    TIME_TO_SEC(
                        TIMEDIFF(a.lunch_out, GREATEST(a.morning, '08:00:00'))
                    ) / 60
                )
            )
            ELSE 0
        END -- Case 3: Evening Only
        WHEN a.day_case = '3.เย็นขาเดียว' THEN CASE
            WHEN a.lunch_in IS NOT NULL THEN LEAST(
                240,
                GREATEST(
                    0,
                    TIME_TO_SEC(TIMEDIFF('17:00:00', a.lunch_in)) / 60
                )
            )
            WHEN a.lunch_out IS NOT NULL THEN -- Fallback if only lunch_out exists (though usually implies morning work?)
            -- existing logic looked for lunch_in/out
            LEAST(
                240,
                GREATEST(
                    0,
                    TIME_TO_SEC(TIMEDIFF('17:00:00', a.lunch_out)) / 60
                )
            )
            ELSE 0
        END
        ELSE 0
    END AS work_minutes,
    -- OT Total Minutes
    CASE
        -- Only count OT if worked in the morning and stayed late (Night or Early)
        WHEN a.morning IS NOT NULL
        AND (
            a.night IS NOT NULL
            OR a.early IS NOT NULL
        ) THEN CASE
            -- Early (Next Day 00:00-06:00): Full 6 hours (18-24) + Early Time
            WHEN a.early IS NOT NULL THEN 360 + (TIME_TO_SEC(a.early) / 60) -- Night (19:00+): Time after 18:00 (17:00-18:00 is break)
            WHEN a.night IS NOT NULL
            AND a.night > '18:00:00' THEN TIME_TO_SEC(TIMEDIFF(a.night, '18:00:00')) / 60
            ELSE 0
        END
        ELSE 0
    END AS ot_total_minutes
from vAttendance a
--     left join employee e on a.scanCode = e.scanCode
--     left join company c on e.comCode = c.comCode;
    left join scancode e on a.scanCode = e.scanCode
    left join company c on e.comCode = c.comCode;
