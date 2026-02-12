-- payroll.vAttendanceMinutes source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vAttendanceMinutes` AS
SELECT a.status,
    e.comcode,
    e.name AS employee_name,
    c.comName AS company_name,
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
        WHEN a.status = '3' THEN 0
        WHEN a.lunch_case = '1.ไม่พักเที่ยง' THEN 300
        WHEN a.lunch_case = '3.สแกนครั้งเดียว' THEN 180
        WHEN a.lunch_out_min IS NOT NULL
        AND a.lunch_in_min IS NOT NULL THEN GREATEST(60, a.lunch_in_min - a.lunch_out_min)
        ELSE 60
    END AS lunch_minutes,
    -- Late Morning (Late1)
    CASE
        WHEN a.status = '3' THEN 0
        WHEN a.morning_min IS NOT NULL
        AND a.morning_min > 480 THEN a.morning_min - 480
        ELSE 0
    END AS late_morning_minutes,
    -- Late Lunch / Early Departure (Late2)
    CASE
        WHEN a.status = '3' THEN 0
        ELSE (
            CASE
                WHEN a.day_case = '1.เช้า-เย็น'
                AND a.lunch_case = '1.ไม่พักเที่ยง' THEN 240
                WHEN a.day_case = '1.เช้า-เย็น'
                AND a.lunch_case = '3.สแกนครั้งเดียว' THEN 120
                WHEN a.lunch_out_min IS NOT NULL
                AND a.lunch_in_min IS NOT NULL
                AND (a.lunch_in_min - a.lunch_out_min) > 60 THEN (a.lunch_in_min - a.lunch_out_min) - 60
                WHEN a.day_case = '3.เย็นขาเดียว'
                AND a.lunch_in_min > 780 THEN a.lunch_in_min - 780
                ELSE 0
            END
        ) + (
            CASE
                WHEN a.night_min IS NULL
                AND a.early_min IS NULL
                AND (
                    a.day_case = '1.เช้า-เย็น'
                    OR a.day_case = '3.เย็นขาเดียว'
                )
                AND a.evening_min < 1020 THEN 1020 - a.evening_min
                WHEN a.day_case = '2.เช้าขาเดียว' THEN GREATEST(
                    0,
                    GREATEST(720, a.morning_min + 240) - a.lunch_out_min
                )
                ELSE 0
            END
        )
    END AS late_lunch_minutes,
    -- Work Minutes (Potential - Late1 - Late2)
    CASE
        WHEN a.status = '3'
        OR a.day_case = '4.ไม่มี' THEN 0
        WHEN a.day_case = '1.เช้า-เย็น' THEN GREATEST(
            0,
            480 - (
                CASE
                    WHEN a.morning_min IS NOT NULL
                    AND a.morning_min > 480 THEN a.morning_min - 480
                    ELSE 0
                END
            ) - (
                (
                    CASE
                        WHEN a.day_case = '1.เช้า-เย็น'
                        AND a.lunch_case = '1.ไม่พักเที่ยง' THEN 240
                        WHEN a.day_case = '1.เช้า-เย็น'
                        AND a.lunch_case = '3.สแกนครั้งเดียว' THEN 120
                        WHEN a.lunch_out_min IS NOT NULL
                        AND a.lunch_in_min IS NOT NULL
                        AND (a.lunch_in_min - a.lunch_out_min) > 60 THEN (a.lunch_in_min - a.lunch_out_min) - 60
                        ELSE 0
                    END
                ) + (
                    CASE
                        WHEN a.night_min IS NULL
                        AND a.early_min IS NULL
                        AND (
                            a.day_case = '1.เช้า-เย็น'
                            OR a.day_case = '3.เย็นขาเดียว'
                        )
                        AND a.evening_min < 1020 THEN 1020 - a.evening_min
                        ELSE 0
                    END
                )
            )
        )
        WHEN a.day_case = '2.เช้าขาเดียว' THEN GREATEST(
            0,
            240 - (
                CASE
                    WHEN a.morning_min IS NOT NULL
                    AND a.morning_min > 480 THEN a.morning_min - 480
                    ELSE 0
                END
            ) - (
                GREATEST(
                    0,
                    GREATEST(720, a.morning_min + 240) - a.lunch_out_min
                )
            )
        )
        WHEN a.day_case = '3.เย็นขาเดียว' THEN GREATEST(
            0,
            240 - (
                CASE
                    WHEN a.lunch_in_min IS NOT NULL
                    AND a.lunch_in_min > 780 THEN a.lunch_in_min - 780
                    ELSE 0
                END
            ) - (
                CASE
                    WHEN a.night_min IS NULL
                    AND a.early_min IS NULL
                    AND (
                        a.day_case = '1.เช้า-เย็น'
                        OR a.day_case = '3.เย็นขาเดียว'
                    )
                    AND a.evening_min < 1020 THEN 1020 - a.evening_min
                    ELSE 0
                END
            )
        )
        ELSE 0
    END AS work_minutes,
    -- OT Total Minutes
    CASE
        WHEN a.status = '3'
        OR a.day_case = '4.ไม่มี' THEN 0
        WHEN a.morning_min IS NOT NULL
        AND (
            a.night_min IS NOT NULL
            OR a.early_min IS NOT NULL
        ) THEN CASE
            WHEN a.early_min IS NOT NULL THEN 360 + a.early_min
            WHEN a.night_min IS NOT NULL
            AND a.night_min > 1080 THEN a.night_min - 1080
            ELSE 0
        END
        ELSE 0
    END AS ot_total_minutes
FROM vAttendance a
    LEFT JOIN employee e ON a.scanCode = e.scanCode
    LEFT JOIN company c ON e.comCode = c.comCode;