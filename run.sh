#!/bin/bash

if [ ! -f $CATALINA_HOME/webapps/ROOT.war ] || [ ! $FORCED_COMPILATION = "false" ] || [ $FORCED_COMPILATION = "true" ] || [ $FORCED_COMPILATION = "yes" ] || [ ! $FORCED_COMPILATION = "no" ]; then
		if [ ! -f $CATALINA_HOME/webapps/ROOT.war ]; then
			echo "'ROOT.war' does not exist!"
		elif
			echo "Forced compilation = $FORCED_COMPILATION"
		fi
		if [ -f $CODE/pom.xml ]; then
			cd $CODE
			mvn install
			rm -rf $CATALINA_HOME/webapps/* 
			cp target/*.war $CATALINA_HOME/webapps/ROOT.war
			rm -rf /usr/bin/mvn
			rm -rf $MAVEN_HOME
		elif
			echo "'$CODE/pom.xml' does not exist!"
		fi
elif
	echo "'$CATALINA_HOME/webapps/' in the presence of ROOT.war, give priority to the use of ROOT.war"
fi

echo "Clean code = $CLEAN_CODE"

if [ ! $CLEAN_CODE = "false" ] || [ $CLEAN_CODE = "true" ] || [ $CLEAN_CODE = "yes" ] || [ ! $CLEAN_CODE = "no" ]; then
	rm -rf $CODE
fi

echo "Clean .m2 = $CLEAN_M2"

if [ ! $CLEAN_M2 = "false" ] || [ $CLEAN_M2 = "true" ] || [ $CLEAN_M2 = "yes" ] || [ ! $CLEAN_M2 = "no" ]; then
	rm -rf $MAVEN_M2
fi

exec catalina.sh run
