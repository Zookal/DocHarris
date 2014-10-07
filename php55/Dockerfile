FROM dockerfile/ubuntu

MAINTAINER Cyrill Schumacher <cyrill@zookal.com>

# for http://ppa.launchpad.net trusty Release
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# add php5.5 repository
RUN add-apt-repository -y ppa:ondrej/php5 > /dev/null 2>&1 # dirty fix for "invalid UTF-8 in string"
RUN apt-get update -y

# Basic Requirements
RUN apt-get install -y php5-fpm php5-mysql php5-curl php5-mcrypt php5-gd php5-oauth php5-redis php5-xdebug
RUN apt-get install -y php5-apcu
RUN apt-get install -y python-setuptools nano mysql-client-5.5

# git is not needed here but included in the base docker image.
RUN apt-get remove -y git

# install supervisord
RUN apt-get install -y supervisor

# forwards mail to mailcatcher or any other SMTP service
RUN apt-get install -y exim4

ADD . /configs
RUN chmod 700 /configs/boot.sh

RUN ln -sf /configs/supervisor/supervisord.conf /etc/supervisor/
RUN ln -sf /configs/supervisor/conf.d/apps.conf /etc/supervisor/conf.d/apps.conf
RUN cp -f /configs/php5/php-fpm.conf /etc/php5/fpm/php-fpm.conf
RUN cp -f /configs/php5/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf
RUN cp -f /configs/php5/php.ini /etc/php5/fpm/php.ini
RUN cp -f /configs/php5/mods-available/* /etc/php5/mods-available/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add VOLUMEs to allow backup of config
VOLUME  ["/etc/php5/fpm/", "/etc/exim4/"]

EXPOSE 9000
CMD ["/configs/boot.sh"]
