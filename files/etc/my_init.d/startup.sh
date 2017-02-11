#!/bin/bash

export TERM=xterm

if [ -z "`ls /hitcounter --hide='lost+found'`" ]
then
    rsync -a /hitcounter-start/* /hitcounter
fi

# starting 
cd /etc/init.d/
./nginx start

bash /root/bin/my-startup.sh