#!/bin/bash
PATH="/root/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
export PATH
backup_dest=$(sed 's/\/*$//' <<< "$1")
backup_dest=$(sed 's/^\/*//' <<< "$backup_dest")
mkdir -p /var/log/sync/

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

#######################################
# collect nginx logs
#######################################
collectLogs() {
  # Collecting the matching files in a Bash *array*:
  filetxt=$(ls -tp /var/log/nginx/*.hc-access.log | grep -v '/$' | tail -n +2)
  files=(${filetxt//$'\n'/ })
  for i in "${files[@]}"
  do
    DEST_FILE=$(sed -i -e 's/\/nginx\//\/sync\//g' <<< "$i")

    # if [ ! -f $DEST_FILE ]; then
      # split by ? and space
      awk 'BEGIN{FS="[? ]"}{print $7}' $i | grep /pi/ | sort | uniq -c | tee $DEST_FILE > /dev/null

      # delete processed file so we don't process it again
      rm -f $i
    # fi
  done
}

#######################################
# ship nginx logs
#######################################
shipLogs() {
  # delete empty files
  find /var/log/sync/ -size 0 -exec rm -f {} \;

  # aws sync dest file to s3
  aws s3 sync "/var/log/sync/" "s3://$backup_dest/" --exclude="*" --include "*.hc-access.log"

  # aws cli does not sync file that exists remotely
  # but it's probably good to delete it locally for house keeping sake
  rm -rf /var/log/sync/*
}

# trigger log rotation or creation of new log
curl http://127.0.0.1/null/rotate
# a little sleep to wait for new log
sleep 2

collectLogs
shipLogs
