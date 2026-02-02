
  CREATE USER 'koranit'@'%' IDENTIFIED BY 'oeviivog';
  CREATE DATABASE payroll;
  GRANT ALL PRIVILEGES ON payroll.* TO 'koranit'@'%';
  FLUSH PRIVILEGES;

