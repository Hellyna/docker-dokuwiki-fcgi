from alpine:latest

WORKDIR /root

RUN apk update && \
  apk add \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-opcache \
    php7-session \
    php7-xml

RUN addgroup -S dokuwiki && \
  mkdir -p /srv/chroot/dokuwiki/var/lib && \
  cd /srv/chroot/dokuwiki && \
  adduser -S -G dokuwiki -h var/lib/dokuwiki -s /sbin/nologin dokuwiki && \
  mkdir -p etc srv/www

ADD secure.sh /root/secure.sh

RUN wget https://download.dokuwiki.org/out/dokuwiki-8a269cc015a64b40e4c918699f1e1142.tgz -O dokuwiki.tar.gz && \
  cd /srv/chroot/dokuwiki/srv/www && \
  tar -xf /root/dokuwiki.tar.gz && \
  rm /root/dokuwiki.tar.gz && \
  cd /srv/chroot/dokuwiki && \
  chown -R root:root srv/www/dokuwiki && \
  mv srv/www/dokuwiki/conf etc/dokuwiki && \
  mv srv/www/dokuwiki/data/.htaccess srv/www/dokuwiki/data/* var/lib/dokuwiki && \
  rmdir srv/www/dokuwiki/data && \
  sh /root/secure.sh

ADD preload.php /root/preload.php
ADD entrypoint.sh /root/entrypoint.sh

RUN mv /etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^\[www\].*$/[dokuwiki]/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^listen =.*$/listen = 9000/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^user =.*$/user = dokuwiki/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^group =.*$/group = dokuwiki/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir '/^;php_admin_value\[error_log\] =.*$/s/^;//g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir '/^;php_admin_flag\[log_errors\] =.*$/s/^;//g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^;chroot =.*$/chroot = \/srv\/chroot\/dokuwiki/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[short_open_tag] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[output_buffering] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[output_handler] =' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[zlib.output_compression] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[implicit_flush] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[allow_call_time_pass_reference] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_execution_time] = 30' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_input_time] = 60' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_input_vars] = 10000' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[memory_limit] = 32M' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[error_reporting] = E_ALL & ~E_NOTICE' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[display_errors] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[display_startup_errors] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[variables_order] = EGPCS' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[register_argc_argv] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[magic_quotes_gpc] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[magic_quotes_runtime] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[magic_quotes_sybase] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[file_uploads] = on' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[session.use_cookies] = 1' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[register_globals] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf

VOLUME /srv/chroot/dokuwiki/var/lib/dokuwiki
VOLUME /srv/chroot/dokuwiki/etc/dokuwiki
EXPOSE 9000
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
