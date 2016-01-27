#镜像来源
[https://hub.docker.com/r/library/php/](https://hub.docker.com/r/library/php/ "(5.6/apache/Dockerfile)")
	
	FROM php:5.6-apache

#应用存放
	COPY app/ /var/www/html/

#自定义配置文件
	COPY config/php.ini /usr/local/etc/php/

#安装PHP扩展参考
	RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd


#默认开放端口
    EXPOSE 22 80

#配置Mysql数据库变量
	ENV HOSTNAME        localhost      
	ENV USERNAME        yourDBUser
	ENV PASSWORD        yourDBPassword
	ENV DATABASE        yourDBName

#root登录密码可查看docker的log输出
	========================================================================
	You can now connect to this Ubuntu container via SSH using:

	    ssh -p 		<port> root@<host>
	and enter the root password 'U0iSGVUCr7W3' when prompted

	Please remember to change the above password as soon as possible!
	========================================================================


In this case, `U0iSGVUCr7W3` is the password allocated to the `root` user.

Done!

#为root设置固定密码
	ENV ROOT_PASS        mypass

#导入授权key登录ssh
	ENV AUTHORIZED_KEYS		`cat ~/.ssh/id_rsa.pub`