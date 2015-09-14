#!/bin/bash
#
# PowerDNS Dynamic IP Updates

# Host to query for stored public IP address
KNOWN_HOST=www.example.com

# Router to query for current IP
ROUTER_IP=192.0.2.1
ROUTER_USER=pdns_updater
ROUTER_SSH_KEY=$HOME/.ssh/pdns_updater_rsa
ROUTER_IFC=sfp1
# Display IP Address on MicroTik Routers
ROUTER_CMD=":put [/ip address get [find interface=\"$ROUTER_IFC\"] address];"

# Our domain name master server to ask stored IP
DNS_MASTER=2001:db8::41

# MySQL server
MYSQL_HOST=localhost
MYSQL_USER=pdns_updater
MYSQL_PASSWORD=********
MYSQL_DB=pdns

# Ask router for current interface IP
READ_WAN_IP=`ssh $ROUTER_USER@$ROUTER_IP -i $ROUTER_SSH_KEY $ROUTER_CMD`

# Strip netmask ("/24") from IP
CURRENT_IP=`expr "$READ_WAN_IP" : '\([0-9\.]*\)'`

# Get current DNS address
DNS_IP=`dig +short @${DNS_MASTER} $KNOWN_HOST A`

# Compare the IPs
if [ $CURRENT_IP == $DNS_IP ]; then
	#echo "*** IPs are the same :) ***"
	exit
else
	echo "*** ALERT! Our WAN IP has changed! ***"
	echo "Old IP Address: $DNS_IP"
	echo "New IP Address: $CURRENT_IP"

	# Update all records in PowerDNS database which use the old IP
	mysql -u $MYSQL_USER -p${MYSQL_PASSWORD} -h $MYSQL_HOST $MYSQL_DB -e \
	   "UPDATE \`records\` 
	    	SET \`content\` = \"$CURRENT_IP\", \`change_date\`=\"`date +%s`\"
        	WHERE \`type\` = \"A\" AND \`content\` = \"$DNS_IP\";" \
    && echo "All DNS records with the old IP where updated." \
    || echo "*** Update of DNS records failed! ***"
fi
