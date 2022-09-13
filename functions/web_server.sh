#!/usr/bin/env bash

web_server_config()
{
    # Create required directories
    [ -d ${HTTP_DOCUMENTROOT} ] || mkdir -p ${HTTP_DOCUMENTROOT} >> ${INSTALL_LOG} 2>&1

    if [ X"${WEB_SERVER}" == X'APACHE2' ]; then
        . ${FUNCTIONS_DIR}/apache2.sh
        check_status_before_run apache2_config
    fi

    echo 'export status_web_server_config="DONE"' >> ${STATUS_FILE}
}
