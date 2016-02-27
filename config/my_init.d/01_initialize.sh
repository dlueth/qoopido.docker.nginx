#!/bin/bash

HOSTNAME=$(hostname)
UP="/etc/nginx/up.sh"
FILE_KEY="/app/data/certificates/$HOSTNAME.key"
FILE_CRT="/app/data/certificates/$HOSTNAME.crt"

if [ -d /app/config ]
then
	files=($(find /app/config -type f))

	for source in "${files[@]}"
	do
		pattern="\.DS_Store"
		target=${source/\/app\/config/\/etc\/nginx}

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
mkdir -p /app/data/certificates
mkdir -p /app/data/logs
mkdir -p /app/config

if [ -f $UP ]
then
	 chmod +x $UP && chmod 755 $UP && eval $UP;
fi