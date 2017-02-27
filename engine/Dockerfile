# engine/Dockerfile
FROM debian:jessie

# enable docker repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install locales-all
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install net-tools dnsutils whois strace
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bash bash-completion
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server openssh-client rsync
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install lynx curl wget netcat whatweb
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install imagemagick
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ssl-cert

# timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# logs directory
RUN mkdir -p /var/log/dockersite && \
    chmod 777 /var/log/dockersite

# apache
COPY 000-default.conf /etc/apache2/sites-enabled/

RUN make-ssl-cert generate-default-snakeoil
RUN a2enmod rewrite && \
    a2enmod headers && \
    a2enmod expires && \
    a2enmod include && \
    a2enmod ssl && \
    a2enmod vhost_alias && \
    echo 'Servername localhost' >> /etc/apache2/apache2.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf && \
    sed -i 's/export APACHE_LOG_DIR=.*/export APACHE_LOG_DIR=\/var\/log\/dockersite$SUFFIX/g' /etc/apache2/envvars && \
    sed -i 's/Listen 80/Listen 0.0.0.0:80/g' /etc/apache2/ports.conf && \
    sed -i 's/Listen 443/Listen 0.0.0.0:443/g' /etc/apache2/ports.conf && \
    sed -i 's/CustomLog ${APACHE_LOG_DIR}\/access.log combined/CustomLog ${APACHE_LOG_DIR}\/access.log dockersite/g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's/CustomLog ${APACHE_LOG_DIR}\/access.log combined/CustomLog ${APACHE_LOG_DIR}\/access.log dockersite/g' /etc/apache2/sites-available/default-ssl.conf && \
    mkdir -p /etc/apache2/dockersite && \
    echo 'LogFormat "%V:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" dockersite' >> /etc/apache2/apache2.conf && \
    echo 'IncludeOptional dockersite/*.conf' >> /etc/apache2/apache2.conf

# apache: workaround for write permission
RUN sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=roddocker/g" /etc/apache2/envvars && \
    sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=roddocker/g" /etc/apache2/envvars && \
    chgrp roddocker /var/lib/phpmyadmin/* /etc/phpmyadmin/config-db.php /etc/phpmyadmin/htpasswd.setup


# phpmyadmin
RUN echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf && \
    sed -i 's/    \/\/ $cfg\['\''Servers'\''\]\[$i\]\['\''AllowNoPassword'\''\] = TRUE/    $cfg\['\''Servers'\''\]\[$i\]\['\''AllowNoPassword'\''\] = TRUE/g' /etc/phpmyadmin/config.inc.php && \
    sed -i "s/^\$dbuser='phpmyadmin';/\$dbuser='root';/g" /etc/phpmyadmin/config-db.php && \
    sed -i "s/^\$dbpass='.*';/\$dbpass=getenv('MYSQL_FORCED_ROOT_PASSWORD');/g" /etc/phpmyadmin/config-db.php && \
    echo '<?php' > /etc/phpmyadmin/conf.d/roddocker.php && \
    echo '$cfg["MaxNavigationItems"] = 500;' >> /etc/phpmyadmin/conf.d/roddocker.php && \
    echo '$sessionDuration = 60*60*24*7; // 60*60*24*7 = one week' >> /etc/phpmyadmin/conf.d/roddocker.php && \
    echo 'ini_set("session.gc_maxlifetime", $sessionDuration);' >> /etc/phpmyadmin/conf.d/roddocker.php && \
    echo '$cfg["LoginCookieValidity"] = $sessionDuration;' >> /etc/phpmyadmin/conf.d/roddocker.php

# mysql (mariadb)
RUN sed -i "s/^bind-address.*/bind-address = 0.0.0.0/g" /etc/mysql/my.cnf && \
    sed -i "s/^query_cache_limit.*/slow_query_log = 1\nslow_query_log_file = \/var\/log\/dockersite\/mysql-slow.log\nlong_query_time = 2/g" /etc/mysql/my.cnf && \
    sed -i "s/^query_cache_size.*/query_cache_type = 1\nquery_cache_limit = 16M\nquery_cache_size = 256M\nopen_files_limit = 9999\ninnodb_buffer_pool_size = 32M\nmax_allowed_packet = 32M\ninnodb_log_file_size = 32M\n/g" /etc/mysql/my.cnf && \
    sed -i "s/#character-set-server/character-set-server/g" /etc/mysql/conf.d/mariadb.cnf && \
    sed -i "s/#character_set_server/character_set_server/g" /etc/mysql/conf.d/mariadb.cnf && \
    sed -i "s/#collation-server/collation-server/g" /etc/mysql/conf.d/mariadb.cnf && \
    sed -i "s/#collation_server/collation_server/g" /etc/mysql/conf.d/mariadb.cnf && \
    sed -i "s/#default-character-set/default-character-set/g" /etc/mysql/conf.d/mariadb.cnf
COPY perfs.cnf /etc/mysql/conf.d/

# ssh
RUN sed -i "s/^Port 22/Port 8022/g" /etc/ssh/sshd_config && \
    sed -i "s/^PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
# copy your *readonly* mounted ssh keys and config everytime you login
COPY copy-ssh-config.sh /
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
RUN mkdir -p /home/roddocker/.ssh && chmod 700 /home/roddocker

# cd /var/www/html at startup
RUN echo 'cd /var/www/html' >> /home/roddocker

# longer log messages
RUN echo '$MaxMessageSize 20k' > /etc/rsyslog.d/roddocker.conf/.bashrc/.ssh

# start ssh-agent at startup
RUN echo 'if [ "$(pgrep ssh-agent)" == "" ]; then SSHAGENTEVAL="$(ssh-agent -s)"; echo "$SSHAGENTEVAL" | grep -v echo >> /home/roddocker/.bashrc; eval "$SSHAGENTEVAL"; fi' >> /home/roddocker/.bashrc

# source custom bashrc file at startup
RUN echo "for f in \$(find /home/roddocker/bashrc.d -maxdepth 1 -type f -name '*.sh'); do source \$f; done" >> /home/roddocker/.bashrc

RUN echo '' > /etc/motd

RUN echo roddocker:roddocker | chpasswd

# expose ports
EXPOSE 8022
EXPOSE 80
EXPOSE 443
EXPOSE 3306
