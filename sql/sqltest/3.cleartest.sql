set
    @test_year = '2000';

set
    @emp_code = '99999';

-- Use a test scan code
-- Clear existing data for test range
-- ลบข้อมูล attendance ของ test employee
delete a
from
    attendance a
    join employee e on a.comCode = e.comCode
    and a.empCode = e.empCode
where
    e.scanCode = @emp_code
    and YEAR(a.dateAt) = @test_year
    and MONTH (a.dateAt) = 1;

-- ลบข้อมูล timecard ของ test employee
delete from timecard
where
    scanCode = @emp_code
    and YEAR(scanAt) = @test_year
    and MONTH (scanAt) = 1;
