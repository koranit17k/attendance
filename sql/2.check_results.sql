-- check_results.sql
with
    expected_values as (
        select
            1 as id,
            'Normal 1' as scenario,
            'Full' as status,
            480 as exp_work,
            60 as exp_lunch,
            0 as exp_ot,
            0 as exp_late1,
            0 as exp_late2
        union all
        select
            2,
            'Normal 2',
            'Full',
            480,
            41,
            0,
            0,
            0
        union all
        select
            3,
            'Normal 3',
            'Full',
            450,
            40,
            0,
            0,
            30
        union all
        select
            4,
            'OT Night 1',
            'Full+OT',
            480,
            22,
            192,
            0,
            0
        union all
        select
            5,
            'OT Night 2',
            'Full+OT',
            480,
            55,
            190,
            0,
            0
        union all
        select
            6,
            'OT Night 3',
            'Half+OT',
            240,
            43,
            0,
            0,
            0
        union all
        select
            7,
            'OT Early',
            'Full+OT',
            480,
            52,
            482,
            0,
            0
        union all
        select
            8,
            'Missing Lunch 1',
            'Full',
            240,
            0,
            0,
            0,
            240
        union all
        select
            9,
            'Missing Lunch 2',
            'Full',
            360,
            0,
            0,
            0,
            120
        union all
        select
            10,
            'Missing Lunch 3',
            'Full',
            360,
            0,
            0,
            0,
            120
        union all
        select
            11,
            'morning+OT',
            'Full',
            480,
            48,
            151,
            0,
            0
        union all
        select
            12,
            'morning+MLunch+OT 1',
            'Full+OT',
            240,
            0,
            131,
            0,
            240
        union all
        select
            13,
            'morning+MLunch+OT 2',
            'Full+OT',
            360,
            0,
            178,
            0,
            120
        union all
        select
            14,
            'morning+MLunch+OT 3',
            'Full+OT',
            360,
            0,
            125,
            0,
            120
        union all
        select
            15,
            'morning+MLunch+early',
            'Full',
            240,
            0,
            488,
            0,
            240
        union all
        select
            16,
            'Half Day Morning 1',
            'Half',
            225,
            0,
            0,
            0,
            15
        union all
        select
            17,
            'Half Day Morning 2',
            'Half',
            240,
            0,
            0,
            0,
            0
        union all
        select
            18,
            'Half Day Afternoon 1',
            'Half',
            230,
            0,
            0,
            0,
            10
        union all
        select
            19,
            'Half Day Afternoon 2',
            'Half',
            230,
            0,
            0,
            0,
            10
        union all
        select
            20,
            'Late Morning',
            'Full',
            455,
            51,
            0,
            20,
            5
        union all
        select
            21,
            'Late Morning Half',
            'Half',
            200,
            0,
            0,
            30,
            10
        union all
        select
            22,
            'Late Lunch',
            'Full',
            458,
            82,
            0,
            0,
            22
        union all
        select
            23,
            'Spam Morning',
            'Full',
            230,
            0,
            0,
            5,
            245
        union all
        select
            24,
            'Spam Lunch Out',
            'Full',
            480,
            16,
            0,
            0,
            0
        union all
        select
            25,
            'Absent 1',
            'Absent',
            0,
            0,
            0,
            0,
            0
        union all
        select
            26,
            'Absent 2',
            'Absent',
            0,
            0,
            0,
            0,
            0
        union all
        select
            27,
            'Absent 3',
            'Absent',
            0,
            0,
            0,
            0,
            0
        union all
        select
            28,
            'Absent 4',
            'Absent',
            0,
            0,
            0,
            0,
            0
        union all
        select
            29,
            'Absent 5',
            'Absent',
            0,
            0,
            0,
            0,
            0
        union all
        select
            30,
            'Absent 6',
            'Absent',
            0,
            0,
            0,
            0,
            0
    ),
    actual_values as (
        select
            DAY (a.dateAt) as id,
            a.work_minutes,
            a.lunch_minutes,
            a.ot_total_minutes,
            a.late_morning_minutes,
            a.late_lunch_minutes
        from
            attendance a
            join employee e on a.comCode = e.comCode
            and a.empCode = e.empCode
        where
            e.scanCode = '99999'
            and YEAR(a.dateAt) = 2000
            and MONTH (a.dateAt) = 1
    )
select
    e.id,
    e.scenario,
    -- Work Check
    case
        when coalesce(a.work_minutes, 0) = e.exp_work then 'PASS'
        else concat(
            'FAIL (Got ',
            coalesce(a.work_minutes, 0),
            ', Exp ',
            e.exp_work,
            ')'
        )
    end as work_check,
    -- Late1 Check
    case
        when coalesce(a.late_morning_minutes, 0) = e.exp_late1 then 'PASS'
        else concat(
            'FAIL (Got ',
            coalesce(a.late_morning_minutes, 0),
            ', Exp ',
            e.exp_late1,
            ')'
        )
    end as late1_check,
    -- Late2 Check
    case
        when coalesce(a.late_lunch_minutes, 0) = e.exp_late2 then 'PASS'
        else concat(
            'FAIL (Got ',
            coalesce(a.late_lunch_minutes, 0),
            ', Exp ',
            e.exp_late2,
            ')'
        )
    end as late2_check,
    -- OT Check
    case
        when coalesce(a.ot_total_minutes, 0) = e.exp_ot then 'PASS'
        else concat(
            'FAIL (Got ',
            coalesce(a.ot_total_minutes, 0),
            ', Exp ',
            e.exp_ot,
            ')'
        )
    end as ot_check
from
    expected_values e
    left join actual_values a on e.id = a.id
order by
    e.id;
