FROM php:7.1-apache
MAINTAINER Glenn ROLLAND <glenux@glenux.net>

RUN apt-get update \
	&& apt-cache search lib mysql dev$ \
	&& apt-get install -y \
		wget unzip curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmysql++-dev \
        zlib1g-dev \
	&& apt-get autoremove \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && docker-php-ext-install zip

RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer

RUN wget \
  -O /tmp/dolibarr-8.0.4.zip \
  https://github.com/Dolibarr/dolibarr/archive/8.0.4.zip

RUN unzip -d /usr/src /tmp/dolibarr-8.0.4.zip \
	&& chown -R www-data:www-data /usr/src/dolibarr-8.0.4 \
	&& rm -fr /var/www/html \
	&& cp -a /usr/src/dolibarr-8.0.4 /var/www/html

ADD php-uploads.ini /usr/local/etc/php/conf.d/glenux-uploads.ini
ADD php-performance.ini /usr/local/etc/php/conf.d/glenux-performance.ini
ADD php-errors.ini /usr/local/etc/php/conf.d/glenux-errors.ini

RUN sed \
  -i 's|/var/www/html|/var/www/html/htdocs|' \
  /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/html 

CMD composer install && apache2-foreground
