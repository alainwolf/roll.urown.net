#!/usr/bin/bash
#
# Notify user of borgmatic backup error.
#
# /etc/notify.sh "{configuration_filename}" "{repository}" "{error}" "{output}"

mail -s "Borgmatic Error on ${HOST}" "${USER}" <<EOF

Borgmatic backup on ${HOST} failed.

Configuration file: $1

Repository: $2

Error Message: $3

Command output, if any: $4

For more information, query the systemd journal on ${HOST}.

EOF
