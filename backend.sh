#!/bin/bash
DB_PSW='psw123'

# MEmcache
yum install epel-release -y
yum install memcached -y
systemctl start memcached
systemctl enable memcached
systemctl status memcached
memcached -p 11211 -U 11111 -u memcached -d

# Rabbit
yum install socat -y
yum install erlang -y
yum install wget -y
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum update
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
systemctl status rabbitmq-server
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
rabbitmqctl add_user rabbit bunny
rabbitmqctl set_user_tags rabbit administrator
systemctl restart rabbitmq-server

# Mysql
yum install mariadb-server -y

#mysql_secure_installation
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf

# starting & enabling mariadb-server
systemctl start mariadb
systemctl enable mariadb

#restore the dump file for the application
mysqladmin -u root password "$DB_PSW"
mysql -u root -p"$DB_PSW" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PSW') WHERE User='root'"
mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DB_PSW" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DB_PSW" -e "FLUSH PRIVILEGES"
mysql -u root -p"$DB_PSW" -e "create database accounts"
mysql -u root -p"$DB_PSW" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'psw123'"
mysql -u root -p"$DB_PSW" -e "grant all privileges on accounts.* TO 'admin'@'app01' identified by 'psw123'"
mysql -u root -p"$DB_PSW" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql
mysql -u root -p"$DB_PSW" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
systemctl restart mariadb