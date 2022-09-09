#!/usr/bin/env bash

_ROOTDIR="$(pwd)"
CONFIG_DIR="${_ROOTDIR}/../conf"

. ${CONFIG_DIR}/global
. ${CONFIG_DIR}/core

# Re-define @STATUS_FILE, so that iRedMail.sh can read it.
#export STATUS_FILE="${_ROOTDIR}/../.status"

check_user root
check_runtime_dir

export PKG_DIR="${_ROOTDIR}/pkgs"

# Special package.
# command: which.
export BIN_WHICH='which'
export PKG_WHICH='which'
# command: wget.
export BIN_WGET='wget'
export PKG_WGET='wget'
# command: perl.
export BIN_PERL='perl'
export PKG_PERL='perl'

export PKG_WHICH="debianutils"
export PKG_APT_TRANSPORT_HTTPS="apt-transport-https"

prepare_dirs()
{
    ECHO_DEBUG "Creating necessary directories ..."
    for i in ${PKG_DIR} ; do
        [ -d "${i}" ] || mkdir -p "${i}"
    done
}

echo_end_msg()
{
    if [ X"$(basename $0)" != X'get_all.sh' ]; then
        cat <<EOF
********************************************************
* All tasks had been finished successfully. Next step:
*
*   # cd ..
*   # bash server_config.sh
*
********************************************************
EOF
    fi
}

if [ -e ${STATUS_FILE} ]; then
    . ${STATUS_FILE}
else
    echo '' > ${STATUS_FILE}
fi

prepare_dirs

# Check required commands, and install packages which offer the commands.
if [ X"${DISTRO}" == X'UBUNTU' ]; then
    [[ -e /usr/sbin/update-ca-certificates ]] || export MISSING_PKGS="${MISSING_PKGS} ca-certificates"
    [[ -e /usr/lib/apt/methods/https ]] || export MISSING_PKGS="${MISSING_PKGS} ${PKG_APT_TRANSPORT_HTTPS}"
    [[ -e /usr/bin/gpg2 ]] || export MISSING_PKGS="${MISSING_PKGS} gnupg2"
    # dirmngr is required by apt-key
    [ -e /usr/bin/dirmngr ] || export MISSING_PKGS="${MISSING_PKGS} dirmngr"

    if [ X"${DISTRO}" == X'UBUNTU' ]; then
        # Some required packages are in `universe` and `multiverse` apt repos.
        [ -x /usr/bin/apt-add-repository ] || export MISSING_PKGS="${MISSING_PKGS} software-properties-common"
    fi

    check_pkg ${BIN_PERL} ${PKG_PERL}
    check_pkg ${BIN_WGET} ${PKG_WGET}
    check_pkg ${BIN_CURL} ${PKG_CURL}
    check_pkg ${BIN_ZIP} ${PKG_ZIP}
    check_pkg ${BIN_UNZIP} ${PKG_UNZIP}

fi

check_pkg ${BIN_DIALOG} ${PKG_DIALOG}
install_missing_pkg

 # Force update.
    ECHO_INFO "apt update ..."
    ${APTGET} update
     ECHO_INFO "apt upgrade ..."
    ${APTGET} upgrade -y


echo_end_msg && \
echo 'export status_get_all="DONE"' >> ${STATUS_FILE}