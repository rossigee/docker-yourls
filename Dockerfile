FROM alpine:latest

RUN apk -U upgrade && apk add \
	curl tar \
	supervisor \
	nginx \
	php7-curl \
	php7-fpm \
	php7-iconv \
	php7-json \
	php7-mysqli \
	php7-pdo_mysql \
	php7-session

COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx

# Show nginx logs in Docker console output
RUN rm -f /var/log/nginx/* && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY www.conf /etc/php7/php-fpm.d/www.conf
RUN addgroup nginx nobody

# Delegate the rest to the supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Set up YOURLS document root
RUN mkdir /var/www/public_html
WORKDIR /var/www/public_html
RUN curl -sL https://github.com/YOURLS/YOURLS/archive/1.7.3.tar.gz | tar xz --strip-components=1

# Apply fix from https://github.com/YOURLS/YOURLS/pull/2376/commits/c8144d702a81995093704334d491677f1b1efdd3
COPY functions-auth.php includes/functions-auth.php

COPY config.php /var/www/public_html/user/config.php

EXPOSE 80
