SET @test_year = '2000';
SET @emp_code = '99999';
-- Use a test scan code
-- Clear existing data for test range
DELETE FROM timecard
WHERE scanCode = @emp_code
    AND YEAR(scanAt) = @test_year
    AND MONTH(scanAt) = 1;