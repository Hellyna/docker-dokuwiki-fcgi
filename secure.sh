cd /etc/dokuwiki
chown -R root:root .
chown dokuwiki:dokuwiki \
  acl.auth.php \
  local.php local.php.bak \
  plugins.local.php plugins.local.php.bak \
  users.auth.php

cd /var/lib/dokuwiki
chown -R dokuwiki:dokuwiki .
chown -R dokuwiki:dokuwiki /srv/www/dokuwiki/lib/plugins
