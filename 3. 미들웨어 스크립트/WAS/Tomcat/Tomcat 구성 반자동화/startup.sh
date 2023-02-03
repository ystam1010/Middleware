#!/bin/bash
export OSUSER=erpwas
export JAVA_HOME=/usr/lib/jvm/java-11
export CATALINA_INST=erpdev
export CATALINA_HOME=/app/WAS/tomcat
export CATALINA_BASE=$CATALINA_HOME/servers/$CATALINA_INST
export CATALINA_LOG=$CATALINA_BASE/logs
export HEAP_SIZE=64
export CATALINA_OPTS="$CATALINA_OPTS \
       -D$CATALINA_INST -server -Xmx${HEAP_SIZE}M -Xms${HEAP_SIZE}M \
       -XX:+DoEscapeAnalysis \
       -XX:+CMSClassUnloadingEnabled -XX:+DisableExplicitGC \
       -XX:CMSInitiatingOccupancyFraction=80 -XX:CMSIncrementalSafetyFactor=20 \
       -XX:+UseCMSInitiatingOccupancyOnly \
       -Xlog:gc*,safepoint=info:file=$CATALINA_LOG/gclog/gc_${CATALINA_INST}.log.`date +%Y%m%d%H%M%S`:time,uptime:filecount=31,filesize=8M  \
       -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$CATALINA_LOG \
       -Djava.net.preferIPv4Stack=true \
       -Djava.net.preferIPv6Addresses=false \
       -Djava.security.egd=file:///dev/urandom \
       -Dfile.encoding=UTF-8 \
       --add-opens=java.base/java.lang=ALL-UNNAMED \
       --add-opens=java.base/java.io=ALL-UNNAMED \
       --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED "
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib/apr/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/bin

#export SCOUTER_AGENT_DIR="/app/scouter/agent.java"
#export CATALINA_OPTS="$CATALINA_OPTS -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar -Dscouter.conf=${SCOUTER_AGENT_DIR}/conf/scouter.conf -Dobj_name=${CATALINA_INST}"


# O/S User
if [ ${LOGNAME} != "${OSUSER}" ]
then
    echo "OS USER MUST BE [${OSUSER}]!"
    exit 1
fi

# process running
PID=`ps -ef | grep java | grep D${CATALINA_INST} | grep org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{print $2}'`
if [ "$PID" != "" ]
then
    echo Process is running !!!
    exit 1
fi

$CATALINA_HOME/bin/startup.sh

