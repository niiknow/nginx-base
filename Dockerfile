FROM niiknow/docker-hostingbase:0.8.3

MAINTAINER friends@niiknow.org

ENV DEBIAN_FRONTEND=noninteractive

# start
RUN \
    cd /tmp \
    && apt-get update && apt-get -y upgrade \

# nginx
    && apt-get install -y nginx \

# aws cli
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py \
    && pip install awscli \

    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean 

ADD ./files /

# tweaks
RUN \
    cd /tmp \
    && mkdir -p /hitcounter-start/etc \

    && mv /etc/nginx   /hitcounter-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /hitcounter/etc/nginx /etc/nginx \

    && mv /etc/letsencrypt   /hitcounter-start/etc/letsencrypt \
    && rm -rf /etc/letsencrypt \
    && ln -s /hitcounter/etc/letsencrypt /etc/letsencrypt \

    && rm -rf /tmp/*

VOLUME ["/hitcounter", "/backup"]

EXPOSE 22 80 443
