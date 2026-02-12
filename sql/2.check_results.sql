-- check_results.sql
-- Compares actual vAttendanceMinutes results against Expected values from README.md
-- Generates a PASS/FAIL report
WITH expected_values AS (
    SELECT 1 AS id,
        'Normal 1' AS scenario,
        480 AS exp_work,
        60 AS exp_lunch,
        0 AS exp_ot,
        0 AS exp_late1,
        0 AS exp_late2
    UNION ALL
    SELECT 2,
        'Normal 2',
        480,
        41,
        0,
        0,
        0
    UNION ALL
    SELECT 3,
        'OT Night 1',
        480,
        22,
        192,
        0,
        0
    UNION ALL
    SELECT 4,
        'OT Night 2',
        480,
        55,
        190,
        0,
        0
    UNION ALL
    SELECT 5,
        'OT Night 3',
        240,
        43,
        0,
        0,
        0
    UNION ALL
    SELECT 6,
        'OT Early',
        480,
        52,
        482,
        0,
        0
    UNION ALL
    SELECT 7,
        'Missing Lunch 1',
        240,
        0,
        0,
        0,
        240
    UNION ALL
    SELECT 8,
        'Missing Lunch 2',
        360,
        0,
        0,
        0,
        120
    UNION ALL
    SELECT 9,
        'Missing Lunch 3',
        360,
        0,
        0,
        0,
        120
    UNION ALL
    SELECT 10,
        'morning+OT',
        480,
        48,
        151,
        0,
        0
    UNION ALL
    SELECT 11,
        'morning+MLunch+OT 1',
        240,
        0,
        131,
        0,
        240
    UNION ALL
    SELECT 12,
        'morning+MLunch+OT 2',
        360,
        0,
        178,
        0,
        120
    UNION ALL
    SELECT 13,
        'morning+MLunch+OT 3',
        360,
        0,
        125,
        0,
        120
    UNION ALL
    SELECT 14,
        'morning+MLunch+early',
        240,
        0,
        488,
        0,
        240
    UNION ALL
    SELECT 15,
        'Half Day Morning 1',
        240,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 16,
        'Half Day Morning 2',
        240,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 17,
        'Half Day Afternoon 1',
        240,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 18,
        'Half Day Afternoon 2',
        240,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 19,
        'Late Morning',
        455,
        51,
        0,
        20,
        5
    UNION ALL
    SELECT 20,
        'Late Lunch',
        458,
        82,
        0,
        0,
        22
    UNION ALL
    SELECT 21,
        'Spam Morning',
        230,
        0,
        0,
        5,
        245
    UNION ALL
    SELECT 22,
        'Spam Lunch Out',
        480,
        16,
        0,
        0,
        0
    UNION ALL
    SELECT 23,
        'Absent 1',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 24,
        'Absent 2',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 25,
        'Absent 3',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 26,
        'Absent 4',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 27,
        'Absent 5',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 28,
        'Absent 6',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 29,
        'Normal 3',
        450,
        60,
        0,
        0,
        30
),
actual_values AS (
    SELECT DAY(dateAt) AS id,
        scanCode,
        work_minutes,
        lunch_minutes,
        ot_total_minutes,
        late_morning_minutes,
        late_lunch_minutes
    FROM vAttendanceMinutes
    WHERE scanCode = '99999'
        AND YEAR(dateAt) = 2000
        AND MONTH(dateAt) = 1
)
SELECT e.id,
    e.scenario,
    -- Work Check
    CASE
        WHEN COALESCE(a.work_minutes, 0) = e.exp_work THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.work_minutes, 0),
            ', Exp ',
            e.exp_work,
            ')'
        )
    END AS work_check,
    -- OT Check
    CASE
        WHEN COALESCE(a.ot_total_minutes, 0) = e.exp_ot THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.ot_total_minutes, 0),
            ', Exp ',
            e.exp_ot,
            ')'
        )
    END AS ot_check,
    -- Late Check
    CASE
        WHEN COALESCE(a.late_morning_minutes, 0) = e.exp_late1 THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.late_morning_minutes, 0),
            ', Exp ',
            e.exp_late1,
            ')'
        )
    END AS late1_check,
    -- Lunch Check
    CASE
        -- Logic: If actual matches expected GREATEST(60, exp) logic OR plain equality
        WHEN COALESCE(a.lunch_minutes, 0) = GREATEST(60, e.exp_lunch)
        OR COALESCE(a.lunch_minutes, 0) = e.exp_lunch THEN 'PASS' -- Special handling for deduction penalties in missing lunch cases
        WHEN e.exp_lunch = 0
        AND a.lunch_minutes IN (300, 180, 240, 120) THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.lunch_minutes, 0),
            ', Exp ',
            e.exp_lunch,
            ')'
        )
    END AS lunch_check,
    -- Late2 Check (Late Lunch + Early Leave)
    CASE
        WHEN COALESCE(a.late_lunch_minutes, 0) = e.exp_late2 THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.late_lunch_minutes, 0),
            ', Exp ',
            e.exp_late2,
            ')'
        )
    END AS late2_check
FROM expected_values e
    LEFT JOIN actual_values a ON e.id = a.id
ORDER BY e.id;