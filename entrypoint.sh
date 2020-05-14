test $# -ne 1 && exit 1

sh secure.sh

case $1 in
  setup)
    chown dokuwiki:dokuwiki /etc/dokuwiki
    cd /srv/www/dokuwiki
    mv /root/phpinfo.php /srv/www/dokuwiki/phpinfo.php
    ln -sf /var/lib/dokuwiki data
    ln -sf /etc/dokuwiki conf
    ;;
  production)
    mv /root/preload.php /srv/www/dokuwiki/inc/preload.php
    rm -f /srv/www/dokuwiki/install.php
    rm -f /srv/www/dokuwiki/phpinfo.php
    ;;
esac

exec /usr/sbin/php-fpm7 --nodaemonize
