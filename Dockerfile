FROM hyperknot/baseimage16:1.0.0

MAINTAINER friends@niiknow.org

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 TERM=xterm container=docker

# start
RUN \
    cd /tmp \
    && apt-get -o Acquire::GzipIndexes=false update \
    && apt-get update && apt-get -y upgrade \
    && apt-get -y install wget curl unzip nano vim rsync sudo tar git apt-transport-https ca-certificates dnsmasq awscli \
        apt-utils software-properties-common build-essential openssl inotify-tools gettext-base nginx letsencrypt \

    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean autoclean \

# re-enable all default services
    && rm -f /etc/service/syslog-forwarder/down \
    && rm -f /etc/service/cron/down \
    && rm -f /etc/service/syslog-ng/down

ADD ./files /

# tweaks
RUN \
    cd /tmp \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.old \
    && mv /etc/nginx/nginx.new /etc/nginx/nginx.conf \
    && rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/mainsite /etc/nginx/sites-enabled/mainsite \

# generate fake ssl for mainsite conf, do letsencrypt later
    && bash /root/bin/example-ssl.sh \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /var/www \

    && mkdir -p /app-start/etc/letsencrypt \
    && chmod 0755 /app-start/etc/letsencrypt \
    && ln -s /app/etc/letsencrypt /etc/letsencrypt \

    && mkdir -p /app-start/var/log \
    && mkdir -p /app-start/var/www \
    && mkdir -p /app-start/var/spool \
    && chown -R www-data:www-data /app-start/var/www \

    && mv /etc/nginx   /app-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /app/etc/nginx /etc/nginx \

    && mv /var/log/nginx   /app-start/var/log/nginx \
    && rm -rf /var/log/nginx \
    && ln -s /app/var/log/nginx /var/log/nginx \

    && mv /var/www/html   /app-start/var/www/html \
    && rm -rf /var/www/html \
    && ln -s /app/var/www/html /var/www/html \
    && chown -R www-data:www-data /app-start/var/www/html \

# link root to save root crontab if any?
    && mv /root   /app-start/root \
    && rm -rf /root \
    && ln -s /app/root /root \

    && rm -rf /tmp/*

ENV WEBROOT_PATH=/app/var/www/html

VOLUME ["/app", "/backup"]

EXPOSE 80 443
