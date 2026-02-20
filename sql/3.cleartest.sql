SET @test_year = '2000';
SET @emp_code = '99999';
-- Use a test scan code
-- Clear existing data for test range
-- ลบข้อมูล attendance ของ test employee
DELETE a
FROM attendance a
    JOIN employee e ON a.comCode = e.comCode
    AND a.empCode = e.empCode
WHERE e.scanCode = @emp_code
    AND YEAR(a.dateAt) = @test_year
    AND MONTH(a.dateAt) = 1;
-- ลบข้อมูล timecard ของ test employee
DELETE FROM timecard
WHERE scanCode = @emp_code
    AND YEAR(scanAt) = @test_year
    AND MONTH(scanAt) = 1;