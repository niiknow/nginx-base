#!/bin/bash

export TERM=xterm

if [ -z "`ls /app --hide='lost+found'`" ]
then
    mkdir -p /app
    rsync -a /app-start/* /app/
fi

# if file exists
if [ -f /etc/nginx/nginx.new ]; then
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.old
	mv /etc/nginx/nginx.new /etc/nginx/nginx.conf
fi

# starting 
cd /etc/init.d/
./nginx start

bash /root/bin/my-startup.sh