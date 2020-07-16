FROM debian:buster-slim

MAINTAINER https://github.com/vdedios

COPY srcs/* ./

RUN apt-get update && apt-get install -y \
	wget nginx php-fpm php-mysql php-mbstring mariadb-server openssl\
	&& wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& tar xvf phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& mv phpMyAdmin-5.0.2-all-languages /var/www/html/phpmyadmin \
	&& rm -rf phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& wget https://es.wordpress.org/latest-es_ES.tar.gz \
	&& tar xvf latest-es_ES.tar.gz \
	&& mv wordpress/* /var/www/html \
	&& rm -rf latest-es_ES.tar.gz \
	&& chown -R www-data:www-data /var/www/html \
	&& find /var/www/html -type d -exec chmod 0755 {} \; \
	&& find /var/www/html -type f -exec chmod 0644 {} \; \
	&& mv default /etc/nginx/sites-available \
	&& mv config.sample.inc.php /var/www/html/phpmyadmin \
	&& mv wp-config.php /var/www/html \
	&& mv config_db.sql /tmp \
	&& mv wordpress.sql /tmp \
	&& service mysql start \
	&& mysql < /var/www/html/phpmyadmin/sql/create_tables.sql \
	&& mysql < /tmp/config_db.sql \
	&& mysql wordpress < /tmp/wordpress.sql \
	&& service mysql stop \
	&& openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 -subj "/C=SP/ST=Spain/L=Madrid/O=42/CN=127.0.0.1" \
	-keyout /etc/ssl/private/server.key \
	-out /etc/ssl/certs/server.crt && \
	openssl dhparam -out /etc/nginx/dhparam.pem 1000

CMD service mysql start \
	&& service php7.3-fpm start \
	&& service nginx start \
	&& bash

EXPOSE 80 443
