#!/usr/bin/env bash

# cleanup cronjob
cleanup_set_cron_file_permission()
{
    for f in ${CRON_FILE_ROOT} ; do
        if [ -f ${f} ]; then
            ECHO_DEBUG "Set file permission to 0600: ${f}."
            chmod 0600 ${f}
        fi
    done

    echo 'export status_cleanup_set_cron_file_permission="DONE"' >> ${STATUS_FILE}
}


cleanup()
{
    check_status_before_run cleanup_set_cron_file_permission

    echo 'export status_cleanup="DONE"' >> ${STATUS_FILE}
 
}