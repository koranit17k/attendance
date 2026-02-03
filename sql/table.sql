-- payroll.company definition
CREATE TABLE `company` (
    `comCode` varchar(2) NOT NULL,
    `comName` varchar(64) NOT NULL COMMENT 'บริษัท ชื่อ',
    `taxId` varchar(13) DEFAULT NULL COMMENT 'เลขประจำตัวผู้เสียภาษี',
    `address` varchar(200) DEFAULT NULL COMMENT 'ที่อยู่',
    `phone` varchar(100) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์ FAX มือถือ',
    `email1` varchar(30) DEFAULT NULL COMMENT 'email 1',
    `email2` varchar(30) DEFAULT NULL COMMENT 'email 2',
    `email3` varchar(30) DEFAULT NULL COMMENT 'email 3',
    `yrPayroll` year(4) DEFAULT year(curdate()) COMMENT 'ปีปัจจุบันที่กำลังทำงาน',
    `mnPayroll` tinyint(3) unsigned DEFAULT month(curdate()) COMMENT 'เดือนปัจจุบันที่กำลังทำงาน',
    PRIMARY KEY (`comCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'บริษัท-ข้อมูลของแต่ละบริษัท';
-- payroll.deduction definition
CREATE TABLE `deduction` (
    `costPercent` decimal(4, 2) DEFAULT NULL COMMENT 'หักค่าใช้จ่าย %',
    `costLimit` mediumint(8) unsigned DEFAULT 0 COMMENT 'หักค่าใช้จ่ายไม่เกิน',
    `deductSelf` mediumint(8) unsigned DEFAULT 0 COMMENT 'ค่าลดหย่อนส่วนตัว',
    `deductSpouse` mediumint(8) unsigned DEFAULT 0 COMMENT 'ค่าลดหย่อนคู่สมรส',
    `deductChild` mediumint(8) unsigned DEFAULT 0 COMMENT 'ค่าลดหย่อนบุตรธิดา',
    `deductChildEdu` mediumint(8) unsigned DEFAULT 0 COMMENT 'ค่าลดหย่อนบุตรธิดา กำลังศึกษา'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ประเภทเงินหักลดหย่อน ของกรมสรรพากร';
-- payroll.holiday definition
CREATE TABLE `holiday` (
    `comCode` varchar(2) NOT NULL,
    `day` date NOT NULL COMMENT 'วันเดือนปีวันหยุด',
    `name` varchar(40) DEFAULT NULL COMMENT 'ชื่อวันหยุด',
    PRIMARY KEY (`comCode`, `day`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'รายการวันหยุดประจำปี';
-- payroll.incometype definition
CREATE TABLE `incometype` (
    `inCode` varchar(2) NOT NULL COMMENT 'รหัสประเภทเงิน',
    `inName` varchar(30) DEFAULT NULL COMMENT 'ชื่อประเภทเงิน',
    `inType` tinyint(4) DEFAULT 1 COMMENT 'เป็นเงินได้ (1) หรือ เงินหัก (-1)',
    `isTax` tinyint(1) DEFAULT 1 COMMENT 'คิดภาษีประจำปีหรือไม่',
    `isReset` tinyint(1) DEFAULT 1 COMMENT 'reset เป็นศูนย์ ในเดือนต่อไป',
    `initLimit` decimal(9, 2) DEFAULT 0.00 COMMENT 'มูลค่าจำกัด ไม่เกิน',
    `initPercent` decimal(4, 2) DEFAULT 0.00 COMMENT 'มูลค่าคิดเป็นเปอร์เซ็นฐานเงินเดือน',
    PRIMARY KEY (`inCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ประเภทเงินได้ เงินหัก';
-- payroll.logs definition
CREATE TABLE `logs` (
    `logNr` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `logTime` timestamp NOT NULL DEFAULT current_timestamp(),
    `logType` varchar(8) DEFAULT NULL COMMENT 'insert delete update query rollback login logfail execute',
    `userId` varchar(16) DEFAULT NULL COMMENT 'user ที่ส่งคำสั่งทำงาน',
    `program` varchar(20) DEFAULT NULL COMMENT 'ชื่อโปรแกรม URL.to',
    `tableName` varchar(20) DEFAULT NULL COMMENT 'ไฟล์ ที่มีผลกระทบ',
    `changed` varchar(256) DEFAULT NULL COMMENT 'ข้อมูลการเปลี่ยนแปลง',
    `comCode` varchar(2) DEFAULT NULL COMMENT 'บริษัท',
    PRIMARY KEY (`logNr`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'บันทึกการทำงาน';
-- payroll.taxrate definition
CREATE TABLE `taxrate` (
    `total` mediumint(8) unsigned NOT NULL COMMENT 'เงินได้ไม่เกิน /ปี',
    `rate` decimal(4, 2) DEFAULT 0.00 COMMENT 'อัตราภาษีเปอร์เซ็น',
    PRIMARY KEY (`total`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'อัตราการคำนวณภาษี';
-- payroll.timecard definition
CREATE TABLE `timecard` (
    `scanCode` varchar(5) NOT NULL,
    `scanAt` datetime NOT NULL COMMENT 'วันที่และเวลาลงเวลา (ถึงนาที)',
    PRIMARY KEY (`scanCode`, `scanAt`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'รายการลงเวลา';
-- payroll.timetype definition
CREATE TABLE `timetype` (
    `timeCode` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
    `descript` varchar(40) DEFAULT NULL COMMENT 'คำอธิบายวิธีการคิดเวลางาน',
    `s1Start` varchar(5) DEFAULT '08:00' COMMENT 'hh:mm',
    `s1Finish` varchar(5) DEFAULT '12:00' COMMENT 'hh:mm',
    `s2Start` varchar(5) DEFAULT '13:00' COMMENT 'hh:mm',
    `s2Finish` varchar(5) DEFAULT '17:00' COMMENT 'hh:mm',
    `s3Start` varchar(5) DEFAULT '18:00' COMMENT 'hh:mm',
    `s3Finish` varchar(5) DEFAULT '23:00' COMMENT 'hh:mm',
    `otRate1` decimal(2, 1) DEFAULT 1.5 COMMENT 'อัตรา ot วันทำงาน',
    `otRate2` decimal(2, 1) DEFAULT 2.0 COMMENT 'อัตรา ot วันหยุด',
    `otRate3` decimal(2, 1) DEFAULT 3.0 COMMENT 'อัตรา ot หลังเที่ยงคืน',
    `allowance1` decimal(9, 2) DEFAULT 0.00 COMMENT 'เบี้ยเลี้ยง 1',
    `allowance2` decimal(9, 2) DEFAULT 0.00 COMMENT 'เบี้ยเลี้ยง 2',
    `weekDay` varchar(7) DEFAULT '123456' COMMENT 'วันทำงานในสัปดาห์ 1=จันทร์ ... 7=อาทิตย์',
    `flexible` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT 'ระยะเวลาพักยืดหยุ่น (นาที)',
    PRIMARY KEY (`timeCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'กำหนดค่าวิธีคิดเวลาทำงาน เบี้ยเลี้ยง OT';
-- payroll.employee definition
CREATE TABLE `employee` (
    `comCode` varchar(2) NOT NULL COMMENT 'รหัสบริษัท',
    `empCode` smallint(5) unsigned NOT NULL COMMENT 'รหัสพนักงาน',
    `taxId` varchar(17) DEFAULT NULL COMMENT 'เลขประจำตัวผู้เสียภาษี เลขบัตรประชาชน',
    `prefix` varchar(16) DEFAULT NULL COMMENT 'คำนำหน้าชื่อ',
    `name` varchar(20) DEFAULT NULL COMMENT 'ชื่อจริง',
    `surName` varchar(30) DEFAULT NULL COMMENT 'นามสกุล',
    `nickName` varchar(20) DEFAULT NULL COMMENT 'ชื่อเล่น',
    `birthDate` date DEFAULT NULL COMMENT 'วันเดือนปีเกิด',
    `department` varchar(20) DEFAULT NULL COMMENT 'แผนก ฝ่าย',
    `timeCode` smallint(5) unsigned DEFAULT NULL COMMENT 'timetype code',
    `beginDate` date DEFAULT NULL COMMENT 'วันที่เริ่มทำงาน',
    `endDate` date DEFAULT NULL COMMENT 'วันที่สิ้นสุดทำงาน',
    `empType` varchar(10) DEFAULT NULL COMMENT 'ประเภทพนักงาน ประจำ/ชั่วคราว/ฝึกงาน',
    `bankAccount` varchar(20) DEFAULT NULL COMMENT 'เลขที่บัญชีธนาคาร',
    `address` varchar(100) DEFAULT NULL COMMENT 'ที่อยู่',
    `phone` varchar(20) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์',
    `childAll` tinyint(3) unsigned DEFAULT 0 COMMENT 'จำนวนบุตรทั้งหมด',
    `childEdu` tinyint(3) unsigned DEFAULT 0 COMMENT 'จำนวนบุตรกำลังศึกษา',
    `isSpouse` tinyint(1) DEFAULT 0 COMMENT 'ลดหย่อนคู่สมรสหรือไม่',
    `isChildShare` tinyint(1) DEFAULT 0 COMMENT 'ลดหย่อนบุตรแบ่งครึ่งหรือไม่',
    `isExcSocialIns` tinyint(1) DEFAULT 0 COMMENT 'ยกเว้นประกันสังคมหรือไม่',
    `deductInsure` decimal(9, 2) DEFAULT 0.00 COMMENT 'ลดหย่อนประกันชีวิต',
    `deductHome` decimal(9, 2) DEFAULT 0.00 COMMENT 'ลดหย่อนผ่อนที่อยู่อาศัย',
    `deductElse` decimal(9, 2) DEFAULT 0.00 COMMENT 'ลดหย่อนอื่นๆ',
    `scanCode` varchar(5) DEFAULT NULL COMMENT 'รหัสสแกนลายนิ้วมือ',
    PRIMARY KEY (`comCode`, `empCode`),
    UNIQUE KEY `comCode` (`comCode`, `scanCode`),
    KEY `timeCode` (`timeCode`),
    CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`comCode`) REFERENCES `company` (`comCode`),
    CONSTRAINT `employee_ibfk_2` FOREIGN KEY (`timeCode`) REFERENCES `timetype` (`timeCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'พนักงาน ลูกจ้าง';
-- payroll.payroll definition
CREATE TABLE `payroll` (
    `yr` year(4) NOT NULL COMMENT 'ปี',
    `mo` tinyint(3) unsigned NOT NULL COMMENT 'เดือน',
    `comCode` varchar(2) NOT NULL,
    `empCode` smallint(5) unsigned NOT NULL,
    `inCode` varchar(2) NOT NULL,
    `value` decimal(9, 2) DEFAULT 0.00 COMMENT 'จำนวนเงิน',
    PRIMARY KEY (`yr`, `mo`, `comCode`, `empCode`, `inCode`),
    KEY `comCode` (`comCode`, `empCode`),
    KEY `inCode` (`inCode`),
    CONSTRAINT `payroll_ibfk_1` FOREIGN KEY (`comCode`, `empCode`) REFERENCES `employee` (`comCode`, `empCode`),
    CONSTRAINT `payroll_ibfk_2` FOREIGN KEY (`inCode`) REFERENCES `incometype` (`inCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'รายการจ่ายเงินเดือนในแต่ละเดือน';
-- payroll.salary definition
CREATE TABLE `salary` (
    `comCode` varchar(2) NOT NULL,
    `empCode` smallint(5) unsigned NOT NULL,
    `inCode` varchar(2) NOT NULL,
    `value` decimal(9, 2) DEFAULT NULL COMMENT 'จำนวนเงิน',
    `duration` tinyint(3) unsigned DEFAULT 1 COMMENT 'จำนวนงวดที่จ่าย',
    `yrBegin` year(4) DEFAULT 0000 COMMENT 'ปีเริ่มจ่าย',
    `moBegin` tinyint(3) unsigned DEFAULT 0 COMMENT 'เดือนเริ่มจ่าย',
    PRIMARY KEY (`comCode`, `empCode`, `inCode`),
    KEY `inCode` (`inCode`),
    CONSTRAINT `salary_ibfk_1` FOREIGN KEY (`comCode`, `empCode`) REFERENCES `employee` (`comCode`, `empCode`),
    CONSTRAINT `salary_ibfk_2` FOREIGN KEY (`inCode`) REFERENCES `incometype` (`inCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ตั้งค่าเงินเดือน';
-- payroll.users definition
CREATE TABLE `users` (
    `id` varchar(16) NOT NULL,
    `name` varchar(40) DEFAULT NULL COMMENT 'ชื่อ นามสกุล',
    `descript` varchar(60) DEFAULT NULL COMMENT 'คำอธิบายหน้าที่',
    `level` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'ระดับการใช้งาน 0 - 9 LEVELS /shared/util.ts ',
    `role` varchar(16) DEFAULT NULL COMMENT 'หน้าที่',
    `passwd` varchar(32) DEFAULT NULL COMMENT 'รหัสผ่านเข้าใช้งาน',
    `passwdTime` timestamp NULL DEFAULT NULL COMMENT 'วันที่ตั้งรหัสผ่าน',
    `created` date DEFAULT curdate() COMMENT 'วันที่สร้างผู้ใช้',
    `stoped` date DEFAULT NULL COMMENT 'วันที่สิ้นสุดการทำงาน',
    `comCode` varchar(2) NOT NULL DEFAULT '01' COMMENT 'บริษัทที่ใช้งาน',
    PRIMARY KEY (`id`),
    KEY `comCode` (`comCode`),
    CONSTRAINT `users_ibfk_1` FOREIGN KEY (`comCode`) REFERENCES `company` (`comCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ผู้ใช้งานระบบ';
-- payroll.attendance definition
CREATE TABLE `attendance` (
    `comCode` varchar(2) NOT NULL,
    `empCode` smallint(5) unsigned NOT NULL,
    `dateTxt` varchar(10) NOT NULL COMMENT 'วันเดือนปีทำงาน',
    `morning` varchar(5) DEFAULT NULL COMMENT 'เวลาเข้า เช้า 06:00 - 10:00 (last)',
    `evening` varchar(5) DEFAULT NULL COMMENT 'เวลาออก เย็น 16:00 - 18:00 (last)',
    `night` varchar(5) DEFAULT NULL COMMENT 'เวลาออก ค่ำ 19:00 - 24:00 (last)',
    `early` varchar(5) DEFAULT NULL COMMENT 'เวลาออก ข้ามวัน 00:00 - 06:00 (last)',
    `lunch_out` varchar(5) DEFAULT NULL COMMENT 'เวลาพักเที่ยง 11:00 - 13:30 (first)',
    `lunch_in` varchar(5) DEFAULT NULL COMMENT 'เวลากลับเที่ยง 11:30 - 14:00 (last)',
    `lateMin1` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนนาทีมาสาย เช้า',
    `lateMin2` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนนาทีมาสาย บ่าย/เที่ยง',
    `workMin` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนนาทีทำงาน',
    `otMin` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนนาทีล่วงเวลา',
    `lunchMin` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนนาทีพักกลางวัน',
    `scanCount` smallint(5) unsigned DEFAULT NULL COMMENT 'จำนวนการสแกน',
    `status` varchar(20) DEFAULT NULL COMMENT 'สถานะเวลางาน',
    PRIMARY KEY (`comCode`, `empCode`, `dateTxt`),
    CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`comCode`, `empCode`) REFERENCES `employee` (`comCode`, `empCode`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'วันที่มาทำงาน เวลาเข้าออกงาน ตามการสแกน';
-- payroll.permission definition
CREATE TABLE `permission` (
    `comCode` varchar(2) NOT NULL,
    `userId` varchar(16) NOT NULL,
    `program` varchar(20) NOT NULL,
    `level` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'ระดับการใช้งาน 0 - 9 ใช้ -1 ในการลบ',
    `used` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'จำนวนครั้งที่ใช้',
    PRIMARY KEY (`comCode`, `userId`, `program`),
    KEY `userId` (`userId`),
    CONSTRAINT `permission_ibfk_1` FOREIGN KEY (`comCode`) REFERENCES `company` (`comCode`),
    CONSTRAINT `permission_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'สิทธิการใช้โปรแกรม';