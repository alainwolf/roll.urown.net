#!/bin/ash
#
# Update IPv6 address with nsupdate.info
#
# for Synology NAS, as dynamic DDNS clients only work with IPv4
#
# Alain Wolf alain@alainwolf.ch 2018-04-11
#

#
# Settings as provided by nsupdate.info
#
HOST_NAME=test-ipv6.nsupdate.info
HOST_SECRET=YV7xr8UasB

### Do not change anything below here unless you know what you do ###

UPDATE_URL="https://ipv6.nsupdate.info/nic/update"
USER_AGENT="Synology NAS custom script/curl/7.51.0"

/bin/curl --user-agent "$USER_AGENT" \
		--ipv6 --include --silent --show-error \
		--basic --user "${HOST_NAME}:${HOST_SECRET}" \
		${UPDATE_URL}
