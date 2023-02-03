#!/bin/bash

if [ $# -ne 1 ]; then
	echo ""
	echo "Usage: $0 SERVICENAME"
	echo ""
	exit;
fi

SERVICENAME=$1;
USERNAME=erpwas;
GROUPNAME=erpwas;
echo "$SERVICENAME resource setting";

if [ "$(whoami)" != root ]; then
	echo "ERROR: script excute root user";
	exit;
fi;

SEARCHUSER=`cat /etc/passwd | awk -F: '{print $1}' | grep ${USERNAME}`

if  [ -z ${SEARCHUSER} ]
then
        echo "ERROR: USERNAME not found!";
        echo "adduser ${USERNAME} excute";
        exit;
else
        echo "${USERNAME} start script"
fi;


### 1-4. make directory ###
echo "##############################"
echo "1-4. make directory "
echo "##############################"

mkdir -p /app/WAS
mkdir -p /app/deploy/${SERVICENAME}
mkdir -p /logs/WAS/tomcat/servers/${SERVICENAME}
mkdir -p /logs/WAS/tomcat/servers/${SERVICENAME}/gclog
mkdir -p /logs/WAS/tomcat/servers/${SERVICENAME}/mod_jk
mkdir -p /logs/WAS/application


### 1-5. yum install ###
echo "##############################"
echo "1-5. yum install"
echo "##############################"

yum -y install java-11-openjdk-devel gcc openssl-devel


### 1-6. Tomcat Engine ###
echo "##############################"
echo "1-6. Tomcat Engine"
echo "##############################"

cd /app/src
tar -xvzf  apache-tomcat*.tar.gz -C /app/WAS
ln -s /app/WAS/apache-tomcat* /app/WAS/tomcat

### 1-7. Tomcat APR setting ###
echo "##############################"
echo "1-7. Tomcat APR setting"
echo "##############################"

yum -y install apr-devel redhat-rpm-config make
cd /app/WAS/tomcat/bin/
tar -xf tomcat-native.tar.gz
cd tomcat-native-*/native
./configure --prefix=/app/WAS/tomcat/lib/apr --with-java-home=/usr/lib/jvm/java-11
make && make install

### 1-8. Instance Template Setting ###
echo "##############################"
echo "1-8. Instance Template Setting"
echo "##############################"

cd /app/src
tar -xvf servers.tar -C /app/WAS/tomcat

### 1-9. Grant Directory ###
echo "##############################"
echo "1-9. Grant Directory"
echo "##############################"

chown -R ${USERNAME}.${GROUPNAME} /app/WAS
chown -R ${USERNAME}.${GROUPNAME} /app/deploy
chown -R ${USERNAME}.${GROUPNAME} /logs/WAS

### 1-10. Instance Setting ###
echo "##############################"
echo "1-10. Instance Setting"
echo "##############################"

mv /app/WAS/tomcat/servers/template  /app/WAS/tomcat/servers/${SERVICENAME}
ln -s  /logs/WAS/tomcat/servers/${SERVICENAME} /app/WAS/tomcat/servers/${SERVICENAME}/logs

echo "tomcat install Complate"
