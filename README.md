# DocHarris - Dockerfiles for Magento 

### With nginx, php-fpm 5.5.x, 2 x Redis, MySQL (only for dev) and Varnish.

### Optimized for composer.org usage. See project [HarrisStreet](https://github.com/Zookal/HarrisStreet).

Condition: Already installed and working Magento System.

If you are already working/developing on a linux machine `boot2docker` is not needed.

Install [boot2docker](http://boot2docker.io) and [Docker](https://docs.docker.com/) itself. 

On OSX please use `brew install docker | boot2docker`

Download the Zookal custom [boot2docker.iso](https://github.com/Zookal/boot2docker/raw/master/boot2docker.iso.gz) 
which fixes vboxsf autoload and place the ISO in the correct folder of your OS. 

Shared Folders are slow in VirtualBox. A todo point is implementing [File system notifications for Go](https://github.com/go-fsnotify/fsnotify) into the boot2docker CLI to constantly sync the files into the VM. There is already some work [going on](https://github.com/boot2docker/boot2docker-cli/pulls).

For OSX put the ISO in: `~/.boot2docker/` folder.

For Win put the ISO in: `???` folder.

The folders `site` and `data` are hardcoded in the boot2docker.iso and always maps to: `/var/www/site` resp. `/var/www/data`.

Documents will be served from `/var/www/site/htdocs`. `media`, `sitemap` and `var` folders are automatically symlinked into the `htdocs` folder. These three folders stay in the data folder for persistence. 

Mac OSX:

	boot2docker --vbox-share=/Users/xxx/Sites/web-site=site --vbox-share=/Users/xxx/Sites/web-data=data -v init
    
Windows:
    
	boot2docker --vbox-share="C:\\Users\xxx\\...=site" --vbox-share="C:\\Users\xxx\\...=data" -v init
    
Start VM:
    
    $ boot2docker up
    
Make sure to export properly `export DOCKER_HOST=tcp://192.168.x.x:2375` in all terminal windows where you would like to use docker.

To regenerate this string use `$ boot2docker socket`.

Update the hosts file of your OS with the new boot2docker ip address.

# DocHarris Redis

### Build an image from Dockerfile: 

    docker build -t="docharris/redisobject" redis/object/
    docker build -t="docharris/redissession" redis/session/

Or `docker pull docharris/redisobject|redissession`. @todo

### Run `redis-server` without persistent data (development)

    docker run -d --name redisobject docharris/redisobject
    docker run -d --name redissession docharris/redissession

This is faster when using Virtualbox with shared folders.

### Run `redis-server` with persistent data directory. (creates `filename.rdb`)

The container `RedisStorage` will be used for directory mapping.

    docker run -d -v /var/www/data/redis:/data --name RedisStorage dockerfile/ubuntu echo "Redis Storage"
    docker run -d --volumes-from RedisStorage --name redisobject docharris/redisobject
    docker run -d --volumes-from RedisStorage --name redissession docharris/redissession

### Run `redis-server` with persistent data directory and password.

    docker run -d -v /var/www/data/redis:/data --name RedisStorage dockerfile/ubuntu echo "Redis Storage"
    docker run -d --volumes-from RedisStorage --name redis dockerfile/redis redis-server /etc/redis/redis.conf --requirepass <password>

### Run `redis-cli`

    docker run -it --rm --link redisobject:redisobject docharris/redisobject bash -c 'redis-cli -p 6379 -h redisobject'
    docker run -it --rm --link redissession:redissession docharris/redissession bash -c 'redis-cli -p 6380 -h redissession'

@todo Add Redis FPC cache.

# DocHarris MySQL

In dev you can run it without persistence. For more details see the README.md file in the `mysql` folder.

Commands for development:

	docker build -t "docharris/mysql" mysql/5.5/
	docker run --name DocHarrisMySQL -d -p 3306:3306 docharris/mysql
	docker logs <CONTAINER_ID>
	
Last commands shows you the password. Please save that! The you can import databases and users.

# DocHarris Mailcatcher (development environment)

Build contailer

    docker build -t docharris/mailcatcher mailcatcher/

Run container

    docker run -d --name mailcatcher docharris/mailcatcher

# DocHarris npStorage

Build container to keep persisted data and load Magento PHP files:

    docker build -t "docharris/npstorage" npStorage/

Run container:

    docker run -d --name npstorage \
      -v /var/www/site:/var/www/site \
      -v /var/www/data/php:/var/www/data/php \
      -v /var/www/data/nginx:/var/www/data/nginx \
      -v /var/www/data/media:/var/www/data/media \
      -v /var/www/data/sitemap:/var/www/data/sitemap \
      -v /var/www/data/var:/var/www/data/var \
      docharris/npstorage

This container will immediately exit and only provides the storage for nginx and php container.

The folders media, sitemap and var will be symlinked to `/var/www/site/htdocs`.

# DocHarris PHP5.5

Build the php container:

    $ docker build -t "docharris/php55" php55/

### Run in background for dev:

    docker run -d --name php \
      --volumes-from=npstorage \
      -v /var/www/site/path-to/etc/php55/development:/etc/php5/fpm \
      -e PHP_ENV=dev \
      --link redisobject:redisobject \
      --link redissession:redissession \
      --link DocHarrisMySQL:DocHarrisMySQL \
      --link mailcatcher:mailcatcher \
      docharris/php55

The `-v` switch is optional and maps your custom php config into the fpm folder.

### Run with bash for dev:

    docker run -ti --rm --name php \
      --volumes-from=npstorage \
      -v /var/www/site/path-to/etc/php55/development:/etc/php5/fpm \
      -e PHP_ENV=dev \
      --link redisobject:redisobject \
      --link redissession:redissession \
      --link DocHarrisMySQL:DocHarrisMySQL \
      --link mailcatcher:mailcatcher \
      docharris/php55 bash

The `-v` switch is optional and maps your custom php config into the fpm folder.

The `bash` at the end starts the shell. When logged in run `/config/boot.sh &` to start the fpm process.

There are two env settings at the momement: `dev` and `prod`.  During container start these settings will be copied into the etc folders. So you can test prod settings on your dev machine. 

With the open shell you can now use [n98-magerun](http://magerun.net/), etc in the `/var/www/site` folder.

On the other hand you can have a local php installation on your Windows or OSX system and then run from there [n98-magerun](http://magerun.net/).

There is no ssh daemon implemented in all docker containers because that is evil and a anti pattern.

#### Run in background on staging | prod:

    docker run -d --name php \
      --volumes-from=npstorage \
      -v /path-to/etc/php55/production:/etc/php5/fpm \
      -e PHP_ENV=prod \
      --link redisobject:redisobject \
      --link redissession:redissession \
      --link DocHarrisMySQL:DocHarrisMySQL \
      zookal/php55


# DocHarris nginx

Build command:

	docker build -t docharris/nginx nginx/

Run the container background with custom nginx config:
    
	docker run -d --name nginx \
      --volumes-from=npstorage \
      -v <path-to-your-sites-enabled-folder>:/etc/nginx/sites-enabled
      -v <path-to-your-certs-folder>:/etc/nginx/certs
      --link php:php \
      -p 80:80 \
      -p 443:443 \
      docharris/nginx

# DocHarris Pulling existing builds

Resource [https://registry.hub.docker.com/repos/docharris/](https://registry.hub.docker.com/repos/docharris/)

Use this docker pull for the development environment:

	docker pull docharris/redisobject:v1.0.2817
	docker pull docharris/redissession:v1.0.2817
	docker pull docharris/mysql55:v1.0.5538
	docker pull docharris/mailcatcher:v1.0.0512
	docker pull docharris/npstorage:v1.0.0
	docker pull docharris/php55:v1.0.5517
	docker pull docharris/nginx:v1.0.162

Use this docker pull for the production environment:

	docker pull docharris/npstorage:v1.0.0
	docker pull docharris/redisobject:v1.0.2817
	docker pull docharris/redissession:v1.0.2817
	docker pull docharris/php55:v1.0.5517
	docker pull docharris/nginx:v1.0.162

Version number: Major.Minor.Service

- PHP 5517 = 5.5.17
- MySQL 5538 = 5.5.38
- Redis 2817 = 2.8.17

Whenever a Services changes this will be reflected in the last number. Whenever something in the Dockerfile changes this will reflect the Major and Minor numbers.
  
The version in the `Makefile` will be updated and not here.

# DocHarris in action

Should look like this:

```
$ docker ps -a
CONTAINER ID        IMAGE                           COMMAND                CREATED             STATUS                         PORTS                                      NAMES
6ec4237ee125        docharris/nginx:latest          "/configs/boot.sh"     About an hour ago   Up About an hour               0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx
555f71b1bdc7        docharris/php55:latest          "bash"                 About an hour ago   Up About an hour               9000/tcp                                   nginx/php,php
5e4f3ab03139        docharris/npstorage:latest      "/configs/boot.sh"     About an hour ago   Exited (0) About an hour ago                                              npstorage
23cc3a980931        docharris/mysql55:latest        "/run.sh"              About an hour ago   Up About an hour               0.0.0.0:3306->3306/tcp                     DocHarrisMySQL,nginx/php/DocHarrisMySQL,php/DocHarrisMySQL
f70db4d54343        docharris/redissession:latest   "redis-server /etc/r   4 hours ago         Up 4 hours                     6380/tcp                                   nginx/php/redissession,php/redissession,redissession
c9433d879fce        docharris/redisobject:latest    "redis-server /etc/r   4 hours ago         Up 4 hours                     6379/tcp                                   nginx/php/redisobject,php/redisobject,redisobject
ecf97f84644d        dockerfile/ubuntu:latest        "echo 'Redis Storage   4 hours ago         Exited (0) 4 hours ago                                                    RedisStorage
```

# Docker Helpers

With Docker <= 1.2 you must restart all linked containers. If you restart container php then you must restart nginx also. If you restart MySQL or Redis container then you must restart php and nginx.

Docker 1.3 solves that problem by automatically updating the `/etc/hosts` files in all containers with the new IP addresses of the restarted containers. 

### Remove all images:

    docker rmi $(docker images -a -q)
    
### Stop all containers:
    
    docker stop $(docker ps -a -q)

### Remove all containers:

    docker rm $(docker ps -a -q)

[Docker Cheat Sheet](https://github.com/wsargent/docker-cheat-sheet)

### Docker UI

Running this on OSX gives you a nice UI to interact with containers and images:

	docker build -t crosbymichael/dockerui github.com/crosbymichael/dockerui
	docker run -d -p 9000:9000 -v /var/run/docker.sock:/docker.sock crosbymichael/dockerui -e /docker.sock

Run it with boot2docker in your browser:

	http://(`boot2docker ip`):9000

Do not use it in production as it has no security.

[dockerui on github](https://github.com/crosbymichael/dockerui)

# FAQ

## How do I link in my PHP app to the dockerized MySQL resp. Redis daemon?

When running the container for php we have defined links to other containers:

      --link redisobject:redisobject \
      --link redissession:redissession \
      --link DocHarrisMySQL:DocHarrisMySQL
      --link Name:Alias

The aliases will be added to the /etc/hosts file:

	[ root@555f71b1bdc7:/var/www/site ]$ cat /etc/hosts
	172.17.0.183	555f71b1bdc7
	ff00::0	ip6-mcastprefix
	ff02::1	ip6-allnodes
	ff02::2	ip6-allrouters
	127.0.0.1	localhost
	::1	localhost ip6-localhost ip6-loopback
	fe00::0	ip6-localnet
	172.17.0.178	DocHarrisMySQL
	172.17.0.29		redisobject
	172.17.0.30		redissession

Don't care for the IP addresses as these ones are dynamic and change with each start or restart.

You can then use as host name: DocHarrisMySQL, etc in you `app/etc/local.xml` config.

# Contribute

Please what ever you see tweet it, create an issue or open a pull request.

### @todo

- Maybe [docker fig](http://www.fig.sh/)
- 

License
-------

[Open Software License (OSL 3.0)](http://opensource.org/licenses/osl-3.0.php)

Copyright
---------

Copyright (c) Zookal Pty Ltd, Sydney Australia

Author
------

Cyrill at Schumacher dot fm or cyrill at zookal dot com

[My pgp public key](http://www.schumacher.fm/cyrill.asc)

[@SchumacherFM](https://github.com/SchumacherFM)