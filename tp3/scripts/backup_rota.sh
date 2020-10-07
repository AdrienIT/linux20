#!/bin/bash
# it4
# 23/09/2020
# Simple backup script

## VARIABLES

# Colors :D
declare -r NC="\e[0m"
declare -r B="\e[1m"
declare -r RED="\e[31m"
declare -r GRE="\e[32m"

# Target directory : the one we want to backup
declare -r target_path="${1}"
declare -r target_dirname=$(awk -F'/' '{ print $NF }' <<< "${target_path%/}")

# Craft the backup full path and name
declare -r backup_destination_dir="/opt/backup/"
declare -r backup_date="$(date +%y%m%d_%H%M%S)"
declare -r backup_filename="${target_dirname}_${backup_date}.tar.gz"
declare -r backup_destination_path="${backup_destination_dir}/${backup_filename}"

# Informations about the User that must run this script
declare -r backup_user_name="backup"
declare -ri backup_user_uid=1003
declare -ri backup_user_umask=077

# The quantity of backup to keep for each directory
declare -i backups_quantity=7
declare -ri backups_quantity=$((backups_quantity+1))

## FUNCTIONS

# Get timestamp in order to log
get_current_timestamp() {
  timestamp=$(date "+[%h %d %H:%M:%S]")
}

# Echo arguments with a timestamp
log() {
  log_level="${1}"
  log_message="${2}"

  get_current_timestamp

  if [[ "${log_level}" == "ERROR" ]]; then
    echo -e "${timestamp} ${B}${RED}[ERROR]${NC} ${log_message}" >&2

  elif [[ "${log_level}" == "INFO" ]]; then
    echo -e "${timestamp} ${B}[INFO]${NC} ${log_message}"

  fi
}


# Delete oldest backups, eg only keep the $backups_quantity most recent backups, for a given directory
delete_oldest_backups() {

  # Get list of oldest backups
  # BE CAREFUL : this only works if there's no IFS character in file names (space, tabs, newlines, etc.)
  oldest_backups=$(ls -tp "${backup_destination_dir}" | grep -v '/$' | grep -E "^${target_dirname}.*$" | tail -n +${backups_quantity})

  if [[ ! -z $oldest_backups ]]
  then

    log "INFO" "This script only keep the ${backups_quantity} most recent backups for a given directory."

    for backup_to_del in ${oldest_backups}
    do
      # This line might be buggy if file names contain IFS characters 
      rm -f "${backup_destination_dir}/${backup_to_del}" &> /dev/null

      if [[ $? -eq 0 ]]
      then
        log "INFO" "${B}${GRE}Success.${NC} Backup ${backup_to_del} has been removed from ${backup_destination_dir}."
      else
        log "[ERROR]" "Deletion of backup ${backup_to_del} from ${backup_destination_dir} has failed."
        exit 1
      fi

    done
  fi
}


### CODE

# Set the backup user UMASK
umask ${backup_user_umask}


# Rotate backups (only keep the most recent ones)
delete_oldest_backups
