#!/bin/sh

##############
############## IMPORTANT STEPS FOR RUNNING VAGRANT ON WINDOWS 7
############## Start up virtualbox in admin mode by right clicking on virtualbox and clicking "run as administrator" and then open up cygwin terminal as an administrator as well. Both programs must be run as admin for symlinking to work correctly on windows 7.
##############

SITE_DIR="/var/www/html" # The path to the web application on the server (default: /var/www/html)
SITE_PUB_DIR="/var/www/html/geoslim.local/public" # The path to the application public web folder.
VAGRANT_DATA_DIR="/vagrant/vagrant"
DB_NAME="geoname" #name of mysql DB.

# Install Applications
yum install -y git
yum install -y vim
yum install -y unzip.x86_64


# Install LAMP stack

# Apache
yum install -y httpd
service httpd start
chkconfig httpd on

# MySql / MariaDB
yum install -y mysql mysql-server
service mysqld start
chkconfig mysqld on
mysqladmin -u root password root # set mysql root password to root

# PHP
yum install -y php php-mysql php-pdo

# Create GeoSlim MySql user and database via install script (deprecated, now we create db named "geoname")
# php $VAGRANT_DATA_DIR/mysql/install.php


# Setting up Xdebug
yum install -y php-devel
yum install -y php-pear
yum install -y gcc gcc-c++ autoconf automake make
pecl install Xdebug

# Install xdebug.ini file.
ln -s $VAGRANT_DATA_DIR/php/xdebug.ini /etc/php.d/xdebug.ini

# Install configured php.ini
cp /etc/php.ini /etc/php.ini.orig
rm -f /etc/php.ini
ln -s $VAGRANT_DATA_DIR/php/php.ini /etc/php.ini

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#echo "Symlinking site ..."
rm -rf /var/www/html #delete html folder so the symlink will recreate it correctly (folder recreated as link).
ln -s /vagrant $SITE_DIR

#echo "Updating session folder permissions"
chown -R vagrant:vagrant /var/lib/php/session


# Install configured httpd.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
rm -f /etc/httpd/conf/httpd.conf
ln -s $VAGRANT_DATA_DIR/apache/httpd.conf /etc/httpd/conf/httpd.conf
ln -s $VAGRANT_DATA_DIR/apache/mod_rewrite_rules.conf /etc/httpd/conf.d/mod_rewrite_rules.conf

# Download geonames data and import into mysql
cd /vagrant/geoname-import/
sh geonames_importer.sh -a download-data
sh geonames_importer.sh -a create-db -u root -p root
sh geonames_importer.sh -a import-dumps -u root -p root
#mysql -u root -proot --local-infile=1 geoname < geonames_import_example_data.sql

# Restart services
service httpd restart
service mysqld restart

# Disabling the development firewall
systemctl stop firewalld.service

echo "Server provisioning complete!"
