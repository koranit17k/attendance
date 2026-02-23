create
or
replace
    ALGORITHM = UNDEFINED VIEW `vAttendance` as
select
    b.status,
    b.comCode,
    b.empCode,
    b.dateAt,
    b.day_case,
    b.lunch_case,
    b.night_case,
    b.early,
    b.early_min,
    b.morning,
    b.morning_min,
    b.lunch_out,
    b.lunch_out_min,
    b.lunch_in,
    b.lunch_in_min,
    b.evening,
    b.evening_min,
    b.night,
    b.night_min,
    /* lunch_minutes (เหมือนเดิม แต่ใช้ b.lunch_break_min) */
    case
        when b.status = '3' then 0
        when b.lunch_case = '1.ไม่พักเที่ยง' then 300
        when b.lunch_case = '3.สแกนครั้งเดียว' then 180
        when b.lunch_out_min is not null
        and b.lunch_in_min is not null then greatest(60, b.lunch_break_min)
        else 60
    end as lunch_minutes,
    /* late_morning_minutes (ใช้ b.late_morning_base) */
    case
        when b.status = '3' then 0
        else b.late_morning_base
    end as late_morning_minutes,
    /* late_lunch_minutes (รวม 2 ก้อนที่เคยซ้ำ: lunch_penalty_base + miss_evening_base) */
    case
        when b.status = '3' then 0
        when b.day_case = '1.เช้า-เย็น' then b.lunch_penalty_base + b.miss_evening_base
        when b.day_case = '2.เช้าขาเดียว' then b.morning_halfday_penalty_base
        when b.day_case = '3.เย็นขาเดียว' then b.evening_halfday_penalty_base + b.miss_evening_base
        else 0
    end as late_lunch_minutes,
    /* work_minutes (เอาก้อนเดิมมาใช้ซ้ำจาก base) */
    case
        when b.status = '3'
        or b.day_case = '4.ไม่มี' then 0
        when b.day_case = '1.เช้า-เย็น' then greatest(
            0,
            480 - b.late_morning_base - (b.lunch_penalty_base + b.miss_evening_base)
        )
        when b.day_case = '2.เช้าขาเดียว' then greatest(
            0,
            240 - b.late_morning_base - b.morning_halfday_penalty_base
        )
        when b.day_case = '3.เย็นขาเดียว' then greatest(
            0,
            240 - b.evening_halfday_penalty_base - b.miss_evening_base
        )
        else 0
    end as work_minutes,
    /* ot_total_minutes (เหมือนเดิม) */
    case
        when b.status = '3'
        or b.day_case = '4.ไม่มี' then 0
        when b.morning_min is not null
        and (
            b.night_min is not null
            or b.early_min is not null
        ) then case
            when b.early_min is not null then 360 + b.early_min
            when b.night_min is not null
            and b.night_min > 1080 then b.night_min - 1080
            else 0
        end
        else 0
    end as ot_total_minutes
from
    (
        select
            a.*,
            /* base: ส่วนที่ใช้ซ้ำ */
            case
                when a.morning_min is not null
                and a.morning_min > 480 then a.morning_min - 480
                else 0
            end as late_morning_base,
            case
                when a.lunch_out_min is not null
                and a.lunch_in_min is not null then (a.lunch_in_min - a.lunch_out_min)
                else null
            end as lunch_break_min,
            /* base: ชุด “สายหลังพัก/หัก 60” + “เย็นขาเดียวหลัง 13:00” (ก้อนใหญ่ที่ซ้ำ) */
            case
                when a.day_case = '1.เช้า-เย็น'
                and a.lunch_case = '1.ไม่พักเที่ยง' then 240
                when a.day_case = '1.เช้า-เย็น'
                and a.lunch_case = '3.สแกนครั้งเดียว' then 120
                when a.lunch_out_min is not null
                and a.lunch_in_min is not null
                and (a.lunch_in_min - a.lunch_out_min) > 60 then (a.lunch_in_min - a.lunch_out_min) - 60
                when a.day_case = '3.เย็นขาเดียว'
                and a.lunch_in_min is not null
                and a.lunch_in_min > 780 then a.lunch_in_min - 780
                else 0
            end as lunch_penalty_base,
            /* base: ขาดสแกนออกเย็น ชดเชยถึง 17:00 */
            case
                when a.night_min is null
                and a.early_min is null
                and a.day_case in ('1.เช้า-เย็น', '3.เย็นขาเดียว')
                and a.evening_min is not null
                and a.evening_min < 1020 then 1020 - a.evening_min
                else 0
            end as miss_evening_base,
            /* base: เฉพาะ day_case='2.เช้าขาเดียว' ที่เคยซ้ำ */
            case
                when a.day_case = '2.เช้าขาเดียว' then greatest(
                    0,
                    greatest(720, a.morning_min + 240) - a.lunch_out_min
                )
                else 0
            end as morning_halfday_penalty_base,
            /* base: เฉพาะ day_case='3.เย็นขาเดียว' (หลัง 13:00) ที่เคยซ้ำ */
            case
                when a.day_case = '3.เย็นขาเดียว'
                and a.lunch_in_min is not null
                and a.lunch_in_min > 780 then a.lunch_in_min - 780
                else 0
            end as evening_halfday_penalty_base
        from
            (
                /* ======= a: subquery เดิมของคุณ (จาก attendance v) ======= */
                select
                    comCode,
                    empCode,
                    dateAt,
                    if (
                        v.morning is not null
                        and (
                            v.evening is not null
                            or v.night is not null
                            or v.early is not null
                        ),
                        '1.เช้า-เย็น',
                        if (
                            v.morning is not null,
                            '2.เช้าขาเดียว',
                            if (
                                v.evening is not null
                                or v.night is not null
                                or v.early is not null,
                                '3.เย็นขาเดียว',
                                '4.ไม่มี'
                            )
                        )
                    ) as day_case,
                    if (
                        v.lunch_out is null
                        and v.lunch_in is null,
                        '1.ไม่พักเที่ยง',
                        if (
                            v.lunch_out <> v.lunch_in,
                            '2.มีพักเที่ยง',
                            '3.สแกนครั้งเดียว'
                        )
                    ) as lunch_case,
                    if (
                        v.night is null
                        and v.early is null,
                        '1.ไม่มีค่ำ',
                        if (v.early is not null, '3.ข้ามวัน ', '2.ออกค่ำ')
                    ) as night_case,
                    if (
                        v.morning is not null
                        and (
                            v.evening is not null
                            or v.night is not null
                            or v.early is not null
                        ),
                        '1',
                        if (
                            (
                                v.lunch_out is not null
                                or v.lunch_in is not null
                            )
                            and (
                                v.morning is not null
                                xor (
                                    v.evening is not null
                                    or v.night is not null
                                    or v.early is not null
                                )
                            ),
                            '2',
                            '3'
                        )
                    ) as status,
                    v.early,
                    floor(time_to_sec(v.early) / 60) as early_min,
                    v.morning,
                    floor(time_to_sec(v.morning) / 60) as morning_min,
                    v.lunch_out,
                    floor(time_to_sec(v.lunch_out) / 60) as lunch_out_min,
                    v.lunch_in,
                    floor(time_to_sec(v.lunch_in) / 60) as lunch_in_min,
                    v.evening,
                    floor(time_to_sec(v.evening) / 60) as evening_min,
                    v.night,
                    floor(time_to_sec(v.night) / 60) as night_min,
                    v.`count`,
                    v.rawTime
                from
                    attendance v -- WHERE v.dateAt >= CURDATE() - INTERVAL 1.5 month -- กำหนดช่วงวันที่ตามต้องการ
            ) a
    ) b;
