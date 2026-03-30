
-- insert กรณี มีฐานข้อมูลพนักงาน ที่ยังไม่มีใน employee table 
-- *ในกรณีนี้ใช้ table scancode ในการ insert เพราะ table scancode คือรายชื่อพนักงานที่ได้รับมาภายหลัง
INSERT INTO employee (comCode, empCode, name, surName, scanCode)
SELECT
    '07' AS comCode,
    mx.max_empCode + x.rn AS empCode,
    x.name,
    x.surName,
    x.scanCode
FROM (
    SELECT
        s.scanCode,
        s.name,
        s.surName,
        ROW_NUMBER() OVER (ORDER BY s.scanCode) AS rn -- ใช้สร้าง รหัสพนักงานใหม่
    FROM scancode s
    LEFT JOIN employee e
        ON s.scanCode = e.scanCode
    WHERE e.scanCode IS NULL
) x
CROSS JOIN (
    SELECT IFNULL(MAX(empCode), 0) AS max_empCode -- หารหัสพนักงานที่มากที่สุด
    FROM employee
) mx;

-- ทำให้ timecode = 1 ทุกคน ก่อนคลีน ว่าใครไม่มาทำงานแล้ว
UPDATE employee
SET timeCode = CASE 
    WHEN empCode IN (2,5,6) THEN NULL
    ELSE 1
END;


-- update timeCode เป็น null สำหรับคนที่ไม่ได้มาทำงาน ตั้งแต่ 2025-01-01 **ใช้ clean data
UPDATE employee e
SET e.timeCode = NULL
WHERE e.timeCode IS NOT NULL
  AND e.endDate IS not NULL
  AND NOT EXISTS (
        SELECT 1
        FROM attendance a
        WHERE a.comCode = e.comCode
          AND a.empCode = e.empCode
          AND a.dateAt >= '2025-01-01'
          AND a.dateAt < CURDATE() + INTERVAL 1 DAY
  );