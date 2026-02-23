create user 'koranit' @'%' identified by 'oeviivog';

create database payroll;

grant all PRIVILEGES on payroll.* to 'koranit' @'%';

flush PRIVILEGES;
