#!/usr/bin/env bash

. ${CONFIG_DIR}/global
. ${CONFIG_DIR}/core

trap "exit 255" 2

# Initialize config file.
echo '' > ${SERVER_CONFIG_FILE}
chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${SERVER_CONFIG_FILE}
chmod 0400 ${SERVER_CONFIG_FILE}


DIALOG="dialog --colors --no-collapse --insecure --ok-label Next \
        --no-cancel --backtitle Server_configuration"

# Welcome message.
${DIALOG} \
    --title "Welcome and thanks for your use" \
    --yesno "\
Welcome to the server setup wizard, we will ask you some simple questions required to setup a server.

NOTE: You can abort this installation wizard by pressing key Ctrl-C.
" 20 76

# Exit when user choose 'exit'.
[ X"$?" != X"0" ] && ECHO_INFO "Exit." && exit 0

# Get the project name
while :; do
    ${DIALOG} \
        --title "Project Name" \
        --inputbox "\
Please enter the name of the project (in lowercase) used to create user.

NOTES:

* make sure the project name will be all lower case.
* Enter project name are used to create the user for developers usage.
* It cannot be root or ubuntu.
* Don't use any character like ,./';:?><\][{}|]
" 20 76 "${PROJECT_NAME}" 2>${RUNTIME_DIR}/.project_name

    export PROJECT_NAME="$(cat ${RUNTIME_DIR}/.project_name | tr '[A-Z]' '[a-z]')"
    [ X"${PROJECT_NAME}" != X'' ] && break
 
done

rm -f ${RUNTIME_DIR}/.project_name &>/dev/null

export PROJECT_NAME="${PROJECT_NAME}"
echo "export PROJECT_NAME='${PROJECT_NAME}'" >> ${SERVER_CONFIG_FILE}

# --------------------------------------------------
# ------------ Default web server ------------------
# --------------------------------------------------

export DISABLE_WEB_SERVER='NO'
export WEB_SERVER=''

while : ; do
        ${DIALOG} \
        --title "Preferred web server" \
        --radiolist "Choose a web server you want to run.

TIP: Use SPACE key to select item." \
20 79 3 \
"APACHE2" "The fastest web server." "on" \
"No web server" "I don't need any web applications on this server." "off" \
2>${RUNTIME_DIR}/.web_server

        web_server_case_sensitive="$(cat ${RUNTIME_DIR}/.web_server)"
        web_server="$(echo ${web_server_case_sensitive} | tr '[a-z]' '[A-Z]')"
        [ X"${web_server}" != X"" ] && break
    done

    rm -f ${RUNTIME_DIR}/.web_server

if [ X"${web_server}" == X'APACHE2' ]; then
    export WEB_SERVER='APACHE2'

echo "export WEB_SERVER='${WEB_SERVER}'" >>${SERVER_CONFIG_FILE}

# domain configuration.
. ${DIALOG_DIR}/domain_config.sh

else
    export DISABLE_WEB_SERVER='YES'
    echo "export DISABLE_WEB_SERVER='YES'" >>${SERVER_CONFIG_FILE}
fi


# ----------------------------------------------------------
# --------------------- Database server --------------------
# ----------------------------------------------------------

export DISABLE_DB_SERVER='NO'
export DB_SERVER=''

while : ; do
    ${DIALOG} \
    --title "Choose preferred database " \
    --radiolist " \
    It's strongly recommended to choose the one you're familiar with for easy maintenance. 

TIP: Use SPACE key to select item.
" 20 80 3 \
"Mongo" "The platform document-oriented database program." "on" \
"No db server" "Instead of going through monogo altas or Don't need." "off" \
2>${RUNTIME_DIR}/.database

    DB_ORIG_CASE_SENSITIVE="$(cat ${RUNTIME_DIR}/.database)"
    DB_ORIG="$(echo ${DB_ORIG_CASE_SENSITIVE} | tr '[a-z]' '[A-Z]')"
    [ X"${DB_ORIG}" != X"" ] && break
done

    rm -f ${RUNTIME_DIR}/.database &>/dev/null

if [ X"${DB_ORIG}" == X'MONGO' ]; then
    export DB_SERVER='MONGO'

echo "export DB_SERVER='${DB_SERVER}'" >> ${SERVER_CONFIG_FILE}

else 
    export DISABLE_DB_SERVER='YES'
    echo "export DISABLE_DB_SERVER=YES" >> ${SERVER_CONFIG_FILE}
fi

# --------------------------------------------------
# --------------------- Backend --------------------
# --------------------------------------------------
export DISABLE_BACKEND_SERVER='NO'
export BACKEND=''

while : ; do
    ${DIALOG} \
    --title "Choose preferred backend " \
    --radiolist " \
    It's strongly recommended to choose the one you're familiar with for easy maintenance. 

TIP: Use SPACE key to select item.
" 30 95 3 \
"Node" "An_open_source back-end Javascript outside a web browser." "on" \
"No backend server" "I don't need to configure the backend server." "off" \
 2>${RUNTIME_DIR}/.backend

    BACKEND_ORIG_CASE_SENSITIVE="$(cat ${RUNTIME_DIR}/.backend)"
    BACKEND_ORIG="$(echo ${BACKEND_ORIG_CASE_SENSITIVE} | tr '[a-z]' '[A-Z]')"
    [ X"${BACKEND_ORIG}" != X"" ] && break
done

    rm -f ${RUNTIME_DIR}/.backend &>/dev/null

if [ X"${BACKEND_ORIG}" == X'NODE' ]; then
    export BACKEND='NODE'

echo "export BACKEND='${BACKEND}'" >> ${SERVER_CONFIG_FILE}

else 
    export DISABLE_BACKEND_SERVER='YES'
    echo "export DISABLE_BACKEND_SERVER=YES" >> ${SERVER_CONFIG_FILE}
fi


# get Public IP address of this server
. ${DIALOG_DIR}/Ip_config.sh

# Optional components.
. ${DIALOG_DIR}/system_account_dialog.sh

# Append EOF tag in config file.
echo "#EOF" >> ${SERVER_CONFIG_FILE}

#
# Ending message.
#
cat <<EOF
********************************************************************************************
**************************************** WARNING *******************************************
********************************************************************************************
*                                                                                          *
* Below file contains sensitive infomation (username/password), please                     *
* do remember to *MOVE* it to a safe place after installation.                             *
*                                                                                          *
   * ${SERVER_CONFIG_FILE}                                                                   
*                                                                                          *
********************************************************************************************
********************************** Review your settings ************************************
********************************************************************************************

* Project Name :                        ${PROJECT_NAME}
* Database Server :                     ${DB_ORIG_CASE_SENSITIVE}
* Backend server:                       ${BACKEND_ORIG_CASE_SENSITIVE}
* Web server :                          ${web_server_case_sensitive}
* Domain Name :                         ${SUBDOMAIN_NAME}.${DOMAIN_NAME}
* IP address :                          ${PUBLIC_IP}
* System_username :                     ${SYSTEM_ACCOUNT_NAME}


EOF

ECHO_QUESTION -n "Continue? [y|N]"
read_setting ${AUTO_INSTALL_WITHOUT_CONFIRM}
case ${ANSWER} in
    Y|y) : ;;
    N|n|*)
        ECHO_INFO "Cancelled, Exit."
        exit 255
        ;;
esac