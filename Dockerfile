FROM alpine:edge

# Maintainer
MAINTAINER Andrey Delphin <masterforweb@hotmail.com>

# Environments
ENV TIMEZONE Europe/Moscow
ENV PHP_MEMORY_LIMIT 1024M
ENV MAX_UPLOAD 128M
ENV PHP_MAX_FILE_UPLOAD 128
ENV PHP_MAX_POST 128M

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk update && \
	apk upgrade && \
    apk --update add \
    supervisor \
    php7 \
    php7-dev \
    php7-cli \
    php7-pcntl \
    php7-bcmath \
    php7-dom \
    php7-ctype \
    php7-curl \
    php7-fileinfo \
    php7-gd \
    php7-iconv \
    php7-tidy \
    php7-intl \
    php7-json \
    php7-mysqlnd \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-soap \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
    php7-ftp \
    php7-memcached \
    php7-redis \
    php7-amqp && \

    apk add --no-cache git  && \

    apk add --no-cache --virtual .imagick-build-dependencies autoconf curl g++ gcc imagemagick-dev libtool make tar && \
    apk add --virtual .imagick-runtime-dependencies imagemagick && \
    IMAGICK_TAG="3.4.2" && \
    git clone -o ${IMAGICK_TAG} --depth 1 https://github.com/mkoppanen/imagick.git /tmp/imagick && \
    cd /tmp/imagick && \
    phpize && \
    ./configure && \
    make && \
    make install && \

    echo "extension=imagick.so" > /etc/php7/conf.d/ext-imagick.ini && \
    apk del .imagick-build-dependencies && \


    # Set environments
    sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini && \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php7/php.ini  && \

        
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \

    # www-data 
    addgroup -g 1000 -S www-data && \
	adduser -u 1000 -D -S -G www-data www-data && \
  
    rm -rf /var/cache/apk/*  

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
