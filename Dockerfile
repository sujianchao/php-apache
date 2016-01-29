FROM php:5.6-apache

MAINTAINER SuJianchao <sujianchao@gmail.com>

ENV REFRESHED_AT 2016-01-27

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

ENV AUTHORIZED_KEYS **None**
#ENV ROOT_PASS

#Mysql连接参数配置
ENV HOSTNAME        localhost      
ENV USERNAME        yourDBUser
ENV PASSWORD        yourDBPassword
ENV DATABASE        yourDBName

#安装app
COPY config/php.ini /usr/local/etc/php/
COPY app/ /var/www/html/
#启用php扩展
RUN docker-php-ext-install -j$(nproc) mysqli mysql pdo pdo_mysql mbstring shmop zip
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN apt-get update && apt-get install -y libmemcached-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached
RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p xcache \
    && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && ( \
        cd xcache \
        && phpize \
        && ./configure --enable-xcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xcache \
    && docker-php-ext-enable xcache
#构建出错，等待修复
#+ cd /usr/src/php/ext/openssl
#+ phpize
#Cannot find config.m4.

#RUN apt-get update && apt-get install -y \
#		openssl \
#	&& docker-php-ext-install -j$(nproc) openssl	

#getopt: unrecognized option '--ini-name'

#RUN docker-php-ext-install -j$(nproc) --ini-name 0-apc.ini apcu apc

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 22 80

CMD ["/run.sh"]