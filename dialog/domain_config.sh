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
