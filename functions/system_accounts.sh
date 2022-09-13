#!/usr/bin/env bash


add_user_develop()
{
    add_sys_user_group \
        ${SYSTEM_ACCOUNT_NAME} 

    echo "The system user - ${SYSTEM_ACCOUNT_NAME} changing folder ownership to '/var/www/html'. "

    chown -R  ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} /var/www

    echo "${SYSTEM_ACCOUNT_NAME} ALL=(ALL) NOPASSWD:${PRIVILEGES}" >> /etc/sudoers

    visudo -c

    echo 'export status_add_user_develop="DONE"' >> ${STATUS_FILE}
}


add_pem_file()
{
    ECHO_INFO "Generate the pem file to login user."
    
    ssh-keygen -b 2048 -t rsa -f ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME} -q -N "" 

    ssh_publickey_case_sensitive="$(cat ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME}.pub)"

    ssh-pubkey="$( echo ${ssh_publickey_case_sensitive} )"

    [[ -d ${SYSTEM_ACCOUNT_NAME}/.ssh ]] || mkdir -p ${SYSTEM_ACCOUNT_NAME}/.ssh
    
    chown ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} ${SYSTEM_ACCOUNT_NAME}/.ssh

    chmod 700 ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} ${SYSTEM_ACCOUNT_NAME}/.ssh

    [[ -f ${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys ]] || touch ${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    chown ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} ${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    chmod 600 ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} ${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    ${ssh-pubkey} >> ${SYSTEM_ACCOUNT_NAME}/.ssh/authorized_keys

    ssh_privatekey_case_sensitive="$(cat ${RUNTIME_DIR}/.ssh/${SYSTEM_ACCOUNT_NAME})"

    ssh-privkey="$( echo ${ssh_privatekey_case_sensitive} )"
    
    ${ssh-privkey} >> ${ROOTDIR}/${SYSTEM_ACCOUNT_NAME}.pem

    echo 'export status_add_pem_file_user_develop="DONE"' >> ${STATUS_FILE}

cat >> ${TIP_FILE} <<EOF
 Your ssh pem  file for login ${SYSTEM_ACCOUNT_NAME}

        - ${ROOTDIR}/${SYSTEM_ACCOUNT_NAME}.pem
EOF

}

add_required_users()
{
    ECHO_INFO "Create required system accounts."

    check_status_before_run add_user_develop
    check_status_before_run add_pem_file

}   