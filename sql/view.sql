-- payroll.vTimeCard source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vTimeCard` AS
select `timecard`.`scanCode` AS `scanCode`,
    date_format(
        if(
            cast(`timecard`.`scanAt` as time) < '06:00',
            `timecard`.`scanAt` - interval 1 day,
            `timecard`.`scanAt`
        ),
        '%Y-%m-%d'
    ) AS `dateAt`,
    date_format(`timecard`.`scanAt`, '%H:%i') AS `timeAt`
from `timecard`;
-- payroll.vDailyTime source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vDailyTime` AS
select `vTimeCard`.`dateAt` AS `dateAt`,
    `vTimeCard`.`scanCode` AS `scanCode`,
    max(
        if(
            `vTimeCard`.`timeAt` < '06:00',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `early`,
    max(
        if(
            `vTimeCard`.`timeAt` >= '06:00'
            and `vTimeCard`.`timeAt` < '09:30',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `morning`,
    min(
        if(
            `vTimeCard`.`timeAt` >= '11:00'
            and `vTimeCard`.`timeAt` < '13:30',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `lunch_out`,
    max(
        if(
            `vTimeCard`.`timeAt` >= '12:00'
            and `vTimeCard`.`timeAt` <= '15:00',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `lunch_in`,
    max(
        if(
            `vTimeCard`.`timeAt` >= '16:00'
            and `vTimeCard`.`timeAt` < '19:00',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `evening`,
    max(
        if(
            `vTimeCard`.`timeAt` >= '19:00',
            `vTimeCard`.`timeAt`,
            NULL
        )
    ) AS `night`,
    count(0) AS `count`,
    group_concat(`vTimeCard`.`timeAt` separator ',') AS `rawTime`
from `vTimeCard`
group by `vTimeCard`.`dateAt`,
    `vTimeCard`.`scanCode`;
--

-- payroll.vAttendance source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vAttendance` AS
select if(
        `v`.`morning` is not null
        and (
            `v`.`evening` is not null
            or `v`.`night` is not null
            or `v`.`early` is not null
        ),
        '1.เช้า-เย็น',
        if(
            `v`.`morning` is not null,
            '2.เช้าขาเดียว',
            if(
                (
                    `v`.`evening` is not null
                    or `v`.`night` is not null
                    or `v`.`early` is not null
                ),
                '3.เย็นขาเดียว',
                '4.ไม่มี'
            )
        )
    ) AS `day_case`,
    if(
        `v`.`lunch_out` is null
        and `v`.`lunch_in` is null,
        '1.ไม่พักเที่ยง',
        if(
            `v`.`lunch_out` <> `v`.`lunch_in`,
            '2.มีพักเที่ยง',
            '3.สแกนครั้งเดียว'
        )
    ) AS `lunch_case`,
    if(
        `v`.`night` is null
        and `v`.`early` is null,
        '1.ไม่มีค่ำ',
        if(
            `v`.`early` is not null,
            '3.ข้ามวัน ',
            '2.ออกค่ำ'
        )
    ) AS `night_case`,
    time_to_sec(timediff(`v`.`evening`, `v`.`morning`)) / 60 AS `work_min`,
    time_to_sec(timediff(`v`.`lunch_in`, `v`.`lunch_out`)) / 60 AS `lunch_min`,
    if(
        `v`.`morning` is not null
        and (
            `v`.`evening` is not null
            or `v`.`night` is not null
            or `v`.`early` is not null
        ),
        '1',
        -- green
        if(
            (
                `v`.`lunch_out` is not null
                or `v`.`lunch_in` is not null
            )
            and (
                `v`.`morning` is null
                xor `v`.`evening` is null
                and `v`.`night` is null
                and `v`.`early` is null
            ),
            '2',
            -- yellow
            '3' -- red
        )
    ) AS `status`,
    `v`.`dateAt` AS `dateAt`,
    `v`.`scanCode` AS `scanCode`,
    `v`.`early` AS `early`,
    `v`.`morning` AS `morning`,
    `v`.`lunch_out` AS `lunch_out`,
    `v`.`lunch_in` AS `lunch_in`,
    `v`.`evening` AS `evening`,
    `v`.`night` AS `night`,
    `v`.`count` AS `count`,
    `v`.`rawTime` AS `rawTime`
from `vDailyTime` `v`;