-- payroll.vAttendanceMinutes source
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vAttendanceMinutes` AS
select `x`.`status` AS `status`,
    `x`.`scanCode` AS `scanCode`,
    `x`.`dateAt` AS `dateAt`,
    `x`.`day_case` AS `day_case`,
    `x`.`lunch_case` AS `lunch_case`,
    `x`.`night_case` AS `night_case`,
    `x`.`early` AS `early`,
    `x`.`morning` AS `morning`,
    `x`.`lunch_out` AS `lunch_out`,
    `x`.`lunch_in` AS `lunch_in`,
    `x`.`evening` AS `evening`,
    `x`.`night` AS `night`,
    `x`.`lunch_minutes` AS `lunch_minutes`,
    `x`.`late_morning_minutes` AS `late_morning_minutes`,
    `x`.`late_lunch_minutes` AS `late_lunch_minutes`,
    `x`.`work_minutes` AS `work_minutes`,
    `x`.`ot_total_minutes` AS `ot_total_minutes`,
    ifnull(`x`.`work_minutes`, 0) + ifnull(`x`.`ot_total_minutes`, 0) AS `total_work_minutes`
from (
        select `a`.`status` AS `status`,
            `a`.`scanCode` AS `scanCode`,
            `a`.`dateAt` AS `dateAt`,
            `a`.`day_case` AS `day_case`,
            `a`.`lunch_case` AS `lunch_case`,
            `a`.`night_case` AS `night_case`,
            `a`.`early` AS `early`,
            `a`.`morning` AS `morning`,
            `a`.`lunch_out` AS `lunch_out`,
            `a`.`lunch_in` AS `lunch_in`,
            `a`.`evening` AS `evening`,
            `a`.`night` AS `night`,
            if(
                `a`.`lunch_out` is not null
                and `a`.`lunch_in` is not null
                and `a`.`lunch_in` <> `a`.`lunch_out`
                and `a`.`lunch_in` > `a`.`lunch_out`,
                ifnull(
                    time_to_sec(timediff(`a`.`lunch_in`, `a`.`lunch_out`)) / 60,
                    0
                ),
                if(
                    (
                        `a`.`lunch_out` is not null
                        xor `a`.`lunch_in` is not null
                    )
                    and (
                        `a`.`day_case` = '1.เช้า-เย็น'
                        and (
                            `a`.`night` is null
                            or `a`.`night` is not null
                        )
                        or `a`.`day_case` = '2.เช้าขาเดียว'
                        and `a`.`night` is not null
                    ),
                    120,
                    if(
                        `a`.`lunch_out` is not null
                        xor `a`.`lunch_in` is not null,
                        60,
                        0
                    )
                )
            ) AS `lunch_minutes`,
            if(
                `a`.`morning` is not null
                and `a`.`morning` > '08:00:00',
                ifnull(
                    time_to_sec(timediff(`a`.`morning`, '08:00:00')) / 60,
                    0
                ),
                0
            ) AS `late_morning_minutes`,
            if(
                `a`.`lunch_out` is not null
                and `a`.`lunch_in` is not null
                and `a`.`lunch_in` <> `a`.`lunch_out`
                and `a`.`lunch_in` > `a`.`lunch_out`,
                greatest(
                    ifnull(
                        time_to_sec(timediff(`a`.`lunch_in`, `a`.`lunch_out`)) / 60,
                        0
                    ) - 60,
                    0
                ),
                0
            ) AS `late_lunch_minutes`,
            if(
                `a`.`morning` is not null
                and (
                    `a`.`lunch_out` is not null
                    or `a`.`lunch_in` is not null
                )
                and (
                    `a`.`night` is not null
                    or `a`.`evening` is not null
                    or `a`.`early` is not null
                ),
                greatest(
                    greatest(
                        ifnull(
                            time_to_sec(
                                timediff(
                                    least(
                                        ifnull(`a`.`evening`, ifnull(`a`.`night`, `a`.`early`)),
                                        '17:00:00'
                                    ),
                                    greatest(`a`.`morning`, '08:00:00')
                                )
                            ) / 60,
                            0
                        ),
                        0
                    ) - if(
                        `a`.`lunch_out` is not null
                        and `a`.`lunch_in` is not null
                        and `a`.`lunch_in` <> `a`.`lunch_out`
                        and `a`.`lunch_in` > `a`.`lunch_out`,
                        ifnull(
                            time_to_sec(timediff(`a`.`lunch_in`, `a`.`lunch_out`)) / 60,
                            0
                        ),
                        if(
                            `a`.`lunch_case` = '3.สแกนครั้งเดียว'
                            and (
                                `a`.`day_case` = '1.เช้า-เย็น'
                                and `a`.`night_case` in ('1.ไม่มีค่ำ', '2.ออกค่ำ')
                                or `a`.`day_case` = '2.เช้าขาเดียว'
                                and `a`.`night_case` = '2.ออกค่ำ'
                            ),
                            120,
                            60
                        )
                    ),
                    0
                ),
                if(
                    `a`.`day_case` = '2.เช้าขาเดียว'
                    and `a`.`lunch_case` in ('2.มีพักเที่ยง', '3.สแกนครั้งเดียว')
                    and `a`.`night` is null
                    and `a`.`evening` is null,
                    least(
                        greatest(
                            ifnull(
                                time_to_sec(
                                    timediff(
                                        `a`.`lunch_out`,
                                        greatest(`a`.`morning`, '08:00:00')
                                    )
                                ) / 60,
                                0
                            ),
                            0
                        ),
                        240
                    ),
                    if(
                        `a`.`day_case` = '3.เย็นขาเดียว'
                        and `a`.`lunch_case` in ('2.มีพักเที่ยง', '3.สแกนครั้งเดียว')
                        and (
                            `a`.`evening` is not null
                            or `a`.`night` is not null
                            or `a`.`early` is not null
                        )
                        and (
                            `a`.`lunch_in` is not null
                            or `a`.`lunch_out` is not null
                        ),
                        least(
                            greatest(
                                ifnull(
                                    time_to_sec(
                                        timediff(
                                            least(
                                                ifnull(`a`.`evening`, ifnull(`a`.`night`, `a`.`early`)),
                                                '17:00:00'
                                            ),
                                            ifnull(`a`.`lunch_in`, `a`.`lunch_out`)
                                        )
                                    ) / 60,
                                    0
                                ),
                                0
                            ),
                            240
                        ),
                        if(
                            `a`.`morning` is null
                            or `a`.`evening` is null
                            and `a`.`night` is null
                            and `a`.`early` is null,
                            0,
                            greatest(
                                greatest(
                                    ifnull(
                                        time_to_sec(
                                            timediff(
                                                least(
                                                    ifnull(`a`.`evening`, ifnull(`a`.`night`, `a`.`early`)),
                                                    '17:00:00'
                                                ),
                                                greatest(`a`.`morning`, '08:00:00')
                                            )
                                        ) / 60,
                                        0
                                    ),
                                    0
                                ) - if(
                                    `a`.`lunch_out` is not null
                                    and `a`.`lunch_in` is not null
                                    and `a`.`lunch_in` <> `a`.`lunch_out`
                                    and `a`.`lunch_in` > `a`.`lunch_out`,
                                    ifnull(
                                        time_to_sec(timediff(`a`.`lunch_in`, `a`.`lunch_out`)) / 60,
                                        0
                                    ),
                                    if(
                                        `a`.`lunch_case` = '3.สแกนครั้งเดียว'
                                        and (
                                            `a`.`day_case` = '1.เช้า-เย็น'
                                            and `a`.`night_case` in ('1.ไม่มีค่ำ', '2.ออกค่ำ')
                                            or `a`.`day_case` = '2.เช้าขาเดียว'
                                            and `a`.`night_case` = '2.ออกค่ำ'
                                        ),
                                        120,
                                        60
                                    )
                                ),
                                0
                            )
                        )
                    )
                )
            ) AS `work_minutes`,
            if(
                `a`.`morning` is null,
                0,
                if(
                    `a`.`early` is not null,
                    if(
                        `a`.`night` is not null
                        and `a`.`night` > '18:00:00',
                        ifnull(
                            time_to_sec(timediff(`a`.`night`, '18:00:00')) / 60,
                            0
                        ),
                        360
                    ) + ifnull(time_to_sec(`a`.`early`) / 60, 0),
                    if(
                        ifnull(`a`.`night`, `a`.`evening`) is not null
                        and ifnull(`a`.`night`, `a`.`evening`) > '18:00:00',
                        ifnull(
                            time_to_sec(
                                timediff(ifnull(`a`.`night`, `a`.`evening`), '18:00:00')
                            ) / 60,
                            0
                        ),
                        0
                    )
                )
            ) AS `ot_total_minutes`
        from `vAttendance` `a`
    ) `x`;