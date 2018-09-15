#
# Rspamd normal worker on Charlotte
#
# Scans messages for spam.
# https://rspamd.com/doc/workers/normal.html
#

# Listen on localhost
bind_socket = "127.0.0.1:11333";
bind_socket = "[::1]:11333";

# Listen on Wireguard VPN
bind_socket = "10.195.171.241:11333";
bind_socket = "[fdc1:d89e:b128:6a04::29ab]:11333";
