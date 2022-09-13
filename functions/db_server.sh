#!/usr/bin/env bash


# -------------------------------------------------------
# ------------------- config database. ------------------
# -------------------------------------------------------
db_server_config()
{

    if [ X"${BACKEND}" == X'MONGO' ]; then
       
    # For Mongo database management.
    echo " Mongo accessing Admin details: " >> ${SERVER_CONFIG_FILE}
    export MONGO_DB_ADMIN_USER="$(${RANDOM_STRING})"
    echo "export MONGO_DB_ADMIN_USER='${MONGO_DB_ADMIN_USER}'" >> ${SERVER_CONFIG_FILE}

    export MONGO_DB_ADMIN_PASSWD="$(${RANDOM_STRING})"
    echo "export MONGO_DB_ADMIN_PASSWD='${MONGO_DB_ADMIN_PASSWD}'" >> ${SERVER_CONFIG_FILE}

     check_status_before_run mongo_setup
    fi

    echo 'export status_db_server_config="DONE"' >> ${STATUS_FILE}
}