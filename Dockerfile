FROM php:7.1-apache

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Apache extensions
RUN apt-get update && \
    apt-get -y install \
    apache2-utils pwgen vim nano \
    libmemcached-dev memcached libmemcached-tools wget curl libapache2-mod-evasive libapache2-mod-security2 && \
    a2enmod headers && a2enmod evasive && a2enmod rewrite && a2enmod ssl

# PHP extensions
RUN apt-get install -y php-twig php-html-safe php-apc php-apigen php-calendar php-calendar php-dompdf php-file \
    php-fpdf php-html-common php-http php-imlib php-mail php-pager php-openid php-parser php-xajax php-pear \
    phpab php-seclib php-monolog phpdox php-pclzip libphp-pclzip php5-mysqlnd-ms php5-mysqlnd sudo php5-xsl php-fxsl php-crypt-blowfish php5-mcrypt libmcrypt* \
    poppler-utils php5-imagick libzip2

# ImageMagick
RUN apt-get install -y imagemagick libmagickwand-dev libmagickwand-dev libmagickcore-dev libpam-pwdfile

# PHP ZipArchive extension
RUN apt-get update \
  && apt-get install -y zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install zip

# Configure extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install zip
RUN pecl install imagick
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini
RUN docker-php-ext-enable imagick
# RUN docker-php-ext-install xsl

ADD  ./src/apache2/*.conf /etc/apache2/sites-available/
COPY ./src/apache2/*.template /etc/apache2/sites-available/
RUN useradd -ms /bin/bash mark && usermod -a -G www-data mark

# cron for background tasks

RUN apt-get update && apt-get install -y cron supervisor mysql-client
RUN mkdir -p /var/log/supervisor
COPY ./src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD  ./src/crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /var/spool/cron/crontabs/root
RUN touch /var/log/cron.log

ADD ./src/init.sh /usr/local/bin/init.sh
ADD ./src/run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/*.sh

CMD ["/usr/local/bin/run.sh"]
