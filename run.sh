#!/bin/bash

if [! -f $CATALINA_HOME/webapps/ROOT.war] && [-f $CODE/pom.xml]; then
	cd $CODE
	mvn install
	rm -rf $CATALINA_HOME/webapps/* 
	cp target/*.war $CATALINA_HOME/webapps/ROOT.war
	rm -rf /usr/bin/mvn
	rm -rf $MAVEN_HOME
	if [! $DELETE_M2 = "false"] || [$DELETE_M2 = "true"] || [$DELETE_M2 = "yes"] || [! $DELETE_M2 = "no"]; then
		rm -rf $DELETE_M2;
	fi
fi

rm -rf $CODE

exec catalina.sh run
