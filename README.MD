# PHP - NGINX Image based on php:7.1.8-fpm-alpine linux and s6-overlay
[https://hub.docker.com/_/php/](https://hub.docker.com/_/php/)

 | Version
--- | ---
[Alpine Linux](https://hub.docker.com/_/alpine/) | 3.4
[PHP](http://php.net/downloads.php) | 7.1.8
[Xdebug](https://github.com/xdebug/xdebug/releases) | 2.5.5
[Nginx](https://nginx.org/en/download.html) | 1.13.4
[S6](https://github.com/just-containers/s6-overlay/releases) | 1.20.0.0

# Available Configuration Parameters

Parameter | Description
--- | ---
`VIRTUAL_HOST`<br>`SERVER_ROOT`<br>`VIRTUAL_HOST_X`<br>`SERVER_ROOT_X` | Handle mapping the web root for multiple point.<br>Format `VIRTUAL_HOST(_X)`: 'a.example.com,b.example.com,*.example.com'<br>Format `SERVER_ROOT(_X)`: '/data/web'
`TZ` | Server [PHP TimeZone](http://php.net/manual/fr/datetime.configuration.php#ini.date.timezone). Default: `UTC`
`APP_ENV` | App environment variable (if required by the app). Default: `prod`.<br>In this case: `opcache.validate_timestamps=0` (https://wiki.mikejung.biz/PHP_OPcache#opcache.validate_timestamps)
`SYMFONY` | Use symfony nginx template. If `DEBUG=true`, load the dev template Default: `false`
`DEBUG` | Activate `Xdebug`, `display_errors=on`, `xdebug.remote_enable=1`. Default: `false`
`XDEBUG_HOST` | Require `DEBUG=true`.<br>Force the remote xdebug host. If not set `remote_connect_back=1`
`XDEBUG_PORT` | Require `DEBUG=true`.<br>Overwrite default `xdebug.remote_port` [9000](https://xdebug.org/docs/all_settings)
`ENABLE_PHP_ENV` | Enable php-fpm access to all environment variable (except YII_ENV). Default: `false`

# Default config files

## Nginx

- [host.d/default.conf](root/etc/nginx/host.d/default.conf): default configuration file

- [host.d/php.tmpl](root/etc/nginx/host.d/php.tmpl): used for `VIRTUAL_HOST(_X)` and `SERVER_ROOT(_X)` variables.

- [host.d/symfony{.dev}.tmpl](root/etc/nginx/host.d/symfony.tmpl): used for `VIRTUAL_HOST(_X)` and `SERVER_ROOT(_X)` variables.

It is possible to mount custom `xxx.conf` files in [`etc/nginx/host.d/`](root/etc/nginx/host.d) to configure specific hosts.

- [`server.d/php.conf`](root/etc/nginx/server.d/php.conf): handle all the Yii PHP requests

- [`server.d/symfony{.dev}.conf`](root/etc/nginx/server.d/symfony.conf): handle all the Symfony PHP requests

- [`nginx.d/01mime.conf`](root/etc/nginx/nginx.d/01mime.conf): handle mime types

- [`nginx.d/02logs.conf`](root/etc/nginx/nginx.d/02logs.conf): log configuration

- [`nginx.d/03performance.conf`](root/etc/nginx/nginx.d/03performance.conf): performance tuning

- [`nginx.d/04gzip.conf`](root/etc/nginx/nginx.d/04gzip.conf): gzip customization

- [`nginx.d/05upstream.conf`](root/etc/nginx/nginx.d/05upstream.conf): php upstream to php-fpm

- [`nginx.d/06realip.conf`](root/etc/nginx/nginx.d/06realip.conf): handle forward ip from possible proxy in front of the container

It is possible to mount custom `07xxx.conf` files in [`etc/nginx/nginx.d/`](root/etc/nginx/nginx.d) to configure the server.

## Php

- [php-fpm.conf](root/usr/local/etc/php-fpm.conf): default fpm configuration file

- [php.ini](root/usr/local/etc/php/php.ini): default php ini file

# Known issue with Docker for Mac

Because xdebug try to retrieve the host ID through a env variable and because of https://docs.docker.com/docker-for-mac/networking/ the container can't reachthe host.

This seems to be the easiest way to setup xdebug to connect back to your IDE running on your host.

The [tv.recatch.docker_10254_alias.plist](https://gist.github.com/recatch/56fb9f5e325cea9e819e61e2ceb80fd2#file-tv-recatch-docker_10254_alias-plist) launchd script will ensure that your Docker environment on your Mac will have 172.0.0.1 as an alias on your loopback device (127.0.0.1).

The command being run is `ifconfig lo0 alias 172.0.0.1`

Similarly, this is a solution for any kind of situations where a container needs to connect back to the host container at a known ip address.

### Installation

Copy the [tv.recatch.docker_10254_alias.plist](https://gist.github.com/recatch/56fb9f5e325cea9e819e61e2ceb80fd2#file-tv-recatch-docker_10254_alias-plist) file to `/Library/LaunchDaemons/tv.recatch.docker_10254_alias.plist` (sudo rights required)

The first time you can load the plist with the command

>sudo launchctl load /Library/LaunchDaemons/tv.recatch.docker_10254_alias.plist

Next and every successive reboot will ensure your lo0 will have the proper ip address.

#### docker-compose.yml

You can just use the `XDEBUG_HOST=172.0.0.1` environment variable
