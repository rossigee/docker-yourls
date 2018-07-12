FROM alpine:latest

RUN apk add --no-cache \
	curl tar \
	supervisor \
	nginx \
	php7-curl \
	php7-fpm \
	php7-json \
	php7-mysqli \
	php7-session

COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx

COPY www.conf /etc/php7/php-fpm.d/www.conf
RUN addgroup nginx nobody

# Delegate the rest to the supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Set up YOURLS document root
RUN mkdir /var/www/public_html
WORKDIR /var/www/public_html
RUN curl -sL https://github.com/YOURLS/YOURLS/archive/1.7.2.tar.gz | tar xz --strip-components=1

COPY config.php /var/www/public_html/user/config.php

EXPOSE 80
