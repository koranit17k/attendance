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