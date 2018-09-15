#
# Fuzzy Storage Master Worker on Charlotte
#
# Stores fuzzy hashes of messages.
# https://rspamd.com/doc/workers/fuzzy_storage.html
#

# number of worker instances to run
count = 1; # Disabled by default

# Listen on localhost
bind_socket = "127.0.0.1:11333";
bind_socket = "[::1]:11333";

# Listen on Wireguard VPN
bind_socket = "10.195.171.241:11333";
bind_socket = "[fdc1:d89e:b128:6a04::29ab]:11333";

# Store the hashes in Redis.
backend = 'redis';
write_servers = "localhost:6383";
read_servers = "master-slave:localhost:6383:30,dolores.vpn.example.net:6383:20,maeve.vpn.example.net:6383:20";
timeout = 1s;
db = 0;
password = 'opHequ75iJgKnc7AyNJp995jhbzTKOSr';

# Expiration time of stored fuzzy hashes (default: 2 days)
expire = 90d;

# List of slaves (Dolores and Maeve)
slaves "10.195.171.142, fdc1:d89e:b128:6a04::7de4, 10.195.171.47, fdc1:d89e:b128:6a04::961";

# Allow Charlotte to perform changes to fuzzy storage.
allow_update = "127.0.0.1, ::1, 10.195.171.241, fdc1:d89e:b128:6a04::29ab";
