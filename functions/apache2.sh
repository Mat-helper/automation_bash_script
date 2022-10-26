#!/usr/bin/env bash

apache2_config()
{
    ECHO_INFO "Configure Apache2 web server."

    # Make sure we have an empty directory
    # Directory used to store virtual web hosts config files
    [ -d ${HTTP_CONF_DIR_AVAILABLE_SITES} ] && mv ${HTTP_CONF_DIR_AVAILABLE_SITES} ${HTTP_CONF_DIR_AVAILABLE_SITES}.bak
    [ ! -d ${HTTP_CONF_DIR_AVAILABLE_SITES} ] && mkdir -p ${HTTP_CONF_DIR_AVAILABLE_SITES}

    [ -d ${HTTP_CONF_DIR_ENABLED_SITES} ] && mv ${HTTP_CONF_DIR_ENABLED_SITES} ${HTTP_CONF_DIR_ENABLED_SITES}.bak
    [ ! -d ${HTTP_CONF_DIR_ENABLED_SITES} ] && mkdir -p ${HTTP_CONF_DIR_ENABLED_SITES}

    backup_file ${APACHE2_CONF} ${APACHE2_CONF_SITE_DEFAULT} ${APACHE2_CONF_SITE_DEFAULT_SSL}
    #
    # Modular config files
    #
    # Copy sample files
    cp ${APACHE2_SAMPLE_DIR}/apache2.conf ${APACHE2_CONF}

    #
    # Default sites
    #
    cp -f ${APACHE2_SAMPLE_DIR}/sites-available/000-default.conf ${APACHE2_CONF_SITE_DEFAULT}
    cp -f ${APACHE2_SAMPLE_DIR}/sites-available/default-ssl.conf ${APACHE2_CONF_SITE_DEFAULT_SSL}
    ${SITE_ENABLE} ${APACHE2_CONF_SITE_DEFAULT} >> ${INSTALL_LOG} 2>&1
   

    #configure X-frame-options
    sudo echo -e "Header set X-Frame-Options: \"sameorigin\"" >> ${HTTP_CONF_DIR_AVAILABLE_CONF}/security.conf     

    # Ports
    perl -pi -e 's#PH_PORT_HTTP#$ENV{PORT_HTTP}#g' ${APACHE2_CONF_SITE_DEFAULT}
    perl -pi -e 's#PH_HTTPS_PORT#$ENV{HTTPS_PORT}#g' ${APACHE2_CONF_SITE_DEFAULT_SSL}

    # web sites
    perl -pi -e 's#PH_HTTP_DOCUMENTROOT#$ENV{HTTP_DOCUMENTROOT}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/*.conf
    
    # Domain & subdomain name
    

    if [ X"${SUBDOMAIN_NAME}" == X'www']; then
     
    perl -pi -e 's#PH_DOMAIN_NAME#$ENV{DOMAIN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/*.conf
    perl -pi -e 's#PH_SUBDOMAIN_NAME#$ENV{SUBDOMAIN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/*.conf

    else 

    export FLQN_NAME="${SUBDOMAIN_NAME}.${DOMAIN_NAME}"

    perl -pi -e 's#PH_DOMAIN_NAME#$ENV{FLQN_NAME}#g' ${HTTP_CONF_DIR_AVAILABLE_SITES}/*.conf

    sudo sed -i -e '11 s/ServerAlias/#ServerAlias/g' /etc/apache2/sites-available/000-default.conf
    sudo sed -i -e '6 s/ServerAlias/#ServerAlias/g' /etc/apache2/sites-available/default-ssl.conf
    

    #enable http2 htaccess rewrite 
    a2enmod http2 headers rewrite 

    # starting apache2
    ECHO_DEBUG "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
    service_control restart ${APACHE2_RC_SCRIPT_NAME}

    cat >> ${TIP_FILE} <<EOF
Apache2:
    * Configuration files:
        - ${APACHE2_CONF}
        - ${APACHE2_CONF_SITE_DEFAULT}
        - ${APACHE2_CONF_SITE_DEFAULT_SSL}
    * Directories:
        - ${HTTP_CONF_ROOT}
        - ${HTTP_DOCUMENTROOT}
    * See also:
        - ${HTTP_DOCUMENTROOT}/index.html

EOF

    echo 'export status_apache2_config="DONE"' >> ${STATUS_FILE}
}
