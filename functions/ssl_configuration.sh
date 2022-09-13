

#!/usr/bin/env bash

ssl_cert_file ()
{
    if [ X"${SSL_CONFIGURATION}" == X'SSL purchased' ]; then

        [[ -d  ${SSL_DIR} ]] || mkdir -p ${SSL_DIR}

         [[ -f ${SSL_CERT_FILE} ]] || touch ${SSL_CERT_FILE} 

         [[ -f ${SSL_KEY_FILE} ]] || touch ${SSL_CERT_FILE} 

         [[ -f ${SSL_FULLCHAIN_FILE} ]] || touch ${SSL_CERT_FILE} 

        echo " Copy paste the SSL key file in repestive order ${SSL_CERT_FILE}, ${SSL_KEY_FILE}, ${SSL_FULLCHAIN_FILE}"
        sleep 3

        nano ${SSL_CERT_FILE}
        sleep 2

        nano ${SSL_KEY_FILE}
        sleep 2

        nano ${SSL_FULLCHAIN_FILE}
        sleep 2

        chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} ${SSL_DIR}

        perl -pi -e 's#PH_SSL_CERT_FILE#$ENV{SSL_CERT_FILE}#g' ${APACHE2_CONF_SITE_DEFAULT_SSL}
        perl -pi -e 's#PH_SSL_KEY_FILE#$ENV{SSL_KEY_FILE}#g' ${APACHE2_CONF_SITE_DEFAULT_SSL}
        perl -pi -e 's#PH_SSL_FULLCHAIN_FILE#$ENV{SSL_FULLCHAIN_FILE}#g' ${APACHE2_CONF_SITE_DEFAULT_SSL}
    
        ${SITE_ENABLE} ${APACHE2_CONF_SITE_DEFAULT_SSL} >> ${INSTALL_LOG} 2>&1

        #enable http2 htaccess rewrite 
        a2enmod ssl

        # starting apache2
        ECHO_DEBUG "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
        service_control restart ${APACHE2_RC_SCRIPT_NAME}

    cat >> ${TIP_FILE} <<EOF
SSL keys were Located:
    - ${SSL_CERT_FILE}
    - ${SSL_KEY_FILE}
    - ${SSL_FULLCHAIN_FILE}
EOF
        echo 'export status_ssl_cert_file="DONE"'  >> ${STATUS_FILE}

fi

if [ X"${SSL_CONFIGURATION}" == X'Lets encrypt' ]; then

    sudo certbot --apache -d ${SUBDOMAIN_NAME}.${DOMAIN_NAME}

    cp -r /etc/letsencrypt/live/${SUBDOMAIN_NAME}.${DOMAIN_NAME} ${SSL_DIR}

    chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} ${SSL_DIR}

cat >> ${TIP_FILE} <<EOF
SSL keys were Located:
    - /etc/letsencrypt/live/${SUBDOMAIN_NAME}.${DOMAIN_NAME}
EOF

    echo 'export status_ssl_cert_file="DONE"'  >> ${STATUS_FILE}

fi

}

