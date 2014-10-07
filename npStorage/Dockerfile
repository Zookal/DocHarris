FROM dockerfile/ubuntu

# npStorage Container n=nginx p=php Storage

MAINTAINER Cyrill Schumacher <cyrill@zookal.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# git is not needed here but included in the base docker image.
RUN apt-get remove -y git

ADD . /configs
RUN chmod 700 /configs/boot.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/www/site", "/var/www/data/php", "/var/www/data/nginx", "/var/www/data/media", "/var/www/data/sitemap", "/var/www/data/var"]

CMD ["/configs/boot.sh"]
