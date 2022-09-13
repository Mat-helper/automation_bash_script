#!/usr/bin/env bash

install_all()
{
 ALL_PKGS=''
    ENABLED_SERVICES=''
    DISABLED_SERVICES=''
    
 # Apache2
    if [ X"${WEB_SERVER}" == X'APACHE2' ]; then
       if [ X"${DISTRO}" == X'UBUNTU' ]; then
            ALL_PKGS="${ALL_PKGS} apache2"
        fi

        ENABLED_SERVICES="${ENABLED_SERVICES} ${APACHE2_RC_SCRIPT_NAME} "
    fi

 # lets encrypt

    if [ X"${SSL_CONFIGURATION}" == X'Lets encrypt']; then
         if [ X"${DISTRO}" == X'UBUNTU' ]; then
         add-apt-repository ppa:certbot/certbot
         ALL_PKGS="${ALL_PKGS} python-certbot-apache"
         fi
    fi     
    
 # node
    if [ X"${BACKEND}" == X'NODE' ]; then
       if [ X"${DISTRO}" == X'UBUNTU' ]; then
            curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - 
            ALL_PKGS="${ALL_PKGS} nodejs"
        fi
    fi

#mongo
 if [ X"${DB_SERVER}" == X'MONGO' ]; then
       if [ X"${DISTRO}" == X'UBUNTU' ]; then
            wget -qO - https://www.mongodb.org/static/pgp/server-4.0.asc | sudo apt-key add - 
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list 
            ALL_PKGS="${ALL_PKGS} mongodb-org"
          
        fi
        ENABLED_SERVICES="${ENABLED_SERVICES} ${MONGO_RC_SCRIPT_NAME} "
    fi

    # Firewall
    if [ X"${DISTRO}" == X'UBUNTU' ]; then
        # Disable ufw service.
        export DISABLED_SERVICES="${DISABLED_SERVICES} ufw"

        # Use nftables since Ubuntu 20.04.
        ALL_PKGS="${ALL_PKGS} nftables"
        ENABLED_SERVICES="${ENABLED_SERVICES} nftables"
    fi

    export ALL_PKGS ENABLED_SERVICES DISABLED_SERVICES PKG_SCRIPTS

    # Install all packages.
    install_all_pkgs()
    {
        eval ${install_pkg} ${ALL_PKGS} | tee ${PKG_INSTALL_LOG}

        if [ -f ${RUNTIME_DIR}/.pkg_install_failed ]; then
            ECHO_ERROR "Installation failed, please check the terminal output."
            ECHO_ERROR "If you're not sure what the problem is, try to get help in iRedMail"
            ECHO_ERROR "forum: https://forum.iredmail.org/"
            exit 255
        fi
    }
    }

    after_package_installation()
    {
        echo 'export status_after_package_installation="DONE"' >> ${STATUS_FILE}
    }

    # Do not run them with 'check_status_before_run', so that we can always
    # install missed packages and enable/disable new services while re-run
    # iRedMail installer.
    install_all_pkgs
    enable_all_services

    check_status_before_run after_package_installation



}