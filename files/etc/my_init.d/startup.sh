#!/bin/bash

export TERM=xterm

if [ -z "`ls /app --hide='lost+found'`" ]
then
    rsync -a /app-start/* /app
fi

# if file exists
if [ -f /app/etc/nginx/nginx.new ]; then
	mv /app/etc/nginx/nginx.conf /app/etc/nginx/nginx.old
	mv /app/etc/nginx/nginx.new /app/etc/nginx/nginx.conf
fi

# starting 
cd /etc/init.d/
./nginx start

bash /root/bin/my-startup.sh