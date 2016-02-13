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
	
# install packages
	RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
		echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list && \
		apt-get update && \
		apt-get -qy upgrade && \
    	apt-get -qy dist-upgrade && \
    	apt-get install -qy ca-certificates nginx gettext-base
		
# create required directories
	RUN mkdir -p /app/htdocs && \
		mkdir -p /app/ssl && \
		mkdir -p /app/logs/nginx

# cleanup
	RUN apt-get clean && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /configure.sh

# finalize
	VOLUME ["/app/htdocs", "/app/ssl", "/app/logs", "/app/config"]
	EXPOSE 80
	EXPOSE 443
