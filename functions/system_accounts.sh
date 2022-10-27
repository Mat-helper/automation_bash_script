#!/usr/bin/env bash


add_user_develop()
{
    add_sys_user_group \
        ${SYSTEM_ACCOUNT_NAME} 

    echo "The system user - ${SYSTEM_ACCOUNT_NAME} changing folder ownership to '/var/www/html'. "

    chown -R  ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} /var/www

    echo "${SYSTEM_ACCOUNT_NAME} ALL = NOPASSWD: ${PRIVILEGES}" >> /etc/sudoers

    visudo -c

    ln -s ${BACKUP_DIR}/${cache_clear_script} /home/${SYSTEM_ACCOUNT_NAME}
    
    echo "Link the buffer cache clear script to the ${SYSTEM_ACCOUNT_NAME} home location"

echo 'export status_add_user_develop="DONE"' >> ${STATUS_FILE}
}

add_pem_file()
{
    ECHO_INFO "Generate the pem file to login user."

    [[ -d ${RUNTIME_DIR}/.ssh ]] || mkdir -p ${RUNTIME_DIR}/.ssh
    
    ssh-keygen -b 2048 -t rsa -f ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME} -q -N "" 

    [[ -d /home/${SYSTEM_ACCOUNT_NAME}/.ssh ]] || mkdir -p /home/${SYSTEM_ACCOUNT_NAME}/.ssh
    
    chown ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} /home/${SYSTEM_ACCOUNT_NAME}/.ssh

    chmod 700  /home/${SYSTEM_ACCOUNT_NAME}/.ssh

    [[ -f /home/${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys ]] || touch /home/${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    chown ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} /home/${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    chmod 600  /home/${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    cp ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME}.pub /home/${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    [[ -d ${RUNTIME_DIR}/key ]] || mkdir -p ${RUNTIME_DIR}/key
    
    cp ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME} ${RUNTIME_DIR}/key/${SYSTEM_ACCOUNT_NAME}.pem

    echo 'export status_add_pem_file_user_develop="DONE"' >> ${STATUS_FILE}

cat >> ${TIP_FILE} <<EOF
 Your ssh pem  file for login ${SYSTEM_ACCOUNT_NAME}

        - ${RUNTIME_DIR}/key/${SYSTEM_ACCOUNT_NAME}.pem
EOF

}

add_required_users()
{
    ECHO_INFO "Create required system accounts."

    check_status_before_run add_user_develop
    check_status_before_run add_pem_file

# separatly save the user_details for sharing to the developer.
cat >> ${Developer_TIP_FILE} <<EOF
system_account reference : 

Developer user details : 
          * Username: ${SYSTEM_ACCOUNT_NAME}
          * Password: Nopassword

Your ssh pem  file for login ${SYSTEM_ACCOUNT_NAME}.pem

Buffer cache clear file location : /home/${SYSTEM_ACCOUNT_NAME}
run command to clear the cache "sudo bash ${BUFFER_CACHE_CLEAR}"
EOF

}   