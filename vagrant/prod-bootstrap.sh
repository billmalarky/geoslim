#!/bin/sh

#Before running this create a dir "/var/repositories/geoname" to hold the repository files


SITE_DIR="/var/www/html" # The path to the web application on the server (default: /var/www/html)
REPO_DIR="/var/repositories/geoname" # The path to the repository on the server

# Install Applications
#yum install -y git #git should already be installed to pull down repo on prod server.
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

# Create Geoname MySql user and database via install script
php $REPO_DIR/vagrant/mysql/install.php


# Setting up Xdebug
yum install -y php-devel
yum install -y php-pear
yum install -y gcc gcc-c++ autoconf automake make
pecl install Xdebug

# Install xdebug.ini file.
ln -s $REPO_DIR/vagrant/php/xdebug.ini /etc/php.d/xdebug.ini

# Install configured php.ini
cp /etc/php.ini /etc/php.ini.orig
rm -f /etc/php.ini
ln -s $REPO_DIR/vagrant/php/php.ini /etc/php.ini

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#echo "Symlinking site ..."
rm -rf $SITE_DIR #delete html folder so the symlink will recreate it correctly (folder recreated as link).
ln -s $REPO_DIR $SITE_DIR


# Install configured httpd.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
rm -f /etc/httpd/conf/httpd.conf
ln -s $REPO_DIR/vagrant/apache/httpd.conf /etc/httpd/conf/httpd.conf
ln -s $REPO_DIR/vagrant/apache/mod_rewrite_rules.conf /etc/httpd/conf.d/mod_rewrite_rules.conf

# Install Phalcon
mkdir -p $REPO_DIR/phalcon
cd $REPO_DIR/phalcon
git clone git://github.com/phalcon/cphalcon.git
rm -rf $REPO_DIR/phalcon/cphalcon/.git
cd $REPO_DIR/phalcon/cphalcon/build
./install
ln -s $REPO_DIR/vagrant/php/phalcon.ini /etc/php.d/phalcon.ini

# Download geonames data and import into mysql
cd $REPO_DIR/geoname-import/
sh geonames_importer.sh -a download-data
sh geonames_importer.sh -a create-db -u root -p root
sh geonames_importer.sh -a import-dumps -u root -p root

# Restart services
service httpd restart
service mysqld restart

echo "Server provisioning complete!"
