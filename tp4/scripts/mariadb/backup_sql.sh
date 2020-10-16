#!/bin/bash
DEST=/mnt/nfsfileshare/
CURRDATE=$(date +"%F")

HOSTNAME="localhost"
USER="root"
PASS=""

DATABASES=giteadb

[ ! -d $DEST ] && mkdir -p $DEST

for db in $DATABASES; do
  FILE="${DEST}/$db.sql.gz"
  FILEDATE=

  # Be sure to make one backup per day
  [ -f $FILE ] && FILEDATE=$(date -r $FILE +"%F")
  [ "$FILEDATE" == "$CURRDATE" ] && continue

  [ -f $FILE ] && mv "$FILE" "${FILE}.old"
  mysqldump --single-transaction --routines --quick -h $HOSTNAME -u $USER -p$PASS -B $db | gzip > "$FILE"
  chown vagrant:vagrant "$FILE"
  rm -f "${FILE}.old"
done

