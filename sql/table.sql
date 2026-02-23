-- payroll.company definition
create table `company` (
    `comCode` varchar(2) not null,
    `comName` varchar(64) not null COMMENT 'บริษัท ชื่อ',
    `taxId` varchar(13) default null COMMENT 'เลขประจำตัวผู้เสียภาษี',
    `address` varchar(200) default null COMMENT 'ที่อยู่',
    `phone` varchar(100) default null COMMENT 'เบอร์โทรศัพท์ FAX มือถือ',
    `email1` varchar(30) default null COMMENT 'email 1',
    `email2` varchar(30) default null COMMENT 'email 2',
    `email3` varchar(30) default null COMMENT 'email 3',
    `yrPayroll` year(4) default year(curdate()) COMMENT 'ปีปัจจุบันที่กำลังทำงาน',
    `mnPayroll` tinyint(3) unsigned default month (curdate()) COMMENT 'เดือนปัจจุบันที่กำลังทำงาน',
    primary key (`comCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'บริษัท-ข้อมูลของแต่ละบริษัท';

-- payroll.deduction definition
create table `deduction` (
    `costPercent` decimal(4, 2) default null COMMENT 'หักค่าใช้จ่าย %',
    `costLimit` mediumint(8) unsigned default 0 COMMENT 'หักค่าใช้จ่ายไม่เกิน',
    `deductSelf` mediumint(8) unsigned default 0 COMMENT 'ค่าลดหย่อนส่วนตัว',
    `deductSpouse` mediumint(8) unsigned default 0 COMMENT 'ค่าลดหย่อนคู่สมรส',
    `deductChild` mediumint(8) unsigned default 0 COMMENT 'ค่าลดหย่อนบุตรธิดา',
    `deductChildEdu` mediumint(8) unsigned default 0 COMMENT 'ค่าลดหย่อนบุตรธิดา กำลังศึกษา'
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'ประเภทเงินหักลดหย่อน ของกรมสรรพากร';

-- payroll.holiday definition
create table `holiday` (
    `comCode` varchar(2) not null,
    `day` date not null COMMENT 'วันเดือนปีวันหยุด',
    `name` varchar(40) default null COMMENT 'ชื่อวันหยุด',
    primary key (`comCode`, `day`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'รายการวันหยุดประจำปี';

-- payroll.incometype definition
create table `incometype` (
    `inCode` varchar(2) not null COMMENT 'รหัสประเภทเงิน',
    `inName` varchar(30) default null COMMENT 'ชื่อประเภทเงิน',
    `inType` tinyint(4) default 1 COMMENT 'เป็นเงินได้ (1) หรือ เงินหัก (-1)',
    `isTax` tinyint(1) default 1 COMMENT 'คิดภาษีประจำปีหรือไม่',
    `isReset` tinyint(1) default 1 COMMENT 'reset เป็นศูนย์ ในเดือนต่อไป',
    `initLimit` decimal(9, 2) default 0.00 COMMENT 'มูลค่าจำกัด ไม่เกิน',
    `initPercent` decimal(4, 2) default 0.00 COMMENT 'มูลค่าคิดเป็นเปอร์เซ็นฐานเงินเดือน',
    primary key (`inCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'ประเภทเงินได้ เงินหัก';

-- payroll.logs definition
create table `logs` (
    `logNr` int(10) unsigned not null AUTO_INCREMENT,
    `logTime` timestamp not null default current_timestamp (),
    `logType` varchar(8) default null COMMENT 'insert delete update query rollback login logfail execute',
    `userId` varchar(16) default null COMMENT 'user ที่ส่งคำสั่งทำงาน',
    `program` varchar(20) default null COMMENT 'ชื่อโปรแกรม URL.to',
    `tableName` varchar(20) default null COMMENT 'ไฟล์ ที่มีผลกระทบ',
    `changed` varchar(256) default null COMMENT 'ข้อมูลการเปลี่ยนแปลง',
    `comCode` varchar(2) default null COMMENT 'บริษัท',
    primary key (`logNr`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'บันทึกการทำงาน';

-- payroll.taxrate definition
create table `taxrate` (
    `total` mediumint(8) unsigned not null COMMENT 'เงินได้ไม่เกิน /ปี',
    `rate` decimal(4, 2) default 0.00 COMMENT 'อัตราภาษีเปอร์เซ็น',
    primary key (`total`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'อัตราการคำนวณภาษี';

-- payroll.timecard definition
create table `timecard` (
    `scanCode` varchar(5) not null,
    `scanAt` datetime not null COMMENT 'วันที่และเวลาลงเวลา (ถึงนาที)',
    primary key (`scanCode`, `scanAt`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'รายการลงเวลา';

-- payroll.timetype definition
create table `timetype` (
    `timeCode` smallint(5) unsigned not null AUTO_INCREMENT,
    `descript` varchar(40) default null COMMENT 'คำอธิบายวิธีการคิดเวลางาน',
    `s1Start` varchar(5) default '08:00' COMMENT 'hh:mm',
    `s1Finish` varchar(5) default '12:00' COMMENT 'hh:mm',
    `s2Start` varchar(5) default '13:00' COMMENT 'hh:mm',
    `s2Finish` varchar(5) default '17:00' COMMENT 'hh:mm',
    `s3Start` varchar(5) default '18:00' COMMENT 'hh:mm',
    `s3Finish` varchar(5) default '23:00' COMMENT 'hh:mm',
    `otRate1` decimal(2, 1) default 1.5 COMMENT 'อัตรา ot วันทำงาน',
    `otRate2` decimal(2, 1) default 2.0 COMMENT 'อัตรา ot วันหยุด',
    `otRate3` decimal(2, 1) default 3.0 COMMENT 'อัตรา ot หลังเที่ยงคืน',
    `allowance1` decimal(9, 2) default 0.00 COMMENT 'เบี้ยเลี้ยง 1',
    `allowance2` decimal(9, 2) default 0.00 COMMENT 'เบี้ยเลี้ยง 2',
    `weekDay` varchar(7) default '123456' COMMENT 'วันทำงานในสัปดาห์ 1=จันทร์ ... 7=อาทิตย์',
    `flexible` smallint(5) unsigned not null default 0 COMMENT 'ระยะเวลาพักยืดหยุ่น (นาที)',
    primary key (`timeCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'กำหนดค่าวิธีคิดเวลาทำงาน เบี้ยเลี้ยง OT';

-- payroll.employee definition
create table `employee` (
    `comCode` varchar(2) not null COMMENT 'รหัสบริษัท',
    `empCode` smallint(5) unsigned not null COMMENT 'รหัสพนักงาน',
    `taxId` varchar(17) default null COMMENT 'เลขประจำตัวผู้เสียภาษี เลขบัตรประชาชน',
    `prefix` varchar(16) default null COMMENT 'คำนำหน้าชื่อ',
    `name` varchar(20) default null COMMENT 'ชื่อจริง',
    `surName` varchar(30) default null COMMENT 'นามสกุล',
    `nickName` varchar(20) default null COMMENT 'ชื่อเล่น',
    `birthDate` date default null COMMENT 'วันเดือนปีเกิด',
    `department` varchar(20) default null COMMENT 'แผนก ฝ่าย',
    `timeCode` smallint(5) unsigned default null COMMENT 'timetype code',
    `beginDate` date default null COMMENT 'วันที่เริ่มทำงาน',
    `endDate` date default null COMMENT 'วันที่สิ้นสุดทำงาน',
    `empType` varchar(10) default null COMMENT 'ประเภทพนักงาน ประจำ/ชั่วคราว/ฝึกงาน',
    `bankAccount` varchar(20) default null COMMENT 'เลขที่บัญชีธนาคาร',
    `address` varchar(100) default null COMMENT 'ที่อยู่',
    `phone` varchar(20) default null COMMENT 'เบอร์โทรศัพท์',
    `childAll` tinyint(3) unsigned default 0 COMMENT 'จำนวนบุตรทั้งหมด',
    `childEdu` tinyint(3) unsigned default 0 COMMENT 'จำนวนบุตรกำลังศึกษา',
    `isSpouse` tinyint(1) default 0 COMMENT 'ลดหย่อนคู่สมรสหรือไม่',
    `isChildShare` tinyint(1) default 0 COMMENT 'ลดหย่อนบุตรแบ่งครึ่งหรือไม่',
    `isExcSocialIns` tinyint(1) default 0 COMMENT 'ยกเว้นประกันสังคมหรือไม่',
    `deductInsure` decimal(9, 2) default 0.00 COMMENT 'ลดหย่อนประกันชีวิต',
    `deductHome` decimal(9, 2) default 0.00 COMMENT 'ลดหย่อนผ่อนที่อยู่อาศัย',
    `deductElse` decimal(9, 2) default 0.00 COMMENT 'ลดหย่อนอื่นๆ',
    `scanCode` varchar(5) default null COMMENT 'รหัสสแกนลายนิ้วมือ',
    primary key (`comCode`, `empCode`),
    unique key `comCode` (`comCode`, `scanCode`),
    key `timeCode` (`timeCode`),
    constraint `employee_ibfk_1` foreign key (`comCode`) references `company` (`comCode`),
    constraint `employee_ibfk_2` foreign key (`timeCode`) references `timetype` (`timeCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'พนักงาน ลูกจ้าง';

-- payroll.payroll definition
create table `payroll` (
    `yr` year(4) not null COMMENT 'ปี',
    `mo` tinyint(3) unsigned not null COMMENT 'เดือน',
    `comCode` varchar(2) not null,
    `empCode` smallint(5) unsigned not null,
    `inCode` varchar(2) not null,
    `value` decimal(9, 2) default 0.00 COMMENT 'จำนวนเงิน',
    primary key (`yr`, `mo`, `comCode`, `empCode`, `inCode`),
    key `comCode` (`comCode`, `empCode`),
    key `inCode` (`inCode`),
    constraint `payroll_ibfk_1` foreign key (`comCode`, `empCode`) references `employee` (`comCode`, `empCode`),
    constraint `payroll_ibfk_2` foreign key (`inCode`) references `incometype` (`inCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'รายการจ่ายเงินเดือนในแต่ละเดือน';

-- payroll.salary definition
create table `salary` (
    `comCode` varchar(2) not null,
    `empCode` smallint(5) unsigned not null,
    `inCode` varchar(2) not null,
    `value` decimal(9, 2) default null COMMENT 'จำนวนเงิน',
    `duration` tinyint(3) unsigned default 1 COMMENT 'จำนวนงวดที่จ่าย',
    `yrBegin` year(4) default 0000 COMMENT 'ปีเริ่มจ่าย',
    `moBegin` tinyint(3) unsigned default 0 COMMENT 'เดือนเริ่มจ่าย',
    primary key (`comCode`, `empCode`, `inCode`),
    key `inCode` (`inCode`),
    constraint `salary_ibfk_1` foreign key (`comCode`, `empCode`) references `employee` (`comCode`, `empCode`),
    constraint `salary_ibfk_2` foreign key (`inCode`) references `incometype` (`inCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'ตั้งค่าเงินเดือน';

-- payroll.users definition
create table `users` (
    `id` varchar(16) not null,
    `name` varchar(40) default null COMMENT 'ชื่อ นามสกุล',
    `descript` varchar(60) default null COMMENT 'คำอธิบายหน้าที่',
    `level` tinyint(4) not null default 0 COMMENT 'ระดับการใช้งาน 0 - 9 LEVELS /shared/util.ts ',
    `role` varchar(16) default null COMMENT 'หน้าที่',
    `passwd` varchar(32) default null COMMENT 'รหัสผ่านเข้าใช้งาน',
    `passwdTime` timestamp null default null COMMENT 'วันที่ตั้งรหัสผ่าน',
    `created` date default curdate() COMMENT 'วันที่สร้างผู้ใช้',
    `stoped` date default null COMMENT 'วันที่สิ้นสุดการทำงาน',
    `comCode` varchar(2) not null default '01' COMMENT 'บริษัทที่ใช้งาน',
    primary key (`id`),
    key `comCode` (`comCode`),
    constraint `users_ibfk_1` foreign key (`comCode`) references `company` (`comCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'ผู้ใช้งานระบบ';

-- payroll.attendance definition
create table `attendance` (
    `comCode` varchar(2) not null,
    `empCode` smallint(5) unsigned not null,
    `scanCode` varchar(5) default null COMMENT 'รหัสสแกนลายนิ้วมือ',
    `dateAt` varchar(10) not null COMMENT 'วันเดือนปีทำงาน',
    `status` varchar(20) default null COMMENT 'สถานะ',
    `day_case` varchar(13) default null COMMENT 'ดูวัน',
    `lunch_case` varchar(16) default null COMMENT 'ดูพักเที่ยง',
    `night_case` varchar(13) default null COMMENT 'ดูค่ำ',
    `early` varchar(10) default null COMMENT 'เวลาออก ข้ามวัน 00:00 - 06:00 (last)',
    `morning` varchar(10) default null COMMENT 'เวลาเข้า เช้า 06:00 - 10:00 (last)',
    `lunch_out` varchar(10) default null COMMENT 'เวลาพักเที่ยง 11:00 - 13:30 (first)',
    `lunch_in` varchar(10) default null COMMENT 'เวลากลับเที่ยง 11:30 - 14:00 (last)',
    `evening` varchar(10) default null COMMENT 'เวลาออก เย็น 16:00 - 18:00 (last)',
    `night` varchar(10) default null COMMENT 'เวลาออก ค่ำ 19:00 - 24:00 (last)',
    `lunch_minutes` smallint default null COMMENT 'จำนวนนาทีพักกลางวัน',
    `late_morning_minutes` smallint default null COMMENT 'จำนวนนาทีมาสาย เช้า',
    `late_lunch_minutes` smallint default null COMMENT 'จำนวนนาทีมาสาย บ่าย/เที่ยง/ออกก่อนเวลางาน',
    `work_minutes` smallint default null COMMENT 'จำนวนนาทีทำงาน',
    `ot_total_minutes` smallint default null COMMENT 'จำนวนนาทีล่วงเวลา',
    `count` tinyint COMMENT 'จำนวนครั้งที่สแกน',
    `rawTime` varchar(60) default null COMMENT 'เวลาที่สแกน',
    `reason` VARCHAR(255),
    `status_check` ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED') default 'DRAFT',
    `modified_by` VARCHAR(50) null,
    `modified_at` DATETIME default current_timestamp,
    `approved_by` VARCHAR(50) null,
    `approved_at` DATETIME null,
    primary key (`comCode`, `empCode`, `dateAt`),
    constraint `attendance_ibfk_1` foreign key (`comCode`, `empCode`) references `employee` (`comCode`, `empCode`)
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'วันที่มาทำงาน เวลาเข้าออกงาน ตามการสแกน';

-- payroll.permission definition
create table `permission` (
    `comCode` varchar(2) not null,
    `userId` varchar(16) not null,
    `program` varchar(20) not null,
    `level` tinyint(4) not null default 0 COMMENT 'ระดับการใช้งาน 0 - 9 ใช้ -1 ในการลบ',
    `used` int(10) unsigned not null default 0 COMMENT 'จำนวนครั้งที่ใช้',
    primary key (`comCode`, `userId`, `program`),
    key `userId` (`userId`),
    constraint `permission_ibfk_1` foreign key (`comCode`) references `company` (`comCode`),
    constraint `permission_ibfk_2` foreign key (`userId`) references `users` (`id`) on delete cascade
) ENGINE = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_general_ci COMMENT = 'สิทธิการใช้โปรแกรม';
