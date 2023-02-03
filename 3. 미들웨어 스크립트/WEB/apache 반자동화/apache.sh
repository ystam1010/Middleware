#!/bin/bash

if [ $# -ne 1 ]; then
	echo ""
	echo "Usage: $0 SERVICENAME"
	echo ""
	exit;
fi

SERVICENAME=$1;
USERNAME=apache;
echo "$SERVICENAME resource setting";

### 1-1.make directory ###
mkdir -p /app/src

### 1-4. make directory ###
mkdir -p /app/web
mkdir -p /app/deploy/web/${SERVICENAME} 
mkdir -p /logs/web/apache/ip 
mkdir -p /logs/web/apache/${SERVICENAME}/ssl 
mkdir -p /logs/web/apache/${SERVICENAME}/mod_jk 

chown -R ${USERNAME}.${USERNAME} /app/web
chown -R ${USERNAME}.${USERNAME} /app/deploy
chown -R ${USERNAME}.${USERNAME} /logs/web

### 1-5. yum install ###
yum -y install  gcc gcc-c++ make openssl-devel expat-devel libtool


### 1-6. source compile ###
cd /app/src
tar xvzf httpd*.tar.gz 
tar xvzf apr-1.*tar.gz -C /app/src/httpd-2.4*/srclib
tar xvzf apr-util*tar.gz -C /app/src/httpd-2.4*/srclib
tar xvzf tomcat-connectors*
mkdir -p /app/src/tmp 
mv *.gz /app/src/tmp
cd /app/src/httpd-2.4*/srclib
mv apr-1* apr
mv apr-util* apr-util
cd /app/src/httpd-*
/app/src/httpd-2.4*/configure --prefix=/app/web/apache --with-mpm=event --with-crypto --with-included-apr --enable-rewrite --enable-deflate --enable-static-rotatelogs --enable-so --enable-ssl
make && make install


### 1-7. mod_jk compile ###
cd /app/src/tomcat-connectors*/native 
/app/src/tomcat-connectors*/native/configure --with-apxs=/app/web/apache/bin/apxs
make && make install

### 1-8. grant setting ###
chown -R apache.apache /app/web/apache
cd /app/web/apache/bin
chown root httpd
chmod 4755 httpd  


### 1-9. securiy delete ###
rm -f /app/web/apache/conf/extra/httpd-manual.conf
rm -f /app/web/apache/conf/original/extra/httpd-manual.conf
rm -rf /app/web/apache/manual
rm -rf /app/web/apache/cgi-bin

echo "apache install Complate"
