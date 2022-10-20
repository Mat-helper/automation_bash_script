#!/usr/bin/env bash

# get domain name  details
while : ; do
    ${DIALOG} \
    --title "Your domain name" \
    --inputbox "\
Please enter your domain name.
NOTES:
        * Don't write domain with 'www'.
            example :  www.domain.com
        * Write without 'www' / subdomain
            example : domain.com.

We need domain name to configure the web server.
" 20 76 2>${RUNTIME_DIR}/.domain_name

    DOMAIN_NAME="$(cat ${RUNTIME_DIR}/.domain_name | tr '[A-Z]' '[a-z]')"

    echo "${DOMAIN_NAME}" | grep '\.' &>/dev/null
    [ X"$?" == X"0" -a X"${DOMAIN_NAME}" != X"www" ] && break
done

export DOMAIN_NAME="${DOMAIN_NAME}"
echo "export DOMAIN_NAME='${DOMAIN_NAME}'" >> ${SERVER_CONFIG_FILE}

rm -f ${RUNTIME_DIR}/.domain_name

#subdomain name
while : ; do
    ${DIALOG} \
    --title "Your subdomain name" \
    --inputbox "\
Please specify your subdomain name.
NOTES:
        * Don't enter your fully domain name here.
            example: api.domain.com
        * 
If server has subdomain like 'www' or other than 'www'.
" 20 76 2>${RUNTIME_DIR}/.subdomain_name

    SUBDOMAIN_NAME="$(cat ${RUNTIME_DIR}/.subdomain_name | tr '[A-Z]' '[a-z]')"

    echo "${SUBDOMAIN_NAME}" | grep '\.' &>/dev/null
    [ X"$?" != X"0" ] && break
done

export SUBDOMAIN_NAME="${SUBDOMAIN_NAME}"
echo "export SUBDOMAIN_NAME='${SUBDOMAIN_NAME}'" >> ${SERVER_CONFIG_FILE}

rm -f ${RUNTIME_DIR}/.subdomain_name


#SSL configuration
export DISABLE_SSL_CONFIUGRATION='NO'
export SSL_CONFIGURATION=''

while : ; do
    ${DIALOG} \
    --title "SSL configuration" \
    --radiolist " Please specify option to configure the SSL.

NOTES:
        * If SSL was not purchased disable the option and do it later on manually.
        * If server is going to use free ssl for temporary from lets encrypt.
        * If SSL was purchased please copy and paste the file .

WARNING:
        * Make sure to use the free SSL for temporary don't go live with free ssl." \
25 90 3 \
"SSLpurchased" "If ssl was purchased enter the ssl code here." "on" \
"Letsencrypt" "Lets Encrypt is a certificate authority." "off" \
"ssl not purchased" "I don't need any web applications on this server." "off" \
2>${RUNTIME_DIR}/.ssl_configuration

        ssl_configuration_case_sensitive="$(cat ${RUNTIME_DIR}/.ssl_configuration)"
        ssl_configuration="$(echo ${ssl_configuration_case_sensitive} | tr '[a-z]' '[A-Z]')"
        [ X"${ssl_configuration}" != X"" ] && break
done

   

if [ X"${ssl_configuration}" == X'SSLpurchased' ]; then
    export SSL_CONFIGURATION='SSL-purchased'

    echo "export SSL_CONFIGURATION='${SSL_CONFIGURATION}'" >>${SERVER_CONFIG_FILE}

elif [ X"${ssl_configuration}" == X'Letsencrypt' ]; then
    export SSL_CONFIGURATION='Lets-encrypt'

    echo "export SSL_CONFIGURATION='${SSL_CONFIGURATION}'" >>${SERVER_CONFIG_FILE}

else
    export DISABLE_SSL_CONFIUGRATION='YES'
    echo "export DISABLE_SSL_CONFIUGRATION='YES'" >>${SERVER_CONFIG_FILE}
fi

 rm -f ${RUNTIME_DIR}/.ssl_configuration

 
cat >> ${TIP_FILE} <<EOF

You entered details regarding the domain :

    * Domain name :          ${DOMAIN_NAME}
    * Subdomain name :       ${SUBDOMAIN_NAME}
    * ssl_status :           ${SSL_CONFIGURATION}

EOF
