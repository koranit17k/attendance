-- check_results.sql
WITH expected_values AS (
    SELECT 1 AS id,
        'Normal 1' AS scenario,
        'Full' AS status,
        480 AS exp_work,
        60 AS exp_lunch,
        0 AS exp_ot,
        0 AS exp_late1,
        0 AS exp_late2
    UNION ALL
    SELECT 2,
        'Normal 2',
        'Full',
        480,
        41,
        0,
        0,
        0
    UNION ALL
    SELECT 3,
        'Normal 3',
        'Full',
        450,
        40,
        0,
        0,
        30
    UNION ALL
    SELECT 4,
        'OT Night 1',
        'Full+OT',
        480,
        22,
        192,
        0,
        0
    UNION ALL
    SELECT 5,
        'OT Night 2',
        'Full+OT',
        480,
        55,
        190,
        0,
        0
    UNION ALL
    SELECT 6,
        'OT Night 3',
        'Half+OT',
        240,
        43,
        0,
        0,
        0
    UNION ALL
    SELECT 7,
        'OT Early',
        'Full+OT',
        480,
        52,
        482,
        0,
        0
    UNION ALL
    SELECT 8,
        'Missing Lunch 1',
        'Full',
        240,
        0,
        0,
        0,
        240
    UNION ALL
    SELECT 9,
        'Missing Lunch 2',
        'Full',
        360,
        0,
        0,
        0,
        120
    UNION ALL
    SELECT 10,
        'Missing Lunch 3',
        'Full',
        360,
        0,
        0,
        0,
        120
    UNION ALL
    SELECT 11,
        'morning+OT',
        'Full',
        480,
        48,
        151,
        0,
        0
    UNION ALL
    SELECT 12,
        'morning+MLunch+OT 1',
        'Full+OT',
        240,
        0,
        131,
        0,
        240
    UNION ALL
    SELECT 13,
        'morning+MLunch+OT 2',
        'Full+OT',
        360,
        0,
        178,
        0,
        120
    UNION ALL
    SELECT 14,
        'morning+MLunch+OT 3',
        'Full+OT',
        360,
        0,
        125,
        0,
        120
    UNION ALL
    SELECT 15,
        'morning+MLunch+early',
        'Full',
        240,
        0,
        488,
        0,
        240
    UNION ALL
    SELECT 16,
        'Half Day Morning 1',
        'Half',
        225,
        0,
        0,
        0,
        15
    UNION ALL
    SELECT 17,
        'Half Day Morning 2',
        'Half',
        240,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 18,
        'Half Day Afternoon 1',
        'Half',
        230,
        0,
        0,
        0,
        10
    UNION ALL
    SELECT 19,
        'Half Day Afternoon 2',
        'Half',
        230,
        0,
        0,
        0,
        10
    UNION ALL
    SELECT 20,
        'Late Morning',
        'Full',
        455,
        51,
        0,
        20,
        5
    UNION ALL
    SELECT 21,
        'Late Morning Half',
        'Half',
        200,
        0,
        0,
        30,
        10
    UNION ALL
    SELECT 22,
        'Late Lunch',
        'Full',
        458,
        82,
        0,
        0,
        22
    UNION ALL
    SELECT 23,
        'Spam Morning',
        'Full',
        230,
        0,
        0,
        5,
        245
    UNION ALL
    SELECT 24,
        'Spam Lunch Out',
        'Full',
        480,
        16,
        0,
        0,
        0
    UNION ALL
    SELECT 25,
        'Absent 1',
        'Absent',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 26,
        'Absent 2',
        'Absent',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 27,
        'Absent 3',
        'Absent',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 28,
        'Absent 4',
        'Absent',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 29,
        'Absent 5',
        'Absent',
        0,
        0,
        0,
        0,
        0
    UNION ALL
    SELECT 30,
        'Absent 6',
        'Absent',
        0,
        0,
        0,
        0,
        0
),
actual_values AS (
    SELECT DAY(dateAt) AS id,
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
    -- Late1 Check
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
    -- Late2 Check
    CASE
        WHEN COALESCE(a.late_lunch_minutes, 0) = e.exp_late2 THEN 'PASS'
        ELSE CONCAT(
            'FAIL (Got ',
            COALESCE(a.late_lunch_minutes, 0),
            ', Exp ',
            e.exp_late2,
            ')'
        )
    END AS late2_check,
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
    END AS ot_check
FROM expected_values e
    LEFT JOIN actual_values a ON e.id = a.id
ORDER BY e.id;