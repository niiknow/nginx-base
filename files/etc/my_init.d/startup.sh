#!/bin/bash

export TERM=xterm

if [ -z "`ls /app --hide='lost+found'`" ]
then
    rsync -a /app-start/* /app
fi

# starting 
cd /etc/init.d/
./nginx start

bash /root/bin/my-startup.sh