test $# -ne 1 && exit 1

sh secure.sh

case $1 in
  setup)
    chown dokuwiki:dokuwiki /srv/chroot/dokuwiki/etc/dokuwiki
    cd /srv/chroot/dokuwiki/srv/www/dokuwiki
    ln -sf ../../../var/lib/dokuwiki data
    ln -sf ../../../etc/dokuwiki conf
    ;;
  production)
    mv /root/preload.php /srv/chroot/dokuwiki/srv/www/dokuwiki/inc/preload.php
    ;;
esac

exec /usr/sbin/php-fpm7 --nodaemonize
