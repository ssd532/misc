#!/bin/bash

############################################################
# Functions of this program
# 1. Install email-marketer software 
# 2. Take client-name as commandline argument
# 3. Set up email-marketer for the client in separate folder
# 
# Developed by Sachin Divekar
############################################################

# Logging related
ME=${0##*/}
LOGGER="/usr/bin/logger -p"
LOGFAC="user"
LOGPRI="debug"
LOGTAG="$ME[$$]"
SUCCESS=0
ERROR=1

log_msg() {
    $LOGGER $LOGFAC.$LOGPRI -t $LOGTAG "$1"
}

display_usage() { 
    echo "This script must be run with super-user privileges." 
    echo -e "\nUsage:\n$0 [arguments] \n"
} 

# if less than two arguments supplied, display usage 
if [  $# -lt 1 ]; then 
    display_usage
    exit 1
fi 

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $# == "--help") ||  $# == "-h" ]]; then 
    display_usage
    exit 0
fi 

# display usage if the script is not run as root user 
if [[ $USER != "root" ]]; then 
    echo "This script must be run as root!" 
    exit 1
fi 

# list of required packages
packages="httpd mysql mysql-server php php-mysql unzip wget"

# If required package is not, installed install it
for package in $(echo $packages); do
    if ! yum list installed $package > /dev/null 2>&1; then
        echo "Installing $package"
	yum -y install $package
    fi
done

# List of required services
services="httpd mysqld"

# Start required services
for service in $(echo $services); do
    UP=$(service $service status | grep "$service start/running" | wc -l)
    if [ "$UP" -ne 1]; then
        log_msg "$service is not running. Starting it"
        echo "$service is not running. Starting it"
        service $service start
    fi
done

em_home="/root/email-marketer"

if [ ! -d $em_home ]; then
    log_msg "$em_home is not present. Creating it."
    echo "$em_home is not present. Creating it."
    mkdir -p $em_home
fi

# Create client-specific directory in DocumentRoot 
docroot="/var/www/html"
client=$1
client_docroot="$docroot/$client"
if [ ! -d $client_docroot ]; then
    log_msg "Directory for $client is not present. Creating it."
    echo "Directory for $client is not present. Creating it."
    mkdir $client_docroot
fi

# Download email-marketer 
cd $em_home
em_package="emailmarketer.zip"

if [ ! -f $em_package ]; then
    log_msg "$em_package not present. Downloading it."
    echo "$em_package not present. Downloading it."
    wget https://iucf.googlecode.com/files/emailmarketer.zip
fi

# Extract email-marketer into client's docurment root
unzip $em_package -d $client_docroot > /dev/null 2>&1

chmod -R 777 ${client_docroot}/admin/com/storage
chmod -R 777 ${client_docroot}/admin/temp
chmod -R 666 ${client_docroot}/admin/includes/config.php

# Create database and database user
# Uncomment mysql_passwd and mysql_db if you are using them

mysql_user="root"
#mysql_passwd="$client"
#mysql_db="root"

#my_exec="mysql -u${user} -D${mysql_db} -p${mysql_passwd} "  # use this command if you are using password for root
my_exec="mysql -u${mysql_user} "
$my_exec<<EOFMYSQL
CREATE DATABASE ${client};
CREATE USER '${client}'@'localhost' IDENTIFIED BY '${client}';
GRANT ALL PRIVILEGES ON ${client}.* TO '${client}'@'localhost';
EOFMYSQL


licensekey=
applicationurl=
contactemail=
admin_username=
admin_password=
admin_password_confirm=
dbtype=
mysql_db_choice=
mysql_dbusername=
mysql_dbpassword=
mysql_dbhostname=
mysql_dbname=
mysql_tableprefix=
pgsql_dbusername=
pgsql_dbpassword=
pgsql_dbhostname=
pgsql_dbname=
pgsql_tableprefix=
SubmitButton=

#curl --data "licensekey=THVLTDTBZ&applicationurl=http%3A%2F%2Fexample.com%2F${client}&contactemail=useremail%40example.com&admin_username=admin&admin_password=password&admin_password_confirm=password&dbtype=mysql&mysql_db_choice=mysql_db_choice1&mysql_dbusername=username&mysql_dbpassword=password&mysql_dbhostname=localhost&mysql_dbname=dbname&mysql_tableprefix=email_&pgsql_dbusername=&pgsql_dbpassword=&pgsql_dbhostname=localhost&pgsql_dbname=&pgsql_tableprefix=email_&SubmitButton=Continue" "http://example.com/${client}/admin/index.php?Page=Installer&Step=1"

if [ $? -eq 0 ]; then
    echo "email marketer is installed"
fi
