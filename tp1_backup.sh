#!/bin/bash

NOW=$(date +"%m%d%Y_%H%M")

backupdir_files="/opt/backup/*"
backupdir="/opt/backup/"

filename="$(echo "${1}" | awk -F'/' '{print $NF}')"

number_file="$(ls $backupdir | wc -l)"

if [[ $number_file -gt 7 ]]
then
        stat --printf='%Y %n\0' $backupdir_files | sort -z | sed -zn '1s/[^ ]\{1,\} //p' | xargs -0 rm
        echo "Removing oldest file before backup"
        tar -zvcf "${backupdir}/${filename}_${NOW}.tar.gz" "$1"
        echo "backup terminée"
else
        tar -zvcf "${backupdir}/${filename}_${NOW}.tar.gz" "$1"
        echo "backup terminée"
fi