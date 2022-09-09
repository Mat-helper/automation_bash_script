#!/usr/bin/env bash


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