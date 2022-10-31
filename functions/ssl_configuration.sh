#!/usr/bin/env bash

generate_ssl_keys ()
{
    
    if [ X"${ssl_configuration}" == X'SSLPURCHASED' ]; then

    ECHO_INFO "Configure Apache2 web for https server."

    #backup the default-ssl conf file
    backup_file ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}

    # Copy default-ssl sites
    cp -f ${APACHE2_SAMPLE_DIR}/sites-available/default-ssl.conf ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}

    # Ports
    perl -pi -e 's#PH_HTTPS_PORT#$ENV{HTTPS_PORT}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    
    # web sites
    perl -pi -e 's#PH_HTTP_DOCUMENTROOT#$ENV{HTTP_DOCUMENTROOT}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    
    # Domain & subdomain name
    
    if [ X"${SUBDOMAIN_NAME}" == X'www' ]; then

    export FLQN_NAME="${SUBDOMAIN_NAME}.${DOMAIN_NAME}"
     
    perl -pi -e 's#PH_DOMAIN_NAME#$ENV{DOMAIN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    perl -pi -e 's#PH_SUBDOMAIN_NAME#$ENV{SUBDOMAIN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    perl -pi -e 's#PH_FLQN_NAME#$ENV{FLQN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    
    else 

    export FLQN_NAME="${SUBDOMAIN_NAME}.${DOMAIN_NAME}"

    perl -pi -e 's#PH_DOMAIN_NAME#$ENV{FLQN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    perl -pi -e 's#PH_FLQN_NAME#$ENV{FLQN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}

    sudo sed -i -e '6 s/ServerAlias/#ServerAlias/g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
    
    fi

        [[ -d  ${SSL_DIR} ]] || mkdir -p ${SSL_DIR}

         [[ -f ${SSL_CERT_FILE} ]] || touch ${SSL_CERT_FILE} 

         [[ -f ${SSL_KEY_FILE} ]] || touch ${SSL_CERT_FILE} 

         [[ -f ${SSL_FULLCHAIN_FILE} ]] || touch ${SSL_CERT_FILE} 

        ECHO_INFO " Copy paste the SSL key file in repestive order ${SSL_CERT_FILE}"
        sleep 3
        nano ${SSL_CERT_FILE}
        sleep 2
        ECHO_INFO " Copy paste the SSL key file in repestive order ${SSL_KEY_FILE}"
        nano ${SSL_KEY_FILE}
        sleep 2
        ECHO_INFO " Copy paste the SSL key file in repestive order ${SSL_FULLCHAIN_FILE}"
        nano ${SSL_FULLCHAIN_FILE}
        sleep 2

        chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} ${SSL_DIR}

        perl -pi -e 's#PH_SSL_CERT_FILE#$ENV{SSL_CERT_FILE}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
        perl -pi -e 's#PH_SSL_KEY_FILE#$ENV{SSL_KEY_FILE}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
        perl -pi -e 's#PH_SSL_FULLCHAIN_FILE#$ENV{SSL_FULLCHAIN_FILE}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}
       
        cd ${HTTP_CONF_DIR_AVAILABLE_SITES}
        ${SITE_ENABLE} ${APACHE2_CONF_SITE_DEFAULT_SSL} >> ${INSTALL_LOG} 2>&1
        cd ${ROOTDIR}
        #enable http2 ssl 
        a2enmod http2 ssl

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


elif [ X"${ssl_configuration}" == X'LETSENCRYPT' ]; then

    export FLQN_NAME="${SUBDOMAIN_NAME}.${DOMAIN_NAME}"

    sudo certbot --apache -d ${FLQN_NAME}

    cp -r /etc/letsencrypt/live/${FLQN_NAME} ${SSL_DIR}

    chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} ${SSL_DIR}

cat >> ${TIP_FILE} <<EOF
SSL keys were Located:
    - /etc/letsencrypt/live/${FLQN_NAME}
EOF

 cd ${HTTP_CONF_DIR_AVAILABLE_SITES}
 ${SITE_ENABLE} ${APACHE2_CONF_SITE_DEFAULT_SSL} >> ${INSTALL_LOG} 2>&1
 cd ${ROOTDIR}
#enable http2 htaccess rewrite 
a2enmod ssl 

# starting apache2
ECHO_DEBUG "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
service_control restart ${APACHE2_RC_SCRIPT_NAME}

    echo 'export status_ssl_cert_file="DONE"'  >> ${STATUS_FILE}

fi

}

