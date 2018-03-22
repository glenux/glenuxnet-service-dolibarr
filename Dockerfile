FROM php:7.2-apache
MAINTAINER Glenn ROLLAND <glenux@glenux.net>

RUN apt-get update \
	&& apt-cache search lib mysql dev$ \
	&& apt-get install -y \
		wget unzip curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmysql++-dev \
	&& apt-get autoremove \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql mysqli

RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer

RUN wget \
  -O /tmp/dolibarr-7.0.0.zip \
  https://github.com/Dolibarr/dolibarr/archive/7.0.0.zip

RUN unzip -d /usr/src /tmp/dolibarr-7.0.0.zip \
	&& chown -R www-data:www-data /usr/src/dolibarr-7.0.0 \
	&& rm -fr /var/www/html \
	&& cp -a /usr/src/dolibarr-7.0.0 /var/www/html

ADD php-uploads.ini /usr/local/etc/php/conf.d/glenux-uploads.ini
ADD php-performance.ini /usr/local/etc/php/conf.d/glenux-performance.ini

RUN sed \
  -i 's|/var/www/html|/var/www/html/htdocs|' \
  /etc/apache2/sites-enabled/000-default.conf

RUN cd /var/www/html \
	composer install

