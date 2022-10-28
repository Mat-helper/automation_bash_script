#!/usr/bin/env bash

# name of the useraccount for developers
while : ; do
    ${DIALOG} \
    --title "system account for developer" \
    --inputbox "\
Please enter your system account for developer.
NOTES:
        * Make sure enter username in lower case.

" 20 76 2>${RUNTIME_DIR}/.system_username

    SYSTEM_ACCOUNT_NAME="$(cat ${RUNTIME_DIR}/.system_username)"

    [ X"${SYSTEM_ACCOUNT_NAME}" != X'' ] && break
done

export SYSTEM_ACCOUNT_NAME="${SYSTEM_ACCOUNT_NAME}"
echo "export SYSTEM_ACCOUNT_NAME='${SYSTEM_ACCOUNT_NAME}'" >> ${SERVER_CONFIG_FILE}

rm -f ${RUNTIME_DIR}/.system_username