export DISABLE_SSL_CONFIUGRATION='NO'
export ssl_configuration=''

while : ; do
        ${DIALOG} \
        --title "Preferred SSL configuration" \
        --radiolist "Choose a option to configure the SSL.

TIP: Use SPACE key to select item." \
25 85 3 \
"SSLpurchased" "If ssl was purchased enter the ssl code here." "on" \
"Letsencrypt" "Just create the ssl file" "off"
"notpurchased" "going to do later on." "off" \
2>${RUNTIME_DIR}/.ssl_configuration

        ssl_configuration_case_sensitive="$(cat ${RUNTIME_DIR}/.ssl_configuration)"
        ssl_configuration="$(echo ${ssl_configuration_case_sensitive} | tr '[a-z]' '[A-Z]')"
        [ X"${ssl_configuration}" != X"" ] && break
    done

    rm -f ${RUNTIME_DIR}/.ssl_configuration

if [ X"${ssl_configuration}" == X'SSLpurchased' ]; then
   
    export ssl_configuration='SSLpurchased'

echo "export ssl_configuration='${ssl_configuration}'" >>${SERVER_CONFIG_FILE}

elif [ X"${ssl_configuration}" == X'Letsencrypt' ]; then
    
    export ssl_configuration='Letsencrypt'

echo "export ssl_configuration='${ssl_configuration}'" >>${SERVER_CONFIG_FILE}
else
    export DISABLE_SSL_CONFIUGRATION='YES'
    echo "export DISABLE_SSL_CONFIUGRATION='YES'" >>${SERVER_CONFIG_FILE}
fi

cat >> ${TIP_FILE} <<EOF

You entered details regarding the domain :

    * Domain name :          ${DOMAIN_NAME}
    * Subdomain name :       ${SUBDOMAIN_NAME}
    * ssl_status :           ${ssl_configuration}

EOF