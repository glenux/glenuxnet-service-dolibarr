FROM php:7.4-apache-buster
# FROM php:7.3-apache-buster
MAINTAINER Glenn ROLLAND <glenux@glenux.net>

# ENV DOLIBARR_VERSION=12.0.1
ENV DOLIBARR_VERSION=13.0.2

RUN apt-get update \
	&& apt-cache search lib mysql dev$ \
	&& apt-get install -y \
		wget unzip curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmariadb-dev \
        zlib1g-dev \
        libicu-dev \
	&& apt-get autoremove -y \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && docker-php-ext-install calendar \
    && docker-php-ext-install zip

RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer

RUN wget \
  -O /tmp/dolibarr-${DOLIBARR_VERSION}.zip \
  https://github.com/Dolibarr/dolibarr/archive/${DOLIBARR_VERSION}.zip

RUN unzip -d /usr/src /tmp/dolibarr-${DOLIBARR_VERSION}.zip \
	&& chown -R www-data:www-data /usr/src/dolibarr-${DOLIBARR_VERSION} \
	&& rm -fr /var/www/html \
	&& cp -a /usr/src/dolibarr-${DOLIBARR_VERSION} /var/www/html

ADD php-uploads.ini /usr/local/etc/php/conf.d/glenux-uploads.ini
ADD php-performance.ini /usr/local/etc/php/conf.d/glenux-performance.ini
ADD php-errors.ini /usr/local/etc/php/conf.d/glenux-errors.ini

RUN sed \
  -i 's|/var/www/html|/var/www/html/htdocs|' \
  /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/html 

CMD composer install && apache2-foreground

