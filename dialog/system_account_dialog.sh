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

    SYSTEM_ACCOUNT_NAME="$(cat ${RUNTIME_DIR}/.system_username | tr '[a-z]')"

    echo "${SYSTEM_ACCOUNT_NAME}" | grep '\.' &>/dev/null
    [ X"$?" == X"0" ] && break
done

export SYSTEM_ACCOUNT_NAME="${SYSTEM_ACCOUNT_NAME}"
echo "export SYSTEM_ACCOUNT_NAME='${SYSTEM_ACCOUNT_NAME}'" >> ${SERVER_CONFIG_FILE}

rm -f ${RUNTIME_DIR}/.system_username


# set a new system user account password.
    while : ; do
        ${DIALOG} \
        --title "Password for System account  : ${SYSTEM_ACCOUNT_NAME}" \
        --passwordbox "\
Please specify password for ${SYSTEM_ACCOUNT_NAME} .

WARNING:

* Do *NOT* use double quote (\") in password.
* EMPTY password is *NOT* permitted.
* Sample password: $(${RANDOM_STRING})
" 20 76 2>${RUNTIME_DIR}/.system_userpw

        SYSTEM_USER_PASSWD="$(cat ${RUNTIME_DIR}/.system_userpw)"

        [ X"${SYSTEM_USER_PASSWD}" != X'' ] && break
    done

    export SYSTEM_USER_PASSWD="${SYSTEM_USER_PASSWD}"
fi

echo "export SYSTEM_USER_PASSWD='${SYSTEM_USER_PASSWD}'" >>${SERVER_CONFIG_FILE}

rm -f ${RUNTIME_DIR}/.system_userpw &>/dev/null
