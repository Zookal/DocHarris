#!/bin/sh
chgrp -R www-data /data && chmod 770 /data
exec /sbin/setuser redis redis-server /etc/redis/redis-obj.conf
