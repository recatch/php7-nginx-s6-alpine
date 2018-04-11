#!/usr/bin/with-contenv bash

SYMFONY=${SYMFONY:-false}
DEBUG=${DEBUG:-false}
NGINX_TEMPLATE=/etc/nginx/host.d/php.tmpl
if [ "$SYMFONY" == "true" ]; then
    SYMFONY_VERSION=${SYMFONY_VERSION:-"3"}
    NGINX_TEMPLATE=/etc/nginx/host.d/symfony.tmpl
    if [ "$SYMFONY_VERSION" == "4" ]; then
        NGINX_TEMPLATE=/etc/nginx/host.d/symfony.4.tmpl
    elif [ "$DEBUG" == "true" ]; then
        NGINX_TEMPLATE=/etc/nginx/host.d/symfony.dev.tmpl
    fi
fi

> /etc/nginx/host.d/sites.conf

while IFS='=' read -r name virtual_host ; do
    number=$(echo "$name" | cut -d"_" -f3)
    server_root_var="SERVER_ROOT_$number"
    if [ -z "$number" ]; then server_root_var="SERVER_ROOT"; else server_root_var="SERVER_ROOT_$number"; fi

    content=$(env | sort | grep "^$server_root_var=")
    server_root=$(echo "$content" | cut -d"=" -f2)

    if [ ! -z "$server_root" ]; then
        virtual_host=$(echo "$virtual_host" | sed "s/,/ /g")
        sed 's#{{VIRTUAL_HOST}}#'"$virtual_host"'#g; s#{{SERVER_ROOT}}#'"$server_root"'#g' "$NGINX_TEMPLATE" >> /etc/nginx/host.d/sites.conf
    fi
done < <(env | sort | grep '^VIRTUAL_HOST')
