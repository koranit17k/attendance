-- Seed Test Data for Attendance Scenarios (Year 2000)
-- Maps README scenarios to dates in 2000 (Case 1 -> Jan 1, Case 2 -> Jan 2, etc.)
SET @test_year = '2000';
SET @emp_code = '99999';
-- Clear existing data for test range
DELETE FROM timecard
WHERE scanCode = @emp_code
    AND YEAR(scanAt) = @test_year
    AND MONTH(scanAt) = 1;
INSERT INTO timecard (scanCode, scanAt)
VALUES -- 1. Normal 1: 07:52, 12:12, 13:12, 17:05
    (@emp_code, '2000-01-01 07:52'),
    (@emp_code, '2000-01-01 12:12'),
    (@emp_code, '2000-01-01 13:12'),
    (@emp_code, '2000-01-01 17:05'),
    -- 2. Normal 2: 07:50, 12:14, 12:45, 17:30
    (@emp_code, '2000-01-02 07:50'),
    (@emp_code, '2000-01-02 12:14'),
    (@emp_code, '2000-01-02 12:45'),
    (@emp_code, '2000-01-02 17:30'),
    -- 3. OT Night 1: 06:54, 12:32, 12:54, 17:31, 21:12
    (@emp_code, '2000-01-03 06:54'),
    (@emp_code, '2000-01-03 12:32'),
    (@emp_code, '2000-01-03 12:54'),
    (@emp_code, '2000-01-03 17:31'),
    (@emp_code, '2000-01-03 21:12'),
    -- 4. OT Night 2: 07:32, 12:10, 12:55, 21:10
    (@emp_code, '2000-01-04 07:32'),
    (@emp_code, '2000-01-04 12:10'),
    (@emp_code, '2000-01-04 12:55'),
    (@emp_code, '2000-01-04 21:10'),
    -- 5. OT Night 3: 12:12, 12:55, 21:30
    (@emp_code, '2000-01-05 12:12'),
    (@emp_code, '2000-01-05 12:55'),
    (@emp_code, '2000-01-05 21:30'),
    -- 6. OT Early: 07:35, 12:05, 12:57, 02:02 (Next Day)
    (@emp_code, '2000-01-06 07:35'),
    (@emp_code, '2000-01-06 12:05'),
    (@emp_code, '2000-01-06 12:57'),
    (@emp_code, '2000-01-07 02:02'),
    -- 7. Missing Lunch 1: 07:38, 17:03
    (@emp_code, '2000-01-07 07:38'),
    (@emp_code, '2000-01-07 17:03'),
    -- 8. Missing Lunch 2: 07:50, 12:34, 17:05
    (@emp_code, '2000-01-08 07:50'),
    (@emp_code, '2000-01-08 12:34'),
    (@emp_code, '2000-01-08 17:05'),
    -- 9. Missing Lunch 3: 07:12, 14:39, 17:32
    (@emp_code, '2000-01-09 07:12'),
    (@emp_code, '2000-01-09 14:39'),
    (@emp_code, '2000-01-09 17:32'),
    -- 10. morning+OT: 07:44, 12:01, 12:49, 20:31
    (@emp_code, '2000-01-10 07:44'),
    (@emp_code, '2000-01-10 12:01'),
    (@emp_code, '2000-01-10 12:49'),
    (@emp_code, '2000-01-10 20:31'),
    -- 11. morning+MLunch+OT 1: 07:39, 20:11
    (@emp_code, '2000-01-11 07:39'),
    (@emp_code, '2000-01-11 20:11'),
    -- 12. morning+MLunch+OT 2: 07:23, 12:22, 20:58
    (@emp_code, '2000-01-12 07:23'),
    (@emp_code, '2000-01-12 12:22'),
    (@emp_code, '2000-01-12 20:58'),
    -- 13. morning+MLunch+OT 3: 07:23, 14:02, 20:05
    (@emp_code, '2000-01-13 07:23'),
    (@emp_code, '2000-01-13 14:02'),
    (@emp_code, '2000-01-13 20:05'),
    -- 14. morning+MLunch+early: 07:21, 02:08 (Next Day)
    (@emp_code, '2000-01-14 07:21'),
    (@emp_code, '2000-01-15 02:08'),
    -- 15. Half Day Morning 1: 07:41, 12:35
    (@emp_code, '2000-01-15 07:41'),
    (@emp_code, '2000-01-15 12:35'),
    -- 16. Half Day Morning 2: 07:41, 12:23, 12:51
    (@emp_code, '2000-01-16 07:41'),
    (@emp_code, '2000-01-16 12:23'),
    (@emp_code, '2000-01-16 12:51'),
    -- 17. Half Day Afternoon 1: 12:30, 17:05
    (@emp_code, '2000-01-17 12:30'),
    (@emp_code, '2000-01-17 17:05'),
    -- 18. Half Day Afternoon 2: 12:20, 12:50, 17:21
    (@emp_code, '2000-01-18 12:20'),
    (@emp_code, '2000-01-18 12:50'),
    (@emp_code, '2000-01-18 17:21'),
    -- 19. Late Morning: 08:20, 12:10, 13:01, 17:05
    (@emp_code, '2000-01-19 08:20'),
    (@emp_code, '2000-01-19 12:10'),
    (@emp_code, '2000-01-19 13:01'),
    (@emp_code, '2000-01-19 17:05'),
    -- 20. Late Lunch: 07:30, 12:01, 13:23, 17:03
    (@emp_code, '2000-01-20 07:30'),
    (@emp_code, '2000-01-20 12:01'),
    (@emp_code, '2000-01-20 13:23'),
    (@emp_code, '2000-01-20 17:03'),
    -- 21. Spam Morning: 07:50, 08:02, 08:05, 17:05
    (@emp_code, '2000-01-21 07:50'),
    (@emp_code, '2000-01-21 08:02'),
    (@emp_code, '2000-01-21 08:05'),
    (@emp_code, '2000-01-21 17:05'),
    -- 22. Spam Lunch Out: 07:30, 11:54, 12:05, 12:10, 17:09
    (@emp_code, '2000-01-22 07:30'),
    (@emp_code, '2000-01-22 11:54'),
    (@emp_code, '2000-01-22 12:05'),
    (@emp_code, '2000-01-22 12:10'),
    (@emp_code, '2000-01-22 17:09'),
    -- 23. Absent 1: 07:31
    (@emp_code, '2000-01-23 07:31'),
    -- 24. Absent 2: 17:30
    (@emp_code, '2000-01-24 17:30'),
    -- 25. Absent 3: 17:30, 20:02
    (@emp_code, '2000-01-25 17:30'),
    (@emp_code, '2000-01-25 20:02'),
    -- 26. Absent 4: 20:02
    (@emp_code, '2000-01-26 20:02'),
    -- 27. Absent 5: 12:01, 13:01
    (@emp_code, '2000-01-27 12:01'),
    (@emp_code, '2000-01-27 13:01'),
    -- 28. Absent 6: 11:15
    (@emp_code, '2000-01-28 11:15');