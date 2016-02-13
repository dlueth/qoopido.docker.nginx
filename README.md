# Run container manually ... #
```
docker run -d -P -t -i -p 80:80 -p 443:443 \
	-h [hostname]
	-v [local path to apache htdocs]:/app/htdocs \
	-v [local path to ssl certificates]:/app/ssl \
	-v [local path to logs]:/app/logs \
	-v [local path to config]:/app/config \
	--name nginx qoopido/nginx
```

# ... or use docker-compose #
```
nginx:
  image: qoopido/nginx
  hostname: [hostname]
  ports:
   - "80:80"
   - "443:443"
  volumes:
   - ./htdocs:/app/htdocs
   - ./ssl:/app/ssl
   - ./logs:/app/logs
   - ./config:/app/config
```

# Open shell #
```
docker exec -i -t "nginx" /bin/bash
```

# Project specific configuration #
Any files under ```/app/config/nginx``` will be symlinked into the container's filesystem beginning at ```/etc/nginx```. This can be used to overwrite the container's default site configuration with a custom, project specific configuration to (e.g.) include php fpm fastCGI proxy (which requires linking a php fpm container).

If you need a custom shell script to be run on start (e.g. to set symlinks) you can do so by creating the file ```/app/config/nginx/initialize.sh```.

SSL certificates will be auto-generated per hostname if no key/crt file can be found in /app/ssl/[hostname].[key|crt]