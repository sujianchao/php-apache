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
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
RUN docker-php-ext-install -j$(nproc) mysqli mysql pdo pdo_mysql
RUN docker-php-ext-install -j$(nproc) openssl apcu apc mbstring shmop

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 22 80

CMD ["/run.sh"]