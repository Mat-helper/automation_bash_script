#!/usr/bin/env bash

# -------------------------------------------------------
# ------------------- config database. ------------------
# -------------------------------------------------------
db_server_config()
{

    if [ X"${DB_SERVER}" == X'MONGO' ]; then
       
    # For Mongo database admin user.
    echo " Mongo accessing Admin details: " >> ${SERVER_CONFIG_FILE}
    export MONGO_DB_ADMIN_USER="$(${RANDOM_STRING})"
    echo "export MONGO_DB_ADMIN_USER='${MONGO_DB_ADMIN_USER}'" >> ${SERVER_CONFIG_FILE}

    export MONGO_DB_ADMIN_PASSWD="$(${RANDOM_STRING})"
    echo "export MONGO_DB_ADMIN_PASSWD='${MONGO_DB_ADMIN_PASSWD}'" >> ${SERVER_CONFIG_FILE}

    # For Mongo database user details.
    echo " Mongo accessing Admin details: " >> ${SERVER_CONFIG_FILE}
    export MONGO_USER="$(${RANDOM_STRING})"
    echo "export MONGO_USER='${MONGO_USER}'" >> ${SERVER_CONFIG_FILE}

    export MONGO_PASSWD="$(${RANDOM_STRING})"
    echo "export MONGO_PASSWD='${MONGO_PASSWD}'" >> ${SERVER_CONFIG_FILE}

    export DATABASE_NAME="$(${RANDOM_STRING})"
    echo "export DATABASE_NAME='${DATABASE_NAME}'" >> ${SERVER_CONFIG_FILE}

    export MONGO_PORT="$(${RANDOM_NUMBER})"
    echo "export MONGO_PORT='${MONGO_PORT}'" >> ${SERVER_CONFIG_FILE}

     check_status_before_run mongo_setup
    fi

    echo 'export status_db_server_config="DONE"' >> ${STATUS_FILE}
}