#!/bin/bash

HOSTNAME=$(hostname)
INIT="/etc/nginx/initialize.sh"
FILE_KEY="/app/ssl/$HOSTNAME.key"
FILE_CRT="/app/ssl/$HOSTNAME.crt"

if [ -d /app/config/nginx ]
then
	files=($(find /app/config/nginx -type f))

	for source in "${files[@]}"
	do
		pattern="\.DS_Store"
		target=${source/\/app\/config\/nginx/\/etc\/nginx}

		if [[ ! $target =~ $pattern ]]; then
			if [[ -f $target ]]; then
				echo "    Removing \"$target\"" && rm -rf $target
			fi

			echo "    Copying \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && cp $source $target
		fi
	done
fi

if [ -d /etc/nginx ]
then
	find /etc/nginx -type f -print0 | xargs -0 sed -i "s/\${HOSTNAME}/${HOSTNAME}/g"
fi

if [ ! -f $FILE_KEY ]
then
	openssl req -x509 -nodes -days 36500 -newkey rsa:8192 -keyout $FILE_KEY -out $FILE_CRT -subj "/C=DE/ST=None/L=None/O=None/OU=None/CN=$HOSTNAME"
fi

mkdir -p /app/htdocs
mkdir -p /app/ssl
mkdir -p /app/logs/nginx

if [ -f $INIT ]
then
	 chmod +x $INIT && chmod 755 $INIT && eval $INIT;
fi