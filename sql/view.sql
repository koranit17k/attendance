-- payroll.vTimeCard source
create
or
replace
    ALGORITHM = UNDEFINED VIEW `vTimeCard` as
select
    `timecard`.`scanCode` as `scanCode`,
    date_format(if (cast(`timecard`.`scanAt` as time) < '06:00', `timecard`.`scanAt` - interval 1 day, `timecard`.`scanAt`), '%Y-%m-%d') as `dateAt`,
    date_format(`timecard`.`scanAt`, '%H:%i') as `timeAt`
from
    `timecard`;

-- payroll.vDailyTime source
create
or
replace
    ALGORITHM = UNDEFINED VIEW `vDailyTime` as
select
    `vTimeCard`.`dateAt` as `dateAt`,
    `vTimeCard`.`scanCode` as `scanCode`,
    max(if (`vTimeCard`.`timeAt` < '06:00', `vTimeCard`.`timeAt`, null)) as `early`,
    max(
        if (
            `vTimeCard`.`timeAt` >= '06:00'
            and `vTimeCard`.`timeAt` < '09:30',
            `vTimeCard`.`timeAt`,
            null
        )
    ) as `morning`,
    min(
        if (
            `vTimeCard`.`timeAt` >= '11:00'
            and `vTimeCard`.`timeAt` < '13:30',
            `vTimeCard`.`timeAt`,
            null
        )
    ) as `lunch_out`,
    max(
        if (
            `vTimeCard`.`timeAt` >= '12:00'
            and `vTimeCard`.`timeAt` <= '15:00',
            `vTimeCard`.`timeAt`,
            null
        )
    ) as `lunch_in`,
    max(
        if (
            `vTimeCard`.`timeAt` >= '16:00'
            and `vTimeCard`.`timeAt` < '19:00',
            `vTimeCard`.`timeAt`,
            null
        )
    ) as `evening`,
    max(if (`vTimeCard`.`timeAt` >= '19:00', `vTimeCard`.`timeAt`, null)) as `night`,
    count(0) as `count`,
    group_concat(`vTimeCard`.`timeAt` separator ',') as `rawTime`
from
    `vTimeCard`
group by
    `vTimeCard`.`dateAt`,
    `vTimeCard`.`scanCode`;
