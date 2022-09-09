#!/usr/bin/env bash

KEEP_DAYS='20'

export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin'

export CMD_DATE='/bin/date'
export CMD_DU='du -sh'


export TIME="$(${CMD_DATE} +%H-%M-%S)"
export YEAR="$(${CMD_DATE} +%Y)"
export MONTH="$(${CMD_DATE} +%m)"
export DAY="$(${CMD_DATE} +%d)"
export TIMESTAMP="${YEAR}-${MONTH}-${DAY}-${TIME}"

export DB_BACKUP_PATH='/backup/mongo'
export MONGO_PORT="${MONGO_PORT}"
export MONGO_USER="${MONGO_USER}"
export MONGO_PASSWD="${MONGO_PASSWD}"
export DATABASE_NAMES="${DATABASE_NAME}"

# Pre-defined backup status
export BACKUP_SUCCESS='YES'

mkdir -p ${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME}

# Log file
export LOGFILE="${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME}/${TIMESTAMP}.log"

# Initialize log file.
echo "* Starting backup: ${TIMESTAMP}." >${LOGFILE}
echo "* Backup directory: ${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME}." >>${LOGFILE}

 
#if [ ${DATABASE_NAMES} = "ALL" ]; then
# echo "You have choose to backup all databases: ${DATABASE_NAMES}" >>${LOGFILE}
# mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} --username ${MONGO_USER} --password ${MONGO_PASSWD} --out ${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME}  &>/dev/null
#else 
if [ X"$?" == X'0' ]; then
 echo "Running backup for selected databases: ${DATABASE_NAMES}" >>${LOGFILE}
   for DB_NAME in ${DATABASE_NAMES}
    do
    mongodump --db ${DB_NAME} --username ${MONGO_USER} --password ${MONGO_PASSWD} --port ${MONGO_PORT} --out ${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME}  &>/dev/null
   done
else
    # backup failed
    export BACKUP_SUCCESS='NO'
fi

# Append file size of backup files.
echo -e "* File size:\n----" >>${LOGFILE}
cd ${DB_BACKUP_PATH}/${YEAR}/${MONTH}/${DAY}/${TIME} && \
${CMD_DU} ${DATABASE_NAMES} >>${LOGFILE}
echo "----" >>${LOGFILE}

echo "* Backup completed (Success? ${BACKUP_SUCCESS})." >>${LOGFILE}

if [ X"${BACKUP_SUCCESS}" == X'YES' ]; then
    echo "==> Backup completed successfully."
else
    echo -e "==> Backup completed with !!!ERRORS!!!.\n" 1>&2
fi

# Find the old backup which should be removed.
export REMOVE_OLD_BACKUP='YES'

export KERNEL="$(uname -s)"
if [[ X"${KERNEL}" == X'Linux' ]]; then
    shift_year=$(date --date="${KEEP_DAYS} days ago" "+%Y")
    shift_month=$(date --date="${KEEP_DAYS} days ago" "+%m")
    shift_day=$(date --date="${KEEP_DAYS} days ago" "+%d")
elif [[ X"${KERNEL}" == X'FreeBSD' ]]; then
    shift_year=$(date -j -v-${KEEP_DAYS}d "+%Y")
    shift_month=$(date -j -v-${KEEP_DAYS}d "+%m")
    shift_day=$(date -j -v-${KEEP_DAYS}d "+%d")
elif [[ X"${KERNEL}" == X'OpenBSD' ]]; then
    epoch_seconds_now="$(date +%s)"
    epoch_shift="$((${KEEP_DAYS} * 86400))"
    epoch_seconds_old="$((epoch_seconds_now - epoch_shift))"

    shift_year=$(date -r ${epoch_seconds_old} "+%Y")
    shift_month=$(date -r ${epoch_seconds_old} "+%m")
    shift_day=$(date -r ${epoch_seconds_old} "+%d")
else
    export REMOVE_OLD_BACKUP='NO' 
fi

export REMOVED_BACKUP_DIR="${DB_BACKUP_PATH}/${shift_year}/${shift_month}/${shift_day}"
export REMOVED_BACKUP_MONTH_DIR="${DB_BACKUP_PATH}/${shift_year}/${shift_month}"
export REMOVED_BACKUP_YEAR_DIR="${DB_BACKUP_PATH}/${shift_year}"


if [[ X"${REMOVE_OLD_BACKUP}" == X'YES' ]] && [[ -d "${REMOVED_BACKUP_DIR}" ]]; then
    echo -e "* Old backup found. Deleting: ${REMOVED_BACKUP_DIR}." >>${LOGFILE}
    rm -rf ${REMOVED_BACKUP_DIR} 

    # Try to remove empty directory.
    rmdir ${REMOVED_BACKUP_MONTH_DIR} 2>/dev/null
    rmdir ${REMOVED_BACKUP_YEAR_DIR} 2>/dev/null
else
    echo -e "Not Found Old backup to delete." >>${LOGFILE}
fi

echo "==> Detailed log (${LOGFILE}):"
echo "========================="
cat ${LOGFILE}
