#!/usr/bin/env bash

# check the mongo installed status
mongo --eval 'db.runCommand({ connectionStatus: 1 })'

# create the admin user     
ECHO_INFO "Creating Mongo admin user"
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
sleep 2
# create the developer user with read & write
ECHO_INFO "Creating Mongo developer user"
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