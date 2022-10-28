#!/usr/bin/env bash

mongo_setup()
{
     # Starting mongo
    ECHO_DEBUG "Enable service: ${MONGO_RC_SCRIPT_NAME}."
    service_control enable ${MONGO_RC_SCRIPT_NAME}
    
    ECHO_DEBUG "Start service: ${MONGO_RC_SCRIPT_NAME}."
    service_control start ${MONGO_RC_SCRIPT_NAME}

    ECHO_INFO "Configure Mongo database server."

    check_status_before_run mongo_initialize_db

    check_status_before_run mongo_cron_backup

    echo 'export status_mongo_setup="DONE"' >> ${STATUS_FILE}
}

mongo_initialize_db()
{
ECHO_INFO "Initialize MONGO server."

backup_file ${MONGO_CONF}

# create the admin user     
mongo  <<EOF
  use admin;
  db.createUser(
    {
      user: "${MONGO_DB_ADMIN_USER}", 
      pwd: "${MONGO_DB_ADMIN_PASSWD}", 
      roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
    }
  )
EOF

# create the developer user with read & write
mongo -u ${MONGO_DB_ADMIN_USER} -p ${MONGO_DB_ADMIN_PASSWD} --authenticationDatabase admin  <<EOF
  use ${DATABASE_NAME};
  db.createUser(
    {
        user: '${MONGO_USER}', 
        pwd: '${MONGO_PASSWD}', 
        roles: [{role: 'readWrite', db: '${DATABASE_NAME}' } ] 
    }
  )
EOF

# config file
   ECHO_INFO "Copy sample MONGO config file: ${MONGO_CONF_SAMPLE} -> ${MONGO_CONF}."
       if [ ! -f ${MONGO_CONF_SAMPLE} ]; then
            cp ${MONGO_CONF_SAMPLE} ${MONGO_CONF} >> ${INSTALL_LOG} 2>&1
        else
            cp ${SAMPLE_DIR}/mongo/mongod.conf ${MONGO_CONF} >> ${INSTALL_LOG} 2>&1
        fi

# add port number at config file
perl -pi -e 's#PH_MONGO_PORT#$ENV{MONGO_PORT}#g' ${MONGO_CONF}

 # Restarting mongo
    ECHO_DEBUG "Restart service: ${MONGO_RC_SCRIPT_NAME}."
    service_control restart ${MONGO_RC_SCRIPT_NAME}

cat >> ${TIP_FILE} <<EOF

Mongo DB reference : 

    * Config file: ${MONGO_CONF}
    ##################  INFO: Don't share admin user details with developers. #####################
    Superadmin details : 
          * Username: ${MONGO_DB_ADMIN_USER}
          * Password: ${MONGO_DB_ADMIN_PASSWD}
          * Port:     ${MONGO_PORT}
          * DB_NAME:  admin

    #command: 
      mongo -u ${MONGO_DB_ADMIN_USER} -p ${MONGO_DB_ADMIN_PASSWD} --authenticationDatabase admin --port $MONGO_PORT

    #    This is admin login details for mongo database 
    ################################################################################################

    Developer db details : 
          * Username: ${MONGO_USER}
          * Password: ${MONGO_PASSWD}
          * PORT:     ${MONGO_PORT}
          * DB_NAME:  ${DATABASE_NAME}
          * IP        ${PUBLIC_IP}

     share the above details to the developers for login the mongo database.

    # commands : 
      mongo -u ${MONGO_USER} -p ${MONGO_PASSWD} ${PUBLIC_IP}:$MONGO_PORT/${DATABASE_NAME}
      mongoURI: "mongodb://${MONGO_USER}:${MONGO_PASSWD}@${PUBLIC_IP}:$MONGO_PORT/${DATABASE_NAME}"   --- share this mongo uri to developers
      mongodump --host ${PUBLIC_IP} -d ${DATABASE_NAME} --port $MONGO_PORT 
      mongorestore --host ${PUBLIC_IP} -d ${DATABASE_NAME} --port $MONGO_PORT 
EOF

# separatly save the db_details for sharing to the developer.
cat >> ${Developer_TIP_FILE} <<EOF

      * Mongo DB reference : 
          - Username: ${MONGO_USER}
          - Password: ${MONGO_PASSWD}
          - PORT:     ${MONGO_PORT}
          - DB_NAME:  ${DATABASE_NAME}
          - IP :      ${PUBLIC_IP}

      # commands : 
        mongo -u ${MONGO_USER} -p ${MONGO_PASSWD} ${PUBLIC_IP}:$MONGO_PORT/${DATABASE_NAME}
        mongoURI: "mongodb://${MONGO_USER}:${MONGO_PASSWD}@${PUBLIC_IP}:$MONGO_PORT/${DATABASE_NAME}" 
EOF

echo 'export status_mongo_initialize_db="DONE"' >> ${STATUS_FILE}
}

#backup schedule
mongo_cron_backup()
{
mongo_backup_script="${BACKUP_DIR}/${BACKUP_SCRIPT_MONGO_NAME}"

    ECHO_INFO "Setup daily cron job to backup MONGO databases with ${mongo_backup_script}"

    [ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} >> ${INSTALL_LOG} 2>&1
     backup_file ${mongo_backup_script}
    cp ${TOOLS_DIR}/${BACKUP_SCRIPT_MONGO_NAME} ${mongo_backup_script}
    chown ${SYS_USER_ROOT}:${SYS_GROUP_ROOT} ${mongo_backup_script}
    chmod 0500 ${mongo_backup_script}

  # Add cron job
    cat >> ${CRON_FILE_ROOT} <<EOF
# Backup MONGO databases at minute 0 past every 2nd hour
0   */2   *   *   *  ${SHELL_BASH} ${mongo_backup_script}
EOF

# port , username, password, db of mongo.
    perl -pi -e 's#PH_MONGO_PORT#$ENV{MONGO_PORT}#g' ${mongo_backup_script}
    perl -pi -e 's#PH_MONGO_USER#$ENV{MONGO_USER}#g' ${mongo_backup_script}
    perl -pi -e 's#PH_MONGO_PASSWD#$ENV{MONGO_PASSWD}#g' ${mongo_backup_script}
    perl -pi -e 's#PH_DATABASE_NAME#$ENV{DATABASE_NAME}#g' ${mongo_backup_script}

cat >> ${TIP_FILE} <<EOF

Backup MONGO database:
    * Script: ${mongo_backup_script}
    * See also:
        # crontab -l -u ${SYS_USER_ROOT}

EOF
    echo 'export status_mongo_cron_backup="DONE"' >> ${STATUS_FILE}
}



