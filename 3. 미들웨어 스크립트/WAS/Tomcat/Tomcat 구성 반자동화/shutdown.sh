#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-11
export CATALINA_INST=erpdev
export CATALINA_HOME=/app/WAS/tomcat
export CATALINA_BASE=$CATALINA_HOME/servers/$CATALINA_INST

$CATALINA_HOME/bin/shutdown.sh
