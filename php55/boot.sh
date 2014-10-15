#!/bin/bash

if [ -z "$MY_ENV" ]
then
    echo "!!! You must set a MY_ENV variable !!!"
    echo "docker run -P -d -e MY_ENV=dev|prod <yourboxname>"
    exit
fi

cp -f /configs/$MY_ENV/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf
# allows receiving emails from other docker containers
MYIP=`ip addr show dev eth0 scope global | grep inet | awk '{print $2;}' | cut -d/ -f1`
echo "dc_other_hostnames='${HOSTNAME}'" >> /etc/exim4/update-exim4.conf.conf
echo "dc_local_interfaces='127.0.0.1;${MYIP}'" >> /etc/exim4/update-exim4.conf.conf

# run command update-exim4.conf to update update-exim4.conf.conf
update-exim4.conf
service exim4 restart

exec /usr/sbin/php5-fpm -c /etc/php5/fpm/ -y /etc/php5/fpm/php-fpm.conf
