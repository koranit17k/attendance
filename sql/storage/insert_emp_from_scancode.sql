
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
