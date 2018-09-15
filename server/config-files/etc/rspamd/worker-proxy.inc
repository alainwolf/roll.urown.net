#
# Rspamd proxy worker on Charlotte
#
# Interacts with MTA using Milter protocol, forwards messages to scanning
# layer.
# https://rspamd.com/doc/workers/rspamd_proxy.html
#

# localhost
bind_socket = "127.0.0.1:11332";
bind_socket = "[::1]:11332";

milter = yes;
timeout = 120s;

# Available scanners
upstream "scan" {
    default = yes;
    hosts = "master-slave:localhost:11333:30,dolores.vpn.example.net:11333:20,maeve.vpn.example.net:11333:20";
}

