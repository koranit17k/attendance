#!/bin/bash
sudo mysqldump --routines payroll > /home/koranit/backup/payroll.sql
zip /home/koranit/backup/payroll /home/koranit/backup/payroll.sql
