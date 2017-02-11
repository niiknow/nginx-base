#!/bin/bash

bash /root/bin/le-certbot.sh

# Check if config or certificates were changed
while inotifywait -q -r --exclude '\.git/' -e modify -e create -e delete /app/etc/nginx /app/etc/letsencrypt; do
  echo "Configuration changes detected. Will send reload signal to nginx in 60 seconds..."
  sleep 60
  nginx -s reload && echo "Reload signal send"
done
