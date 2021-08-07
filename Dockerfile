# Alpine Linux with s6 service management
FROM smebberson/alpine-base:3.3.0

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
	# Install Apache2 and other stuff needed to access svn via WebDav
	# Install svn
	# Installing utilities for SVNADMIN frontend
	# Create required folders
	# Create the authentication file for http access
	# Getting SVNADMIN interface
COPY svnadmin-1.6.2.zip  /opt/
COPY websvn-2.3.3.tar.gz /opt/
COPY enscript-1.6.6-r3.apk /opt/
RUN apk add --no-cache apache2 apache2-utils apache2-webdav apache2-ldap mod_dav_svn &&\
	apk add --no-cache subversion &&\
	apk add --no-cache curl wget unzip sed tar zip gzip php7 php7-apache2 php7-session php7-json php7-ldap &&\
	apk add --no-cache php7-xml &&\	
	sed -i 's/;extension=ldap/extension=ldap/' /etc/php7/php.ini &&\
	mkdir -p /run/apache2/ &&\
	mkdir /home/svn/ &&\
	mkdir /etc/subversion &&\
	touch /etc/subversion/passwd &&\
    #wget --no-check-certificate https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.zip &&\
	#unzip stable-1.6.2.zip -d /opt &&\
	#rm stable-1.6.2.zip &&\
	unzip /opt/svnadmin-1.6.2.zip -d /opt &&\
	mv /opt/iF.SVNAdmin-stable-1.6.2 /opt/svnadmin &&\
	ln -s /opt/svnadmin /var/www/localhost/htdocs/svnadmin &&\
	#wget http://dl-cdn.alpinelinux.org/alpine/v3.12/community/x86_64/enscript-1.6.6-r3.apk &&\
	#apk add enscript-1.6.6-r3.apk &&\
	#rm enscript-1.6.6-r3.apk &&\
	apk add /opt/enscript-1.6.6-r3.apk &&\
	#curl -f -L http://websvn.tigris.org/files/documents/1380/49056/websvn-2.3.3.tar.gz | tar -C /opt -xzv &&\
	tar -zxf /opt/websvn-2.3.3.tar.gz -C /opt &&\
	mv /opt/websvn-2.3.3 /opt/websvn &&\
	ln -s /opt/websvn /var/www/localhost/htdocs/websvn 


# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)	
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

# Fixing https://github.com/mfreiholz/iF.SVNAdmin/issues/118
ADD svnadmin/classes/util/global.func.php /opt/svnadmin/classes/util/global.func.php

# Add services configurations
ADD apache/ /etc/services.d/apache/
ADD subversion/ /etc/services.d/subversion/

# Add SVNAuth file
ADD subversion-access-control /etc/subversion/subversion-access-control
RUN chmod a+w /etc/subversion/* && chmod a+w /home/svn

# Add WebDav configuration
ADD dav_svn.conf /etc/apache2/conf.d/dav_svn.conf

# Add svnadmin configuration
ADD svnadmin/data/config.ini  /opt/svnadmin/data/config.ini
ADD svnadmin/data/userroleassignments.ini  /opt/svnadmin/data/userroleassignments.ini
RUN chmod -R 777 /opt/svnadmin/data

# Add websvn configuration
ADD websvn/include/config.php  /opt/websvn/include/config.php
RUN chmod -R 777 /opt/websvn/include

# Set HOME in non /root folder
ENV HOME /home

# Expose ports for http and custom protocol access
EXPOSE 80
