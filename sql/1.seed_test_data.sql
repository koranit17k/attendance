-- Seed Test Data for Attendance Scenarios (Year 2000)
-- Maps README scenarios to dates in 2000 (Case 1 -> Jan 1, Case 2 -> Jan 2, etc.)
SET @test_year = '2000';
SET @emp_code = '99999';
-- Use a test scan code
-- Clear existing data for test range
DELETE FROM timecard
WHERE scanCode = @emp_code
    AND YEAR(scanAt) = @test_year
    AND MONTH(scanAt) = 1;
-- 1. Normal 1: 08:00, 12:00, 13:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-01 08:00:00'),
    (@emp_code, '2000-01-01 12:00:00'),
    (@emp_code, '2000-01-01 13:00:00'),
    (@emp_code, '2000-01-01 17:00:00');
-- 2. Normal 2: 07:50, 12:04, 12:45, 17:30
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-02 07:50:00'),
    (@emp_code, '2000-01-02 12:04:00'),
    (@emp_code, '2000-01-02 12:45:00'),
    (@emp_code, '2000-01-02 17:30:00');
-- 3. OT Night 1: 08:00, 12:30, 12:50, 17:30, 21:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-03 08:00:00'),
    (@emp_code, '2000-01-03 12:30:00'),
    (@emp_code, '2000-01-03 12:50:00'),
    (@emp_code, '2000-01-03 17:30:00'),
    (@emp_code, '2000-01-03 21:00:00');
-- 4. OT Night 2: 08:00, 12:00, 12:55, 21:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-04 08:00:00'),
    (@emp_code, '2000-01-04 12:00:00'),
    (@emp_code, '2000-01-04 12:55:00'),
    (@emp_code, '2000-01-04 21:00:00');
-- 5. OT Night 3: 12:00, 12:55, 21:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-05 12:00:00'),
    (@emp_code, '2000-01-05 12:55:00'),
    (@emp_code, '2000-01-05 21:00:00');
-- 6. OT Early: 08:00, 12:05, 12:57, 02:00 (Next Day)
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-06 08:00:00'),
    (@emp_code, '2000-01-06 12:05:00'),
    (@emp_code, '2000-01-06 12:57:00'),
    (@emp_code, '2000-01-07 02:00:00');
-- Scan at 02:00 is Early for prev day
-- 7. Missing Lunch 1: 08:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-07 08:00:00'),
    (@emp_code, '2000-01-07 17:00:00');
-- 8. Missing Lunch 2: 08:00, 12:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-08 08:00:00'),
    (@emp_code, '2000-01-08 12:00:00'),
    (@emp_code, '2000-01-08 17:00:00');
-- 9. Missing Lunch 3: 08:00, 15:00, 17:00 (15:00 is not lunch_out/in range typically?)
-- lunch_out: 11:00-13:30 (first/min), lunch_in 11:30-14:00, lunch_in view uses 12:00-15:00 range max?
-- View definition: lunch_in max(timeAt >= '12:00' and timeAt < '15:00')
-- 15:00 is exactly on boundary? Let's check view.sql: `timeAt < '15:00'` so 15:00 is excluded from lunch_in.
-- Wait, README says "15:00". If view says < 15:00, then 15:00 is NOT lunch_in.
-- Let's put 15:00:00.
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-09 08:00:00'),
    (@emp_code, '2000-01-09 15:00:00'),
    (@emp_code, '2000-01-09 17:00:00');
-- 10. morning+OT: 08:00, 12:01, 12:50, 20:31
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-10 08:00:00'),
    (@emp_code, '2000-01-10 12:01:00'),
    (@emp_code, '2000-01-10 12:50:00'),
    (@emp_code, '2000-01-10 20:31:00');
-- 11. morning+MLunch+OT 1: 08:00, 20:01
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-11 08:00:00'),
    (@emp_code, '2000-01-11 20:01:00');
-- 12. morning+MLunch+OT 2: 08:00, 12:00, 20:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-12 08:00:00'),
    (@emp_code, '2000-01-12 12:00:00'),
    (@emp_code, '2000-01-12 20:00:00');
-- 13. morning+MLunch+OT 3: 08:00, 14:00, 20:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-13 08:00:00'),
    (@emp_code, '2000-01-13 14:00:00'),
    (@emp_code, '2000-01-13 20:00:00');
-- 14. morning+MLunch+early: 08:00, 02:00 (Next Day)
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-14 08:00:00'),
    (@emp_code, '2000-01-15 02:00:00');
-- 15. Half Day Morning 1: 08:00, 12:05
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-15 08:00:00'),
    (@emp_code, '2000-01-15 12:05:00');
-- 16. Half Day Morning 2: 08:00, 12:00, 12:30
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-16 08:00:00'),
    (@emp_code, '2000-01-16 12:00:00'),
    (@emp_code, '2000-01-16 12:30:00');
-- 17. Half Day Afternoon 1: 13:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-17 13:00:00'),
    (@emp_code, '2000-01-17 17:00:00');
-- 18. Half Day Afternoon 2: 12:00, 13:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-18 12:00:00'),
    (@emp_code, '2000-01-18 13:00:00'),
    (@emp_code, '2000-01-18 17:00:00');
-- 19. Late Morning: 08:20, 12:00, 13:00, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-19 08:20:00'),
    (@emp_code, '2000-01-19 12:00:00'),
    (@emp_code, '2000-01-19 13:00:00'),
    (@emp_code, '2000-01-19 17:00:00');
-- 20. Late Lunch: 08:00, 12:00, 13:15, 17:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-20 08:00:00'),
    (@emp_code, '2000-01-20 12:00:00'),
    (@emp_code, '2000-01-20 13:15:00'),
    (@emp_code, '2000-01-20 17:00:00');
-- 21. Spam Morning: 07:50, 08:00, 08:05, 17:05
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-21 07:50:00'),
    (@emp_code, '2000-01-21 08:00:00'),
    (@emp_code, '2000-01-21 08:05:00'),
    (@emp_code, '2000-01-21 17:05:00');
-- 22. Spam Lunch Out: 07:00, 11:55, 12:05, 12:10, 17:09
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-22 07:00:00'),
    (@emp_code, '2000-01-22 11:55:00'),
    (@emp_code, '2000-01-22 12:05:00'),
    (@emp_code, '2000-01-22 12:10:00'),
    (@emp_code, '2000-01-22 17:09:00');
-- 23. Absent 1: 08:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-23 08:00:00');
-- 24. Absent 2: 17:30
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-24 17:30:00');
-- 25. Absent 3: 17:30, 20:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-25 17:30:00'),
    (@emp_code, '2000-01-25 20:00:00');
-- 26. Absent 4: 20:00
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-26 20:00:00');
-- 27. Absent 5: 12:00, 13:00 (Lunch Only)
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-27 12:00:00'),
    (@emp_code, '2000-01-27 13:00:00');
-- 28. Absent 6: 11:15
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-28 11:15:00');
-- 29. Absent 7: 11:15
INSERT INTO timecard (scanCode, scanAt)
VALUES (@emp_code, '2000-01-29 11:15:00');