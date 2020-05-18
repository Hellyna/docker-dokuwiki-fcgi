from alpine:latest

WORKDIR /root

RUN apk update && \
  apk add \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-opcache \
    php7-openssl \
    php7-session \
    php7-xml && \
  rm -rf /var/cache/apk/*

RUN addgroup -S dokuwiki && \
  mkdir -p /var/lib && \
  adduser -S -G dokuwiki -h /var/lib/dokuwiki -s /sbin/nologin dokuwiki

ADD secure.sh /root/secure.sh

RUN wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz -O dokuwiki.tar.gz && \
  mkdir -p /srv/www/dokuwiki && \
  cd /srv/www/dokuwiki && \
  tar -xf /root/dokuwiki.tar.gz -C . --strip-components 1 && \
  rm /root/dokuwiki.tar.gz && \
  chown -R root:root /srv/www/dokuwiki && \
  mv /srv/www/dokuwiki/conf /etc/dokuwiki && \
  mv /srv/www/dokuwiki/data/.htaccess /srv/www/dokuwiki/data/* /var/lib/dokuwiki && \
  rmdir /srv/www/dokuwiki/data && \
  sh /root/secure.sh

ADD preload.php /root/preload.php
ADD phpinfo.php /root/phpinfo.php
ADD entrypoint.sh /root/entrypoint.sh

RUN mv /etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^\[www\].*$/[dokuwiki]/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^listen =.*$/listen = 9000/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^user =.*$/user = dokuwiki/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  sed -ir 's/^group =.*$/group = dokuwiki/g' /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[short_open_tag] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[output_buffering] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[output_handler] =' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[zlib.output_compression] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[implicit_flush] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[allow_call_time_pass_reference] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_execution_time] = 30' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_input_time] = 60' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[max_input_vars] = 10000' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[error_log] = /dev/stderr' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[log_errors] = yes' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
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
  echo 'php_admin_flag[register_globals] = off' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_flag[opcache.validate_root] = on' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
  echo 'php_admin_value[open_basedir] = /srv/www/dokuwiki:/var/lib/dokuwiki:/etc/dokuwiki:/tmp' >> /etc/php7/php-fpm.d/dokuwiki.conf

VOLUME /var/lib/dokuwiki
VOLUME /etc/dokuwiki
VOLUME /srv/www/dokuwiki/lib/plugins
EXPOSE 9000
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
