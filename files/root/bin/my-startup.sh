#!/bin/bash
cd /root/bin/

# output is not success then exit
if test $(./le-run.sh | tee ../letsencrypt.init.log | grep -c 'Congratulations') -eq 0; then
	exit 1
fi

# linking the cert and restart nginx
# get the first folder name in live
DOMAINS=(${DOMAINS})
DOMAIN=${DOMAINS[0]}

rm -f /app/etc/nginx/ssl/example-fullchain.pem
ln -s /etc/letsencrypt/live/$DOMAIN/fullchain.pem /app/etc/nginx/ssl/example-fullchain.pem
rm -f /app/etc/nginx/ssl/example-privkey.pem
ln -s /etc/letsencrypt/live/$DOMAIN/privkey.pem /app/etc/nginx/ssl/example-privkey.pem
