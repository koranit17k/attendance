-- Seed Test Data for Attendance Scenarios (Year 2000)
set
    @test_year = '2000';

set
    @emp_code = '99999';

-- Clear existing data
delete from timecard
where
    scanCode = @emp_code
    and YEAR(scanAt) = @test_year
    and MONTH (scanAt) = 1;

insert into
    timecard (scanCode, scanAt)
values -- 1. Normal 1
    (@emp_code, '2000-01-01 07:52:00'),
    (@emp_code, '2000-01-01 12:12:00'),
    (@emp_code, '2000-01-01 13:12:00'),
    (@emp_code, '2000-01-01 17:05:00'),
    -- 2. Normal 2
    (@emp_code, '2000-01-02 07:50:00'),
    (@emp_code, '2000-01-02 12:14:00'),
    (@emp_code, '2000-01-02 12:45:00'),
    (@emp_code, '2000-01-02 17:30:00'),
    -- 3. Normal 3
    (@emp_code, '2000-01-03 07:50:00'),
    (@emp_code, '2000-01-03 12:14:00'),
    (@emp_code, '2000-01-03 12:45:00'),
    (@emp_code, '2000-01-03 16:30:00'),
    -- 4. OT Night 1
    (@emp_code, '2000-01-04 06:54:00'),
    (@emp_code, '2000-01-04 12:32:00'),
    (@emp_code, '2000-01-04 12:54:00'),
    (@emp_code, '2000-01-04 17:31:00'),
    (@emp_code, '2000-01-04 21:12:00'),
    -- 5. OT Night 2
    (@emp_code, '2000-01-05 07:32:00'),
    (@emp_code, '2000-01-05 12:10:00'),
    (@emp_code, '2000-01-05 12:55:00'),
    (@emp_code, '2000-01-05 21:10:00'),
    -- 6. OT Night 3
    (@emp_code, '2000-01-06 12:12:00'),
    (@emp_code, '2000-01-06 12:55:00'),
    (@emp_code, '2000-01-06 21:30:00'),
    -- 7. OT Early
    (@emp_code, '2000-01-07 07:35:00'),
    (@emp_code, '2000-01-07 12:05:00'),
    (@emp_code, '2000-01-07 12:57:00'),
    (@emp_code, '2000-01-08 02:02:00'),
    -- 8. Missing Lunch 1
    (@emp_code, '2000-01-08 07:38:00'),
    (@emp_code, '2000-01-08 17:03:00'),
    -- 9. Missing Lunch 2
    (@emp_code, '2000-01-09 07:50:00'),
    (@emp_code, '2000-01-09 12:34:00'),
    (@emp_code, '2000-01-09 17:05:00'),
    -- 10. Missing Lunch 3
    (@emp_code, '2000-01-10 07:12:00'),
    (@emp_code, '2000-01-10 14:39:00'),
    (@emp_code, '2000-01-10 17:32:00'),
    -- 11. morning+OT
    (@emp_code, '2000-01-11 07:44:00'),
    (@emp_code, '2000-01-11 12:01:00'),
    (@emp_code, '2000-01-11 12:49:00'),
    (@emp_code, '2000-01-11 20:31:00'),
    -- 12. morning+MLunch+OT 1
    (@emp_code, '2000-01-12 07:39:00'),
    (@emp_code, '2000-01-12 20:11:00'),
    -- 13. morning+MLunch+OT 2
    (@emp_code, '2000-01-13 07:23:00'),
    (@emp_code, '2000-01-13 12:22:00'),
    (@emp_code, '2000-01-13 20:58:00'),
    -- 14. morning+MLunch+OT 3
    (@emp_code, '2000-01-14 07:23:00'),
    (@emp_code, '2000-01-14 14:02:00'),
    (@emp_code, '2000-01-14 20:05:00'),
    -- 15. morning+MLunch+early
    (@emp_code, '2000-01-15 07:21:00'),
    (@emp_code, '2000-01-16 02:08:00'),
    -- 16. Half Day Morning 1 (Late2=15 -> Leave 11:45)
    (@emp_code, '2000-01-16 07:41:00'),
    (@emp_code, '2000-01-16 11:45:00'),
    -- 17. Half Day Morning 2
    (@emp_code, '2000-01-17 07:41:00'),
    (@emp_code, '2000-01-17 12:23:00'),
    (@emp_code, '2000-01-17 12:51:00'),
    -- 18. Half Day Afternoon 1 (Late2=10 -> Enter 13:10)
    (@emp_code, '2000-01-18 13:10:00'),
    (@emp_code, '2000-01-18 17:05:00'),
    -- 19. Half Day Afternoon 2 (Late2=10 -> Leave 16:50)
    (@emp_code, '2000-01-19 12:20:00'),
    (@emp_code, '2000-01-19 12:50:00'),
    (@emp_code, '2000-01-19 16:50:00'),
    -- 20. Late Morning
    (@emp_code, '2000-01-20 08:20:00'),
    (@emp_code, '2000-01-20 12:10:00'),
    (@emp_code, '2000-01-20 13:01:00'),
    (@emp_code, '2000-01-20 16:55:00'),
    -- 21. Late Morning Half (Late1=30, Late2=10) -> Morn 08:30. Late2=10?? Leave 12:20?? 
    -- If Leave 12:20 is "early", but 12:00 is limit? Maybe Late2=10 for 12:20 means they stayed too long? No.
    -- Maybe user implies Late2=10 for Case 21 is a typo in their table OR expected LEAVE time is 12:30?
    -- I will just put the data as is: 08:30, 12:20.
    (@emp_code, '2000-01-21 08:30:00'),
    (@emp_code, '2000-01-21 12:20:00'),
    -- 22. Late Lunch
    (@emp_code, '2000-01-22 07:30:00'),
    (@emp_code, '2000-01-22 12:01:00'),
    (@emp_code, '2000-01-22 13:23:00'),
    (@emp_code, '2000-01-22 17:03:00'),
    -- 23. Spam Morning
    (@emp_code, '2000-01-23 07:50:00'),
    (@emp_code, '2000-01-23 08:02:00'),
    (@emp_code, '2000-01-23 08:05:00'),
    (@emp_code, '2000-01-23 16:55:00'),
    -- 24. Spam Lunch Out
    (@emp_code, '2000-01-24 07:30:00'),
    (@emp_code, '2000-01-24 11:54:00'),
    (@emp_code, '2000-01-24 12:05:00'),
    (@emp_code, '2000-01-24 12:10:00'),
    (@emp_code, '2000-01-24 17:09:00'),
    -- 25. Absent 1
    (@emp_code, '2000-01-25 07:31:00'),
    -- 26. Absent 2
    (@emp_code, '2000-01-26 17:30:00'),
    -- 27. Absent 3
    (@emp_code, '2000-01-27 17:30:00'),
    (@emp_code, '2000-01-27 20:02:00'),
    -- 28. Absent 4
    (@emp_code, '2000-01-28 20:02:00'),
    -- 29. Absent 5
    (@emp_code, '2000-01-29 12:01:00'),
    (@emp_code, '2000-01-29 13:01:00'),
    -- 30. Absent 6
    (@emp_code, '2000-01-30 11:15:00');
