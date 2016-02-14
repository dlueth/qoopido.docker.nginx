# recommended directory structure #
Like with my other containers I encourage you to follow a unified directory structure approach to keep things simple & maintainable, e.g.:

```
project root
  - docker_compose.yaml
  - config
    - nginx
      - sites-enabled
      - snippets
  - htdocs
  - ssl
  - logs
```

# Example docker_compose.yaml #
```
web:
  image: qoopido/nginx:latest
  hostname: [hostname]
  ports:
   - "80:80"
   - "443:443"
  volumes:
   - ./config:/app/config
   - ./htdocs:/app/htdocs
   - ./ssl:/app/ssl
   - ./logs:/app/logs
```

# Or start container manually #
```
docker run -d -P -t -i -p 80:80 -p 443:443 \
	-h [hostname]
	-v [local path to config]:/app/config \
	-v [local path to htdocs]:/app/htdocs \
	-v [local path to ssl certificates]:/app/ssl \
	-v [local path to logs]:/app/logs \
	--name web qoopido/nginx:latest
```

# Configuration #
The container comes with a default configuration for nginx under ```/etc/nginx/nginx.conf``` that sets ``` daemon off;``` and globally enabled gzip compression. The container does not come with any kind of default site-configuration.

Any files mounted under ```/app/config/nginx``` will be copied into the container's filesystem beginning at ```/etc/nginx```. This may be used to overwrite the container's default nginx configuration with a custom, project specific configuration to (e.g.) include php fpm fastCGI proxy (which requires linking a php fpm container). Every file will be searched for a string ```${HOSTNAME}``` which will be replaced by the actual hostname.

If you need a custom shell script to be run on start (e.g. to set symlinks) you can do so by creating the file ```/app/config/nginx/initialize.sh```.

SSL certificates will be auto-generated per hostname if no key/crt file can be found in ```/app/ssl/[hostname].[key|crt]```.