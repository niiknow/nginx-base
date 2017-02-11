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

if [ -z "$WEBROOT_PATH" ] ; then
  log "No webroot path set, please fill -e 'WEBROOT_PATH=/app/var/www/html'"
  die
fi

DARRAYS=(${DOMAINS})
EMAIL_ADDRESS=${EMAIL}
LE_DOMAINS=("${DARRAYS[*]/#/-d }")

exp_limit="${EXP_LIMIT:-30}"
check_freq="${CHECK_FREQ:-30}"

le_fixpermissions() {
    log "[INFO] Fixing permissions"
        chown -R ${CHOWN:-root:root} /app/etc/letsencrypt
        find /app/etc/letsencrypt -type d -exec chmod 755 {} \;
        find /app/etc/letsencrypt -type f -exec chmod ${CHMOD:-644} {} \;
}

le_renew() {
    certbot certonly --webroot --agree-tos --renew-by-default --text --email ${EMAIL_ADDRESS} -w ${WEBROOT_PATH} ${LE_DOMAINS}
    le_fixpermissions
}

le_check() {
    cert_file="/app/etc/letsencrypt/live/$DARRAYS/fullchain.pem"
    
    if [ -f $cert_file ]; then
    
        exp=$(date -d "`openssl x509 -in $cert_file -text -noout|grep "Not After"|cut -c 25-`" +%s)
        datenow=$(date -d "now" +%s)
        days_exp=$[ ( $exp - $datenow ) / 86400 ]
        
        log "Checking expiration date for $DARRAYS..."
        
        if [ "$days_exp" -gt "$exp_limit" ] ; then
            log "The certificate is up to date, no need for renewal ($days_exp days left)."
        else
            log "The certificate for $DARRAYS is about to expire soon. Starting webroot renewal script..."
            le_renew
            log "Renewal process finished for domain $DARRAYS"
        fi

        log "Checking domains for $DARRAYS..."

        domains=($(openssl x509  -in $cert_file -text -noout | grep -oP '(?<=DNS:)[^,]*'))
        new_domains=($(
            for domain in ${DARRAYS[@]}; do
                [[ " ${domains[@]} " =~ " ${domain} " ]] || log $domain
            done
        ))

        if [ -z "$new_domains" ] ; then
            log "The certificate have no changes, no need for renewal"
        else
            log "The list of domains for $DARRAYS certificate has been changed. Starting webroot renewal script..."
            le_renew
            log "Renewal process finished for domain $DARRAYS"
        fi


    else
      log "[INFO] certificate file not found for domain $DARRAYS. Starting webroot initial certificate request script..."
      le_renew
      log "Certificate request process finished for domain $DARRAYS"
    fi

    if [ "$1" != "once" ]; then
        sleep ${check_freq}d
        le_check
    fi
}

le_check $1