#!/bin/bash

chown -R root /var/www/data/nginx /var/www/data/php
chgrp -R root /var/www/data/nginx /var/www/data/php
chmod 770 /var/www/data/nginx /var/www/data/php
chgrp -R www-data /var/www/data/media /var/www/data/sitemap /var/www/data/var
chmod 775 /var/www/data/media /var/www/data/sitemap /var/www/data/var

rm -Rf /var/www/site/htdocs/media
rm -Rf /var/www/site/htdocs/sitemap
rm -Rf /var/www/site/htdocs/var
ln -s /var/www/data/media /var/www/site/htdocs/media
ln -s /var/www/data/sitemap /var/www/site/htdocs/sitemap
ln -s /var/www/data/var /var/www/site/htdocs/var
