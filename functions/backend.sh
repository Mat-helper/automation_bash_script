#!/usr/bin/env bash


# -------------------------------------------------------
# ------------- Install and config backend. -------------
# -------------------------------------------------------
backend_install()
{

    if [ X"${BACKEND}" == X'NODE' ]; then

        ECHO_INFO "Installing npm"

        sudo apt-get install npm -y

        ECHO_INFO "Installing pm2."
        
        npm install ${PROCESS_MANAGEMENT} -g

        ECHO_INFO "Changing folder permission"

        chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} /var/www

        echo 'export status_backend_setup="DONE"' >> ${STATUS_FILE}

    fi
    
}
