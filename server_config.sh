#!/usr/bin/env bash

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

export CONFIG_DIR="${ROOTDIR}/conf"
export FUNCTIONS_DIR="${ROOTDIR}/functions"
export DIALOG_DIR="${ROOTDIR}/dialog"
export PKG_DIR="${ROOTDIR}/pkgs"
export SAMPLE_DIR="${ROOTDIR}/samples"
export TOOLS_DIR="${ROOTDIR}/tools"
export RUNTIME_DIR="${ROOTDIR}/runtime"

[[ -d ${RUNTIME_DIR} ]] || mkdir -p ${RUNTIME_DIR}

. ${CONFIG_DIR}/global
. ${CONFIG_DIR}/core

# Check downloaded packages, pkg repository.
[ -f ${STATUS_FILE} ] && . ${STATUS_FILE}

if [ X"${status_get_all}" != X"DONE" ]; then
    cd ${ROOTDIR}/pkgs/ && bash get_all.sh
    if [ X"$?" == X'0' ]; then
        cd ${ROOTDIR}
    else
        exit 255
    fi
fi

# --------------------------------------
# Check target platform and environment.
# --------------------------------------
# Make sure others can read-write /dev/null and /dev/*random, so that it won't
# interrupt server installation.
chmod go+rx /dev/null /dev/*random &>/dev/null

check_env

# Define paths of some directories
# Directory used to store daily backup files
export BACKUP_DIR="${ROOTDIR}/backup"

cache_clear_script="${BACKUP_DIR}/${BUFFER_CACHE_CLEAR}"

    ECHO_INFO "Setup daily cron job to clear server side cache ${cache_clear_script}"

    [ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} >> ${INSTALL_LOG} 2>&1
    cp ${TOOLS_DIR}/${BUFFER_CACHE_CLEAR} ${cache_clear_script}
    chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${cache_clear_script}
    chmod 0500 ${cache_clear_script}

  # Add cron job
    cat >> ${CRON_FILE_ROOT} <<EOF
# Backup MONGO databases at minute 0 past every 8th hour
0 */8 * * *  ${SHELL_BASH} ${cache_clear_script}
EOF

# Import global variables in specified order.
. ${CONFIG_DIR}/web_server
. ${CONFIG_DIR}/ssl
. ${CONFIG_DIR}/mongo
. ${CONFIG_DIR}/node


# Import functions in specified order.
. ${FUNCTIONS_DIR}/packages.sh
. ${FUNCTIONS_DIR}/system_accounts.sh
. ${FUNCTIONS_DIR}/web_server.sh
. ${FUNCTIONS_DIR}/ssl_configuration.sh

# Switch backend
. ${FUNCTIONS_DIR}/backend.sh
. ${FUNCTIONS_DIR}/db_server.sh
. ${FUNCTIONS_DIR}/cleanup.sh

# ************************************************************************
# *************************** Script Main ********************************
# ************************************************************************

# Install all required packages.
check_status_before_run install_all || (ECHO_ERROR "Package installation error, please check the output log.\n\n" && exit 255)

cat <<EOF
********************************************************************
* Start server Configurations
********************************************************************
EOF

check_status_before_run generate_ssl_keys
check_status_before_run add_required_users
check_status_before_run backend_install
check_status_before_run web_server_config
check_status_before_run db_server_config

#optional_components
check_status_before_run cleanup