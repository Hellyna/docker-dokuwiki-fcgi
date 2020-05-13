# docker-dokuwiki-fcgi

A alpine based, pure php-fpm docker image for dokuwiki with maximum security:

+ php-fpm chroot enabled
+ location of conf: `/srv/chroot/dokuwiki/etc/dokuwiki`
+ location of data: `/srv/chroot/dokuwiki/var/lib/dokuwiki`

This docker image does not include nginx, please bring your own.

## How to run

Run in installation mode:
```sh
docker run -it -name dokuwiki-fcgi --rm \
  --publish 127.0.0.1:9000 # To be used by nginx \
  --volume /srv/docker/dokuwiki/conf:/srv/chroot/dokuwiki/etc/dokuwiki \
  --volume /srv/docker/dokuwiki/data:/srv/chroot/dokuwiki/var/lib/dokuwiki \
  quiexotic/dokuwiki-fcgi setup
```

After installation is done, run in production:
```sh
docker run -it -name dokuwiki-fcgi --rm \
  --publish 127.0.0.1:9000 # To be used by nginx \
  --volume /srv/docker/dokuwiki/conf:/srv/chroot/dokuwiki/etc/dokuwiki \
  --volume /srv/docker/dokuwiki/data:/srv/chroot/dokuwiki/var/lib/dokuwiki \
  quiexotic/dokuwiki-fcgi production
```

You can drop in your own config/data files in those volumes, for existing installation. The dokuwiki core files themselves will change with update.

## Special notes about nginx

Refrain from using directives that will check the host OS for files before sending it to the fcgi socket, such as `try_files` or `if ( -f`. Doing so will result in a shortcircuit since the host file in question obviously does not exist on the host, and hence will yield a 404.


