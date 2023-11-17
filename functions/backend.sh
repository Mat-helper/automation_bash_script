#!/usr/bin/env bash


# -------------------------------------------------------
# ------------- Install and config backend. -------------
# -------------------------------------------------------
backend_install()
{

    if [ X"${BACKEND}" == X'NODE' ]; then

        ECHO_INFO "Installing node using nvm"
        sleep 1
        touch /home/${SYSTEM_ACCOUNT_NAME}/nvm_script.sh
    cat >> /home/${SYSTEM_ACCOUNT_NAME}/nvm_script.sh <<EOF
        
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        sleep 1
        source ~/.nvm/nvm.sh
        source ~/.profile
        source ~/.bashrc    
        nvm install v14
        echo "Installing pm2."
        npm install pm2 -g
EOF
        chown ${SYSTEM_ACCOUNT_NAME}:${SYSTEM_ACCOUNT_NAME} /home/${SYSTEM_ACCOUNT_NAME}/nvm_script.sh
        
        runuser -l ${SYSTEM_ACCOUNT_NAME} /home/${SYSTEM_ACCOUNT_NAME}/nvm_script.sh

        rm -rf /home/${SYSTEM_ACCOUNT_NAME}/nvm_script.sh
sleep 2
        ECHO_INFO "Changing folder permission"

        chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} /var/www

        if [ X"${ssl_configuration}" == X'SSLPURCHASED' ]; then

        ECHO_INFO "add the proxy at apache2 server"

        sed -i -e '21,32 {s/#//g}' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}

        #enable http2 htaccess rewrite 
         a2enmod proxy proxy_balancer proxy_http proxy_http2 proxy_wstunnel

        # starting apache2
         ECHO_INFO "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
         service_control restart ${APACHE2_RC_SCRIPT_NAME}

        elif [ X"${ssl_configuration}" == X'LETSENCRYPT' ]; then

         ECHO_INFO "add the proxy at apache2 server"

        sudo sed -i '25 i <Proxy *>\nOrder deny,allow\nAllow from all\n</Proxy>\nSSLProxyEngine On\nProxyRequests Off\nProxyPreserveHost On\nProxyPass / http://127.0.0.1:2053/\nProxyPassReverse / http://127.0.0.1:2053/\n' ${HTTP_CONF_DIR_AVAILABLE_SITES}/000-default-le-ssl.conf

        #enable http2 htaccess rewrite 
         a2enmod proxy proxy_balancer proxy_http proxy_http2 proxy_wstunnel

        # starting apache2
         ECHO_INFO "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
         service_control restart ${APACHE2_RC_SCRIPT_NAME}

        fi

cat >> ${TIP_FILE} <<EOF

Backend port & location info : 
               - Backend-port: 2053
               - Location: /var/www/
                     - Notes: 
                		create a folder name "backend" [ # mkdir backend ] 
EOF

cat >> ${Developer_TIP_FILE} <<EOF
            * Backend port & location info : 
               - Backend-port: 2053
               - Location: /var/www/
                     - Notes: 
                		create a folder name "backend" [ # mkdir backend ] 
EOF


        echo 'export status_backend_setup="DONE"' >> ${STATUS_FILE}

    fi
    
}