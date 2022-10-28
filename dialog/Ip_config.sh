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

    PUBLIC_IP="$(cat ${RUNTIME_DIR}/.public_ip)"

    nm="([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"

    [[ "${PUBLIC_IP}" =~ ^$nm\.$nm\.$nm\.$nm$  ]] && break
done

export PUBLIC_IP="${PUBLIC_IP}"
echo "export public_ip='${PUBLIC_IP}'" >> ${SERVER_CONFIG_FILE}
rm -f ${RUNTIME_DIR}/.public_ip


cat >> ${TIP_FILE} <<EOF
             * IP_address: ${PUBLIC_IP}
EOF