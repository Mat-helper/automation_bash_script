#!/usr/bin/env bash

#############################################################################
#Environment variable

export DOMAIN_NAME='example.com'
export DOMAIN_ALIAS_NAME='www.example.com'
export CERT_FILE=${DOMAIN_NAME//./_}

#############################################################################
################################
#runtime directory creation and name for the log files
################################
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

export STATUS_FILE="${RUNTIME_DIR}/install.status"
export INSTALL_LOG="${RUNTIME_DIR}/install.log"
export PKG_INSTALL_LOG="${RUNTIME_DIR}/pkg.install.log"

. ${PKG_DIR}/installation
. ${CONFIG_DIR}/apache2



# Output flag.
export _INFO_FLAG="[ INFO ]"

# Debug mode: YES, NO.
export SERVER_DEBUG="${SERVER_DEBUG:=NO}"

# root user/group name. Note: not all OSes have group 'root'.
export SYS_USER_ROOT='root'
export SYS_GROUP_ROOT='root'


ECHO_INFO()
{
    if [ X"$1" == X"-n" ]; then
        shift 1
        echo -ne "${_INFO_FLAG} $@"
    else
        echo -e "${_INFO_FLAG} $@"
    fi
    echo -e "${_INFO_FLAG} $@" >> ${INSTALL_LOG}
}

backup_file()
{
    # Usage: backup_file file1 [file2 file3 ... fileN]
    if [ X"$#" != X"0" ]; then
        for f in $@; do
            if [ -f ${f} ]; then
                if [ X"${SERVER_DEBUG}" == X'YES' ]; then
                    echo -e "${_BACKUP_FLAG} ${f} -> ${f}.${DATE}."
                fi
                cp -f ${f} ${f}.${DATE}
            fi
        done
    fi
}

# Backup script file names.
export BACKUP_SCRIPT_MONGO_NAME='backup_mongo.sh'

export BACKUP_DIR='/root'

mongo_backup_script="${BACKUP_DIR}/${BACKUP_SCRIPT_MONGO_NAME}"

    ECHO_INFO "Setup daily cron job to backup MONGO databases with ${mongo_backup_script}"

    [ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} >> ${INSTALL_LOG} 2>&1
     backup_file ${mongo_backup_script}
    cp ${TOOLS_DIR}/${BACKUP_SCRIPT_MONGO_NAME} ${mongo_backup_script}
    chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${mongo_backup_script}
    chmod 0500 ${mongo_backup_script}

###########################################################################################