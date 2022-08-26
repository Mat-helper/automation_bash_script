#!/usr/bin/env bash

#############################################################################
#Environment variable

export DOMAIN_NAME='example.com'
export DOMAIN_ALIAS_NAME='www.example.com'
export CERT_FILE=${DOMAIN_NAME//./_}

#############################################################################
# ------------------------------
# Define some global variables.
# ------------------------------

tmprootdir="$(dirname $0)"
echo ${tmprootdir} | grep '^/' >/dev/null 2>&1
if [ X"$?" == X"0" ]; then
    export ROOTDIR="${tmprootdir}"
else
    export ROOTDIR="$(pwd)"
fi

cd ${ROOTDIR}

export PKG_DIR="${ROOTDIR}/pkg"
export CONFIG_DIR="${ROOTDIR}/conf"
export TOOLS_DIR="${ROOTDIR}/tools"
export RUNTIME_DIR="${ROOTDIR}/runtime"

[[ -d ${RUNTIME_DIR} ]] || mkdir -p ${RUNTIME_DIR}
[[ -f ${STATUS_FILE} ]] || touch ${STATUS_FILE}


. ${CONFIG_DIR}/global
. ${CONFIG_DIR}/core
. ${PKG_DIR}/installation


chmod go+rx /dev/null /dev/*random &>/dev/null

# Debug mode: YES, NO.
export SERVER_DEBUG="${SERVER_DEBUG:=NO}"

# Root Backup directory
export BACKUP_DIR='/root/script'

. ${CONFIG_DIR}/apache2
. ${CONFIG_DIR}/mongo

mongo_backup_script="${BACKUP_DIR}/${BACKUP_SCRIPT_MONGO_NAME}"

    ECHO_INFO "Setup daily cron job to backup MONGO databases with ${mongo_backup_script}"

    [ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} >> ${INSTALL_LOG} 2>&1
     backup_file ${mongo_backup_script}
    cp ${TOOLS_DIR}/${BACKUP_SCRIPT_MONGO_NAME} ${mongo_backup_script}
    chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${mongo_backup_script}
    chmod 0500 ${mongo_backup_script}

  # Add cron job
    cat >> ${CRON_FILE_ROOT} <<EOF
# Backup MONGO databases at minute 0 past every 2nd hour
0   */2   *   *   *  ${SHELL_BASH} ${mongo_backup_script}
EOF

cache_clear_script="${BACKUP_DIR}/${BUFFER_CACHE_CLEAR}"

    ECHO_INFO "Setup daily cron job to Cache clear script ${cache_clear_script}"

    [ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} >> ${INSTALL_LOG} 2>&1
    cp ${TOOLS_DIR}/${BUFFER_CACHE_CLEAR} ${cache_clear_script}
    chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${cache_clear_script}
    chmod 0500 ${cache_clear_script}

  # Add cron job
    cat >> ${CRON_FILE_ROOT} <<EOF
# Backup MONGO databases at minute 0 past every 8th hour
0 */8 * * *  ${SHELL_BASH} ${cache_clear_script}
EOF

mongo_user="${RUNTIME_DIR}/${MONGO_USER_DETAILS}"

    ECHO_INFO "Mongo user details information are stored in ${mongo_user}"
    cp ${TOOLS_DIR}/${MONGO_USER_DETAILS} ${mongo_user}


  