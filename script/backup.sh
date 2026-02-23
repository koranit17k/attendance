#!/bin/bash
sudo mysqldump --routines --event payroll > /home/koranit/backup/payroll.sql
zip /home/koranit/backup/payroll /home/koranit/backup/payroll.sql
rm /home/koranit/backup/payroll.sql
