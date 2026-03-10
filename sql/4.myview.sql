create or replace view `vAttendance` as
select
    `v2`.*,
    case
        when v2.status = 'FullDay' then v2.fullWorkMin - v2.lateMin1 - v2.lateMin2
        when v2.status = 'HalfDay' then v2.halfWorkMin - v2.lateMin1 - v2.lateMin2
        else 0
    end as workMin
from
    (
        select
            `v`.*,
            greatest(0, coalesce(v.morning_m, v.fullWorkMin) - v.fullWorkMin) as lateMin1,
            if (
                v.lunch_out_m is null
                or v.lunch_in_m is null
                or v.lunch_out_m = v.lunch_in_m,
                0,
                v.lunch_in_m - v.lunch_out_m
            ) as lunchMin,
            case
                when v.status = 'FullDay' then if (
                    v.lunch_out_m is null
                    or v.lunch_in_m is null
                    or v.lunch_out_m = v.lunch_in_m,
                    if (
                        v.lunch_out_m is null
                        and v.lunch_in_m is null,
                        v.halfWorkMin,
                        v.halfWorkMin / 2
                    ),
                    greatest(0, v.lunch_in_m - v.lunch_out_m - 60)
                ) + if (
                    v.night_m is null
                    and v.early_m is null
                    and v.evening_m is not null,
                    greatest(0, 1020 - v.evening_m),
                    0
                )
                when v.status = 'HalfDay' then greatest(
                    0,
                    v.halfWorkMin - greatest(0, coalesce(v.morning_m, v.fullWorkMin) - v.fullWorkMin) - case
                        when v.morning_m is not null
                        and v.lunch_out_m is not null then least(v.halfWorkMin, v.lunch_out_m - greatest(v.morning_m, v.fullWorkMin))
                        when v.lunch_in_m is not null
                        and coalesce(v.early_m, v.night_m, v.evening_m) is not null then v.halfWorkMin - greatest(0, v.lunch_in_m - 780) - if (
                            v.night_m is null
                            and v.early_m is null
                            and v.evening_m is not null
                            and v.evening_m < 1020,
                            1020 - v.evening_m,
                            0
                        )
                        else 0
                    end
                )
                else 0
            end as lateMin2,
            if (
                v.morning_m is null
                or (
                    v.status = 'FullDay'
                    and v.night_m is null
                    and v.early_m is null
                ),
                0,
                case
                    when v.early_m is not null then v.early_m - 1080
                    when v.night_m is not null then v.night_m - 1080
                    else 0
                end
            ) as otMin
        from
            (
                select
                    240 as halfWorkMin,
                    480 as fullWorkMin,
                    floor(time_to_sec(morning) / 60) as morning_m,
                    floor(time_to_sec(lunch_out) / 60) as lunch_out_m,
                    floor(time_to_sec(lunch_in) / 60) as lunch_in_m,
                    floor(time_to_sec(evening) / 60) as evening_m,
                    floor(time_to_sec(night) / 60) as night_m,
                    floor(time_to_sec(early) / 60) + 1440 as early_m,
                    comCode,
                    empCode,
                    dateAt,
                    morning,
                    lunch_out,
                    lunch_in,
                    evening,
                    night,
                    early,
                    case
                        when (
                            `a`.`morning` is not null
                            and (
                                `a`.`evening` is not null
                                or `a`.`night` is not null
                                or `a`.`early` is not null
                            )
                        ) then 'FullDay'
                        when (
                            (`a`.`morning` is not null)
                            xor (
                                `a`.`evening` is not null
                                or `a`.`night` is not null
                                or `a`.`early` is not null
                            )
                        )
                        and (
                            `a`.`lunch_out` is not null
                            or `a`.`lunch_in` is not null
                        ) then 'HalfDay'
                        else 'Absent'
                    end as `status`
                from
                    `attendance` `a`
            ) v
    ) v2;
