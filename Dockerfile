FROM php:5.6-apache

MAINTAINER SuJianchao <sujianchao@gmail.com>

ENV REFRESHED_AT 2016-01-27

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

ENV AUTHORIZED_KEYS **None**
#ENV ROOT_PASS
ENV SERVERPORTS  	22 80

#Mysql���Ӳ�������
ENV HOSTNAME        localhost      
ENV USERNAME        yourDBUser
ENV PASSWORD        yourDBPassword
ENV DATABASE        yourDBName

#��װapp
COPY config/php.ini /usr/local/etc/php/
COPY app/ /var/www/html/

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE $SERVERPORTS

CMD ["/run.sh"]