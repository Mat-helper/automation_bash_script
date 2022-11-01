
This is the Bash script used to create the environment to run the node projects 

Web_server: apache2
DB_server: mongo 
Backend_server: Node

and included other features like user creation, sudo privileges for user , clear a cache on server by using cron job, backup script for mongodb by cron.


Make sure to run the bash script on newly installed os. Use below command to run the bash script.

      # cd automation_bash_script
      # bash server_config.sh


# date 25-07-2022
  1. installation command & apache2 web server configuration - http2, rewrite, header, proxy, ssl, virtualhost
  2. initialize the log report for the package installation

# date 4-aug-2022
  1. add the mongo db backup script and place it ot the location by script.
  2. separate the apache page configuration

# date 25-aug-2022
  1. add mongo.conf file configuration

# date 19-SEP-2022
  1. get the variable of domain, subdomain, IP address, system username.
  2. write the functionality separately for packages, apache2, mongo, backend, system user.
  
  
  This script tested on : **ubuntu 18.04, 20.04 **
