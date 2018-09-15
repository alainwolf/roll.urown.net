#
# Controller worker on Charlotte
#
# Manages rspamd stats, learn spam and ham message and serves the WebUI.
# https://rspamd.com/doc/workers/controller.html
#

# Listen on localhost
bind_socket = "127.0.0.1:11334";
bind_socket = "[::1]:11334";

# Listen on WireGuard VPN interface
bind_socket = "10.195.171.241:11334";
bind_socket = "[fdc1:d89e:b128:6a04::29ab]:11334";

# Unix Socket
bind_socket = "/tmp/rspamd-controller.sock mode=0666 owner=_rspamd";

# Allow passwordless access from this host
secure_ip = "127.0.0.1";
secure_ip = "::1";

password = "$2$ozqwiewyd5uym7cdbr7jo6xxg8yuqsee$sk4h4y6geqmqzqo15d6zfti8q5x8cxrnjbbngsrfqd999je95ddy"
