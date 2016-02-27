FROM phusion/baseimage:latest
MAINTAINER Dirk Lüth <info@qoopido.com>

# Initialize environment
	CMD ["/sbin/my_init"]
	ENV DEBIAN_FRONTEND noninteractive

# based on dgraziotin/docker-osx-lamp
	ENV DOCKER_USER_ID 501 
	ENV DOCKER_USER_GID 20
	ENV BOOT2DOCKER_ID 1000
	ENV BOOT2DOCKER_GID 50

# Tweaks to give nginx write permissions to the app
	RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    	usermod -G staff www-data && \
    	groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    	groupmod -g ${BOOT2DOCKER_GID} staff

# configure defaults
	ADD configure.sh /configure.sh
	ADD config /config
	RUN chmod +x /configure.sh && \
		chmod 755 /configure.sh
	RUN /configure.sh && \
		chmod +x /etc/my_init.d/*.sh && \
		chmod 755 /etc/my_init.d/*.sh && \
		chmod +x /etc/service/nginx/run && \
		chmod 755 /etc/service/nginx/run

# add nginx repository
	ADD nginx.key /nginx.key
	RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list && \
		sudo apt-key add nginx.key

# install packages
	RUN apt-get update && \
		apt-get -qy upgrade && \
    	apt-get -qy dist-upgrade && \
    	apt-get install -qy ca-certificates nginx gettext-base
		
# create required directories
	RUN mkdir -p /app/htdocs && \
		mkdir -p /app/data/certificates && \
        mkdir -p /app/data/logs && \
        mkdir -p /app/config

# cleanup
	RUN apt-get clean && \
		apt-get autoclean && \
		apt-get autoremove && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /configure.sh /nginx.key

# finalize
	VOLUME ["/app/htdocs", "/app/data", "/app/config"]
	EXPOSE 80
	EXPOSE 8080
	EXPOSE 443
