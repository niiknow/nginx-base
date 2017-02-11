#!/bin/bash

function die {
    echo >&2 "$@"
    exit 1
}

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

if [ -z "$DOMAINS" ] ; then
  log "No domains set, please fill -e 'DOMAINS=example.com www.example.com'"
  die
fi

if [ -z "$EMAIL" ] ; then
  log "No email set, please fill -e 'EMAIL=your@email.tld'"
  die
fi


EMAIL=${EMAIL}
DOMAINS=(${DOMAINS})

domain_args=""
for i in "${DOMAINS[@]}"
do
   domain_args="$domain_args -d $i"
   # do whatever on $i
done

/usr/local/bin/letsencrypt certonly \
    --webroot -w /var/www/html \
    --text --renew-by-default --agree-tos \
      $domain_args \
	--email=$EMAIL
