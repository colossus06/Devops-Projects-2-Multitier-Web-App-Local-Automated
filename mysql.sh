#!/bin/bash
DB_PSW='psw123'
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y


# starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git
#restore the dump file for the application
sudo mysqladmin -u root password "$DB_PSW"
sudo mysql -u root -p"$DB_PSW" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PSW') WHERE User='root'"
sudo mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DB_PSW" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DB_PSW" -e "create database accounts"
sudo mysql -u root -p"$DB_PSW" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'psw123'"
sudo mysql -u root -p"$DB_PSW" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'psw123'"
sudo mysql -u root -p"$DB_PSW" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DB_PSW" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
sudo systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
