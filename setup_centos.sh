#!/usr/bin/env bash

#########################################
### Centos 6 Server Setup (Rackspace) ###
###									  ###
######## RUN THIS SCRIPT AS ROOT ########
#########################################

USER=$1

# Send an alert if the previous command exited with 0 status
alert (){
	STATUS=$?
	if [ $STATUS -eq 0 ]; then
		echo $1
	fi
}

# Create user account with sudo access and force password change
# on initial login
adduser $USER
chage -d 0 $USER
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers
alert "Created account for $USER"

# Change the server name
SERVER_NAME=`hostname`
sed -i 's/#ServerName www\.example\.com:80/ServerName $SERVER_NAME\.com/g' /etc/httpd/conf/httpd.conf
alert "Changed the server name to $SERVER_NAME"

# Install apache2 and mod-ssl, make sure apache starts and boot time and open port 80
yum -y -q install httpd mod_ssl
chkconfig --levels 2345 httpd on
service httpd start
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
alert "Installed Apache with mod-ssl enabled"

# Install the latest version of JAVA (openjdk)
yum -y -q install java-1.7.0-openjdk
export JAVA_HOME=/usr/lib/jvm/jre/
alert "Installed Java"

# Install the latest version of PHP
yum -y -q install php php-cli php-common php-dba php-gd php-imap php-mbstring php-mysql php-pdo php-pear php-pecl-apc php-process php-xml cups-php php-pecl-memcache uuid-php
alert "Installed PHP"

# Install memcached
yum -y -q install memcached
chkconfig --level 2345 memcached on
iptables -I INPUT -p tcp --dport 11211 -j ACCEPT OR iptables -I INPUT -i eth1 -p tcp --dport 11211 -j ACCEPT
service iptables save
alert "Installed memcached"

# Install gcc
yum -y -q install gcc gcc-c++
alert "Installed gcc"

# Install mysql
yum -y -q install mysql mysql-server mysql-devel
chkconfig --levels 2345 mysqld on
service mysqld start
alert "Installed mysql"

# Set root password for mysql
PASSWORD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
mysqladmin -u root password $PASSWORD
alert "Set mysql root password to $PASSWORD"

# Install phpMyAdmin
wget -q http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm
wget -c -q http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/3.4.9/phpMyAdmin-3.4.9-english.tar.gz
tar xvfx phpMyAdmin*
mv phpMyAdmin-3.4.9-english /usr/share/phpmyadmin
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sed -i 's/'\''cookie'\''/'\''http'\''/g' /usr/share/phpmyadmin/config.inc.php
service httpd restart
alert "Installed phpMyAdmin"

# Install nfs and rcpbind
yum -y install nfs-utils nfs-utils-lib
service rpcbind start
service ifs start
chkconfig --levels 2345 nfs on
chkconfig --levels 2345 rpcbind on
alert "Installed nfs and rpcbind"




