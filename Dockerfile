from alpine:latest

WORKDIR /root

RUN apk update && \
  apk add \
    freetype \
    gd \
    libpng \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-opcache \
    php7-openssl \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader && \
  rm -rf /var/cache/apk/*

RUN addgroup -S dokuwiki && \
  mkdir -p /var/lib && \
  adduser -S -G dokuwiki -h /var/lib/dokuwiki -s /sbin/nologin dokuwiki

ADD secure /usr/local/bin/secure

RUN wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz -O dokuwiki.tar.gz && \
  mkdir -p /srv/www/dokuwiki && \
  cd /srv/www/dokuwiki && \
  tar -xf /root/dokuwiki.tar.gz -C . --strip-components 1 && \
  rm /root/dokuwiki.tar.gz && \
  chown -R root:root /srv/www/dokuwiki && \
  mv /srv/www/dokuwiki/conf /etc/dokuwiki && \
  mkdir -p /var/lib/dokuwiki/data && \
  mv /srv/www/dokuwiki/data/.htaccess /srv/www/dokuwiki/data/* /var/lib/dokuwiki/data && \
  rmdir /srv/www/dokuwiki/data && \
  mkdir -p /var/lib/dokuwiki/plugins && \
  mv /srv/www/dokuwiki/lib/plugins/* /var/lib/dokuwiki/plugins && \
  rmdir /srv/www/dokuwiki/lib/plugins && \
  ln -sf /var/lib/dokuwiki/plugins /srv/www/dokuwiki/lib/plugins && \
  mkdir -p /var/lib/dokuwiki/templates && \
  mv /srv/www/dokuwiki/lib/tpl/* /var/lib/dokuwiki/templates && \
  rmdir /srv/www/dokuwiki/lib/tpl && \
  ln -sf /var/lib/dokuwiki/templates /srv/www/dokuwiki/lib/tpl && \
  mkdir -p /var/lib/dokuwiki/images && \
  mv /srv/www/dokuwiki/lib/images/* /var/lib/dokuwiki/images && \
  rmdir /srv/www/dokuwiki/lib/images && \
  ln -sf /var/lib/dokuwiki/images /srv/www/dokuwiki/lib/images && \
  mkdir -p /var/log/dokuwiki && \
  secure

ADD preload.php /root/preload.php
ADD phpinfo.php /root/phpinfo.php
ADD entrypoint /usr/local/bin/entrypoint

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
  echo 'php_admin_value[error_log] = /var/log/dokuwiki/error.log' >> /etc/php7/php-fpm.d/dokuwiki.conf && \
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
  echo 'php_admin_value[open_basedir] = /srv/www/dokuwiki:/var/lib/dokuwiki/data:/var/lib/dokuwiki/images:/var/lib/dokuwiki/plugins:/var/lib/dokuwiki/templates:/etc/dokuwiki:/tmp' >> /etc/php7/php-fpm.d/dokuwiki.conf

EXPOSE 9000
ENTRYPOINT ["entrypoint"]
