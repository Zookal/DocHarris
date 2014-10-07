#!/bin/bash

rm -Rf /var/www/site/htdocs/media
rm -Rf /var/www/site/htdocs/sitemap
rm -Rf /var/www/site/htdocs/var
ln -s /var/www/data/media /var/www/site/htdocs/media
ln -s /var/www/data/sitemap /var/www/site/htdocs/sitemap
ln -s /var/www/data/var /var/www/site/htdocs/var
