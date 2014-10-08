CONTAINERS := $(shell docker ps -a -q)
IMAGES := $(shell docker images -a -q)

pull-dev:
	docker pull docharris/redisobject:v1.0.2817
	docker pull docharris/redissession:v1.0.2817
	docker pull docharris/mysql55:v1.0.5538
	docker pull docharris/mailcatcher:v1.0.0512
	docker pull docharris/npstorage:v1.0.0
	docker pull docharris/php55:v1.0.5517
	docker pull docharris/nginx:v1.0.162

pull-prod:
    docker pull docharris/npstorage:v1.0.0
	docker pull docharris/redisobject:v1.0.2817
	docker pull docharris/redissession:v1.0.2817
	docker pull docharris/php55:v1.0.5517
	docker pull docharris/nginx:v1.0.162

build:
	docker build -t="docharris/redisobject" redis/object/
	docker build -t="docharris/redissession" redis/session/
	docker build -t="docharris/mysql55" mysql/5.5/
	docker build -t="docharris/mailcatcher" mailcatcher/
	docker build -t="docharris/npstorage" npStorage/
	docker build -t="docharris/php55" php55/
	docker build -t="docharris/nginx" nginx/
	docker build -t="crosbymichael/dockerui" github.com/crosbymichael/dockerui

run-dev:
	docker run -d --name mailcatcher -p 1080:1080 docharris/mailcatcher
	docker run -d --name redisobject docharris/redisobject
	docker run -d --name redissession docharris/redissession
	docker run --name DocHarrisMySQL -d -p 3306:3306 docharris/mysql55
	docker run -d --name npstorage \
	-v /var/www/site:/var/www/site \
	-v /var/www/data/php:/var/www/data/php \
	-v /var/www/data/nginx:/var/www/data/nginx \
	-v /var/www/data/media:/var/www/data/media \
	-v /var/www/data/sitemap:/var/www/data/sitemap \
	-v /var/www/data/var:/var/www/data/var \
	docharris/npstorage
	docker run -d --name php \
	--volumes-from=npstorage \
	-e PHP_ENV=dev \
	--link redisobject:redisobject \
	--link redissession:redissession \
	--link DocHarrisMySQL:DocHarrisMySQL \
	--link mailcatcher:mailcatcher \
	docharris/php55
	docker run -d --name nginx --volumes-from=npstorage --link php:php -p 80:80 -p 443:443 docharris/nginx

clean-container:
	docker stop $(CONTAINERS)
	docker rm -f $(CONTAINERS)

clean-images:
	docker rmi -f $(IMAGES)
