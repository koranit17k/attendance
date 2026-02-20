CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW `vAttendance` AS
SELECT b.status,
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
  CASE
    WHEN b.status = '3' THEN 0
    WHEN b.lunch_case = '1.ไม่พักเที่ยง' THEN 300
    WHEN b.lunch_case = '3.สแกนครั้งเดียว' THEN 180
    WHEN b.lunch_out_min IS NOT NULL
    AND b.lunch_in_min IS NOT NULL THEN GREATEST(60, b.lunch_break_min)
    ELSE 60
  END AS lunch_minutes,
  /* late_morning_minutes (ใช้ b.late_morning_base) */
  CASE
    WHEN b.status = '3' THEN 0
    ELSE b.late_morning_base
  END AS late_morning_minutes,
  /* late_lunch_minutes (รวม 2 ก้อนที่เคยซ้ำ: lunch_penalty_base + miss_evening_base) */
  CASE
    WHEN b.status = '3' THEN 0
    WHEN b.day_case = '1.เช้า-เย็น' THEN b.lunch_penalty_base + b.miss_evening_base
    WHEN b.day_case = '2.เช้าขาเดียว' THEN b.morning_halfday_penalty_base
    WHEN b.day_case = '3.เย็นขาเดียว' THEN b.evening_halfday_penalty_base + b.miss_evening_base
    ELSE 0
  END AS late_lunch_minutes,
  /* work_minutes (เอาก้อนเดิมมาใช้ซ้ำจาก base) */
  CASE
    WHEN b.status = '3'
    OR b.day_case = '4.ไม่มี' THEN 0
    WHEN b.day_case = '1.เช้า-เย็น' THEN GREATEST(
      0,
      480 - b.late_morning_base - (b.lunch_penalty_base + b.miss_evening_base)
    )
    WHEN b.day_case = '2.เช้าขาเดียว' THEN GREATEST(
      0,
      240 - b.late_morning_base - b.morning_halfday_penalty_base
    )
    WHEN b.day_case = '3.เย็นขาเดียว' THEN GREATEST(
      0,
      240 - b.evening_halfday_penalty_base - b.miss_evening_base
    )
    ELSE 0
  END AS work_minutes,
  /* ot_total_minutes (เหมือนเดิม) */
  CASE
    WHEN b.status = '3'
    OR b.day_case = '4.ไม่มี' THEN 0
    WHEN b.morning_min IS NOT NULL
    AND (
      b.night_min IS NOT NULL
      OR b.early_min IS NOT NULL
    ) THEN CASE
      WHEN b.early_min IS NOT NULL THEN 360 + b.early_min
      WHEN b.night_min IS NOT NULL
      AND b.night_min > 1080 THEN b.night_min - 1080
      ELSE 0
    END
    ELSE 0
  END AS ot_total_minutes
FROM (
    SELECT a.*,
      /* base: ส่วนที่ใช้ซ้ำ */
      CASE
        WHEN a.morning_min IS NOT NULL
        AND a.morning_min > 480 THEN a.morning_min - 480
        ELSE 0
      END AS late_morning_base,
      CASE
        WHEN a.lunch_out_min IS NOT NULL
        AND a.lunch_in_min IS NOT NULL THEN (a.lunch_in_min - a.lunch_out_min)
        ELSE NULL
      END AS lunch_break_min,
      /* base: ชุด “สายหลังพัก/หัก 60” + “เย็นขาเดียวหลัง 13:00” (ก้อนใหญ่ที่ซ้ำ) */
      CASE
        WHEN a.day_case = '1.เช้า-เย็น'
        AND a.lunch_case = '1.ไม่พักเที่ยง' THEN 240
        WHEN a.day_case = '1.เช้า-เย็น'
        AND a.lunch_case = '3.สแกนครั้งเดียว' THEN 120
        WHEN a.lunch_out_min IS NOT NULL
        AND a.lunch_in_min IS NOT NULL
        AND (a.lunch_in_min - a.lunch_out_min) > 60 THEN (a.lunch_in_min - a.lunch_out_min) - 60
        WHEN a.day_case = '3.เย็นขาเดียว'
        AND a.lunch_in_min IS NOT NULL
        AND a.lunch_in_min > 780 THEN a.lunch_in_min - 780
        ELSE 0
      END AS lunch_penalty_base,
      /* base: ขาดสแกนออกเย็น ชดเชยถึง 17:00 */
      CASE
        WHEN a.night_min IS NULL
        AND a.early_min IS NULL
        AND a.day_case IN ('1.เช้า-เย็น', '3.เย็นขาเดียว')
        AND a.evening_min IS NOT NULL
        AND a.evening_min < 1020 THEN 1020 - a.evening_min
        ELSE 0
      END AS miss_evening_base,
      /* base: เฉพาะ day_case='2.เช้าขาเดียว' ที่เคยซ้ำ */
      CASE
        WHEN a.day_case = '2.เช้าขาเดียว' THEN GREATEST(
          0,
          GREATEST(720, a.morning_min + 240) - a.lunch_out_min
        )
        ELSE 0
      END AS morning_halfday_penalty_base,
      /* base: เฉพาะ day_case='3.เย็นขาเดียว' (หลัง 13:00) ที่เคยซ้ำ */
      CASE
        WHEN a.day_case = '3.เย็นขาเดียว'
        AND a.lunch_in_min IS NOT NULL
        AND a.lunch_in_min > 780 THEN a.lunch_in_min - 780
        ELSE 0
      END AS evening_halfday_penalty_base
    FROM (
        /* ======= a: subquery เดิมของคุณ (จาก attendance v) ======= */
        SELECT comCode,
          empCode,
          dateAt,
          IF(
            v.morning IS NOT NULL
            AND (
              v.evening IS NOT NULL
              OR v.night IS NOT NULL
              OR v.early IS NOT NULL
            ),
            '1.เช้า-เย็น',
            IF(
              v.morning IS NOT NULL,
              '2.เช้าขาเดียว',
              IF(
                v.evening IS NOT NULL
                OR v.night IS NOT NULL
                OR v.early IS NOT NULL,
                '3.เย็นขาเดียว',
                '4.ไม่มี'
              )
            )
          ) AS day_case,
          IF(
            v.lunch_out IS NULL
            AND v.lunch_in IS NULL,
            '1.ไม่พักเที่ยง',
            IF(
              v.lunch_out <> v.lunch_in,
              '2.มีพักเที่ยง',
              '3.สแกนครั้งเดียว'
            )
          ) AS lunch_case,
          IF(
            v.night IS NULL
            AND v.early IS NULL,
            '1.ไม่มีค่ำ',
            IF(v.early IS NOT NULL, '3.ข้ามวัน ', '2.ออกค่ำ')
          ) AS night_case,
          IF(
            v.morning IS NOT NULL
            AND (
              v.evening IS NOT NULL
              OR v.night IS NOT NULL
              OR v.early IS NOT NULL
            ),
            '1',
            IF(
              (
                v.lunch_out IS NOT NULL
                OR v.lunch_in IS NOT NULL
              )
              AND (
                v.morning IS NOT NULL
                XOR (
                  v.evening IS NOT NULL
                  OR v.night IS NOT NULL
                  OR v.early IS NOT NULL
                )
              ),
              '2',
              '3'
            )
          ) AS status,
          v.early,
          FLOOR(TIME_TO_SEC(v.early) / 60) AS early_min,
          v.morning,
          FLOOR(TIME_TO_SEC(v.morning) / 60) AS morning_min,
          v.lunch_out,
          FLOOR(TIME_TO_SEC(v.lunch_out) / 60) AS lunch_out_min,
          v.lunch_in,
          FLOOR(TIME_TO_SEC(v.lunch_in) / 60) AS lunch_in_min,
          v.evening,
          FLOOR(TIME_TO_SEC(v.evening) / 60) AS evening_min,
          v.night,
          FLOOR(TIME_TO_SEC(v.night) / 60) AS night_min,
          v.`count`,
          v.rawTime
        FROM attendance v -- WHERE v.dateAt >= CURDATE() - INTERVAL 1.5 month -- กำหนดช่วงวันที่ตามต้องการ
      ) a
  ) b;