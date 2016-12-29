#!/usr/bin/with-contenv sh

add_config() {
    ini="/usr/local/etc/php/conf.d/docker-php-ext-$2.ini"
    if ! grep -q "$1" "$ini" 2>/dev/null; then
		echo "$1" >> "$ini"
	fi
}

# Use the TZ environment variable, otherwise use UTC
TZ=${TZ:-UTC}
sed -i "s#;?date.timezone =.*#date.timezone = $TZ#" /usr/local/etc/php/php.ini
APP_ENV=${APP_ENV:-prod}
sed -i "s#env\[APP_ENV\] = .*#env[APP_ENV] = ${APP_ENV}#" /usr/local/etc/php-fpm.conf

docker-php-ext-enable opcache
add_config opcache.enable_cli=1 opcache
add_config opcache.save_comments=1 opcache
add_config opcache.fast_shutdown=1 opcache
add_config opcache.revalidate_freq=0 opcache
add_config opcache.max_accelerated_files=100000 opcache
add_config opcache.memory_consumption=128 opcache

if [ "${APP_ENV}" == "prod" ]; then
    add_config opcache.validate_timestamps=0 opcache
fi

DEBUG=${DEBUG:-false}
if [ "${DEBUG}" == "true" ]; then
    sed -i 's#^display_errors = Off#display_errors = On#' /usr/local/etc/php/php.ini
    docker-php-ext-enable xdebug
    add_config xdebug.remote_enable=1 xdebug
    if [ ! -z "$XDEBUG_HOST" ]; then
        add_config xdebug.remote_host=${XDEBUG_HOST} xdebug
    else
        add_config xdebug.remote_connect_back=1 xdebug
    fi
    if [ ! -z "$XDEBUG_PORT" ]; then
        add_config xdebug.remote_port=${XDEBUG_PORT} xdebug
    fi
fi

ENABLE_PHP_ENV=${ENABLE_PHP_ENV:-false}
if [ "${ENABLE_PHP_ENV}" == "true" ]; then
    sed -i 's#clear_env = yes#clear_env = no#' /usr/local/etc/php/php-fpm.conf
fi
