# docker-dokuwiki-fcgi

[![Docker](https://github.com/Hellyna/docker-dokuwiki-fcgi/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Hellyna/docker-dokuwiki-fcgi/actions/workflows/docker-publish.yml)

A alpine based, pure php-fpm docker image for dokuwiki:

+ location of conf: `/etc/dokuwiki`
+ location of data: `/var/lib/dokuwiki/data`
+ location of plugins: `/var/lib/dokuwiki/plugins`
+ location of library images: `/var/lib/dokuwiki/images`
+ location of templates: `/var/lib/dokuwiki/templates`
+ location of php-fpm logs: `/var/log/dokuwiki`

## How to run

Please see [docker-compose.yml](https://github.com/Hellyna/docker-dokuwiki-fcgi/blob/master/docker-compose.yml)


## Update

To update, you will need to delete, and recreate the `dokuwiki-www` volume after pulling this image. The reason is because that `dokuwiki-www` is meant to be a ephemeral volume but it is persisted because it is shared with [quiexotic/dokuwiki-nginx](https://github.com/Hellyna/docker-dokuwiki-nginx).

## Special notes about nginx

Refrain from using directives that will check the host OS for files before sending it to the fcgi socket, such as `try_files` or `if ( -f`. Doing so will result in a shortcircuit since the host file in question obviously does not exist on the host, and hence will yield a 404.

## TODO

Generate (php-fpm) config file on the fly based on environmental variables.
