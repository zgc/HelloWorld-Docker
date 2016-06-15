FROM ubuntu:xenial
MAINTAINER Guocheng Zheng<hxgsn@hxgsn.com>

# ubuntu
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US en_US.UTF-8
RUN \
	echo "LANG=en_US.UTF-8"  >>  /etc/default/locale

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

RUN \
	dpkg-reconfigure locales \
	&& echo "Asia/Shanghai" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata
	
ENV SOURCES_DOMAIN mirrors.aliyun.com

RUN \
	sed -i "s/archive.ubuntu.com/$SOURCES_DOMAIN/g" /etc/apt/sources.list

# oracle jdk
ENV JAVA_VER 8

RUN \
	echo oracle-java$JAVA_VER-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
	&& echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
	&& echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
	&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
	&& apt update \
	&& apt install -y oracle-java$JAVA_VER-installer oracle-java$JAVA_VER-unlimited-jce-policy \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/oracle-jdk$JAVA_VER*

ENV JAVA_HOME /usr/lib/jvm/java-$JAVA_VER-oracle

# tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

RUN apt update && apt install -y --no-install-recommends \
		curl \
		libapr1 \
		openssl \
	&& rm -rf /var/lib/apt/lists/*

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.2
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# INSTALL TOMCAT
RUN set -ex \
	\
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.sha1" -o tomcat.tar.gz.sha1 \
	&& sha1sum tomcat.tar.gz > tomcat.tar.gz.sha1 \
	&& sha1sum -c tomcat.tar.gz.sha1 \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz* \
	\
	&& nativeBuildDir="$(mktemp -d)" \
	&& tar -xvf bin/tomcat-native.tar.gz -C "$nativeBuildDir" --strip-components=1 \
	&& nativeBuildDeps=" \
			gcc \
			libapr1-dev \
			libssl-dev \
			make \
			" \
	&& apt update && apt install -y --no-install-recommends $nativeBuildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	&& ( \
			export CATALINA_HOME="$PWD" \
			&& cd "$nativeBuildDir/native" \
			&& ./configure \
				--libdir=/usr/lib/jni \
				--prefix="$CATALINA_HOME" \
				--with-apr=/usr/bin/apr-1-config \
				--with-java-home="$JAVA_HOME" \
				--with-ssl=yes \
			&& make -j$(nproc) \
			&& make install \
		) \
	&& apt purge -y --auto-remove $nativeBuildDeps \
	&& rm -rf "$nativeBuildDir" \
	&& rm bin/tomcat-native.tar.gz \
	&& ln -s /usr/lib/jni/libtcnative-1.so /usr/lib/libtcnative-1.so

# verify Tomcat Native is working properly
RUN set -e \
	&& nativeLines="$(catalina.sh configtest 2>&1)" \
	&& nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')" \
	&& nativeLines="$(echo "$nativeLines" | sort -u)" \
	&& if ! echo "$nativeLines" | grep 'INFO: Loaded APR based Apache Tomcat Native library' >&2; then \
			echo >&2 "$nativeLines"; \
			exit 1; \
		fi

# maven
ENV MAVEN_HOME /usr/local/maven
ENV PATH MAVEN_HOME/bin:$PATH
ENV MAVEN_M2 /root/.m2
RUN mkdir -p "$MAVEN_M2"
VOLUME $MAVEN_M2
ENV CLEAN_M2 true
RUN mkdir -p "$MAVEN_HOME"
WORKDIR $MAVEN_HOME

ENV MAVEN_MAJOR_VERSION 3
ENV MAVEN_MINOR_VERSION 3.3.9
ENV MAVEN_TGZ_URL https://archive.apache.org/dist/maven/maven-$MAVEN_MAJOR_VERSION/$MAVEN_MINOR_VERSION/binaries/apache-maven-$MAVEN_MINOR_VERSION-bin.tar.gz

# INSTALL MAVEN
RUN set -ex \
	\
	&& curl -fSL "$MAVEN_TGZ_URL" -o maven.tar.gz \
	&& curl -fSL "$MAVEN_TGZ_URL.sha1" -o maven.tar.gz.sha1 \
	&& sha1sum maven.tar.gz > maven.tar.gz.sha1 \
	&& sha1sum -c maven.tar.gz.sha1 \
	&& tar -xvf maven.tar.gz --strip-components=1 \
	&& rm bin/*.cmd \
	&& rm maven.tar.gz* \
	&& ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn

# code
ENV CODE /root/code
RUN mkdir -p "$CODE"
VOLUME $CODE
ENV CLEAN_CODE false

WORKDIR $CATALINA_HOME

RUN apt purge -y --auto-remove curl \
	&& apt autoclean && apt --purge -y autoremove \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080
CMD ["/run.sh"]
