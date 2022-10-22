export DISABLE_SSL_CONFIUGRATION='NO'
export SSL_CONFIGURATION=''

while : ; do
        ${DIALOG} \
        --title "Preferred SSL configuration" \
        --radiolist "Choose a option to configure the SSL.

TIP: Use SPACE key to select item." \
25 85 3 \
"SSLpurchased" "If ssl was purchased enter the ssl code here." "on" \
"ssl not purchased" "just create only a file." "off" \
2>${RUNTIME_DIR}/.ssl_configuration

        ssl_configuration_case_sensitive="$(cat ${RUNTIME_DIR}/.ssl_configuration)"
        ssl_configuration="$(echo ${ssl_configuration_case_sensitive} | tr '[a-z]' '[A-Z]')"
        [ X"${ssl_configuration}" != X"" ] && break
    done

    rm -f ${RUNTIME_DIR}/.ssl_configuration

if [ X"${ssl_configuration}" == X'SSLpurchased' ]; then
    export SSL_CONFIGURATION='SSLpurchased'

echo "export SSL_CONFIGURATION='${SSL_CONFIGURATION}'" >>${SERVER_CONFIG_FILE}


else
    export DISABLE_SSL_CONFIUGRATION='YES'
    echo "export DISABLE_SSL_CONFIUGRATION='YES'" >>${SERVER_CONFIG_FILE}
fi

cat >> ${TIP_FILE} <<EOF

You entered details regarding the domain :

    * Domain name :          ${DOMAIN_NAME}
    * Subdomain name :       ${SUBDOMAIN_NAME}
    * ssl_status :           ${SSL_CONFIGURATION}

EOF