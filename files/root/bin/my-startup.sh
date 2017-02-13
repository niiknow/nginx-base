#!/bin/bash
cd /root/bin/

if [ -n "$DOMAINS" ] ; then
	DOMAINZ=(${DOMAINS})
	MYDOMAIN=${DOMAINZ[0]}

    # only generate domain if not exists
	if [ ! -f /etc/letsencrypt/live/$MYDOMAIN/fullchain.pem ]; then
		# wait for nginx to start
		sleep 2
		# output is not success then exit
		if test $(./le-run.sh | tee ../letsencrypt.init.log | grep -c 'Congratulations') -eq 0; then
			echo "letsencrypt failed, please restart docker or rerun /root/le-run.sh"
			exit 0
		fi

		echo "reloading domain ssl"

		rm -f /app/etc/nginx/ssl/example-fullchain.pem
		ln -s /etc/letsencrypt/live/$MYDOMAIN/fullchain.pem /app/etc/nginx/ssl/example-fullchain.pem
		rm -f /app/etc/nginx/ssl/example-privkey.pem
		ln -s /etc/letsencrypt/live/$MYDOMAIN/privkey.pem /app/etc/nginx/ssl/example-privkey.pem
		service nginx reload
	fi
fi

# hitcounter instruction: link nginx conf, provide AWS ENV, then setup contab
# rm -f /etc/nginx/sites-enabled/mainsite
# ln -s /etc/nginx/sites-available/hitcounter /etc/nginx/sites-enabled/hitcounter
# (crontab -l ; echo "* * * * * /root/bin/hc-logship.sh s3-bucket-name/folder-name") | sort - | uniq - | crontab -
