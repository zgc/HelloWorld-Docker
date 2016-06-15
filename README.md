docker run --name test -v /home/test/helloworld-docker:/root/code -v /home/test/data/m2:/root/.m2 -v /home/test/data/webapps:/usr/local/tomcat/webapps -e CLEAN_CODE=false -e CLEAN_M2=false -e FORCED_COMPILATION=true -p 80:8080 test <br />
在存在源码和ROOT.war的情况下。优先使用ROOT.war。<br />
默认保存源码、清空maven jar包、不强制编译源码替换ROOT.war<br />
CLEAN_CODE 清空源码<br />
CLEAN_M2 清空maven jar包<br />
FORCED_COMPILATION 在存在ROOT.war的情况下强制编译源码，并替换ROOT.war
