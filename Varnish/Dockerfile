FROM dockerfile/ubuntu

MAINTAINER Cyrill Schumacher <cyrill@zookal.com>

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update
RUN apt-get install -y varnish


# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# git is not needed here but included in the base docker image.
RUN apt-get remove -y git

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make our custom VCLs available on the container
ADD config/default.vcl /etc/varnish/default.vcl
ADD config/vcl/default.vcl /etc/varnish/vcl/default.vcl

ENV VARNISH_BACKEND_PORT 80
ENV VARNISH_BACKEND_IP 172.17.42.1
ENV VARNISH_PORT 80

EXPOSE 80

# allow full custom config instead of default ones
VOLUME  ["/etc/varnish"]

ADD boot.sh /boot.sh
RUN chmod 0700 /boot.sh
CMD ["/boot.sh"]
