#!/usr/bin/env bash


# First domain name.
while : ; do
    ${DIALOG} \
    --title "Your server public IP address" \
    --inputbox "\
Please enter your public IP address.

NOTES:
    * Make sure the IP address point to the dns 

" 20 76 2>${RUNTIME_DIR}/.public_ip

    PUBLIC_IP="$(cat ${RUNTIME_DIR}/.public_ip | tr '[0-9]' )"

    echo "${PUBLIC_IP}" | grep '\.' &>/dev/null
    [ X"$?" == X"0" ] && break
done

export PUBLIC_IP="${PUBLIC_IP}"
echo "export public_ip='${PUBLIC_IP}'" >> ${SERVER_CONFIG_FILE}
rm -f ${RUNTIME_DIR}/.public_ip


cat >> ${TIP_FILE} <<EOF

Public IP address of your domain :

    * IP_address: ${PUBLIC_IP}

EOF