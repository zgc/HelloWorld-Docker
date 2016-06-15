#!/bin/bash

if [ ! -f $CATALINA_HOME/webapps/ROOT.war ] && [ -f $CODE/pom.xml ]; then
	cd $CODE
	mvn install
	rm -rf $CATALINA_HOME/webapps/* 
	cp target/*.war $CATALINA_HOME/webapps/ROOT.war
	rm -rf /usr/bin/mvn
	rm -rf $MAVEN_HOME
fi

if [ ! $CLEAN_CODE = "false" ] || [ $CLEAN_CODE = "true" ] || [ $CLEAN_CODE = "yes" ] || [ ! $CLEAN_CODE = "no" ]; then
	rm -rf $CODE
fi

if [ ! $CLEAN_M2 = "false" ] || [ $CLEAN_M2 = "true" ] || [ $CLEAN_M2 = "yes" ] || [ ! $CLEAN_M2 = "no" ]; then
	rm -rf $MAVEN_M2
fi

exec catalina.sh run
