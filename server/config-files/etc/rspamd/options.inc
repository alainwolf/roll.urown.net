#
# Charlotte IP Addresses
# Mails coming from these addresses originate from this machine.
#
local_addrs [
    "127.0.0.0/8",
    "::1",
    "172.27.88.10",
    "fdc1:d89e:b128:13a6::10"
    "2001:db8:3414:6b1d::10",
    "10.195.171.241",
    "fdc1:d89e:b128:6a04::29ab"
]

#
# example.net Subnets
# Mails from these addresses originate from our network.
#
local_networks [
    "203.0.113.54/32",
    "198.51.100.7/32",
    "2001:db8:48d1::/64",
    "2001:db8:2d07:5b57::/128",
    "172.27.0.0/16",
    "2001:db8:3414::/48",
    "fdc1:d89e:b128::/48",
    "10.195.171.0/24",
]

#
# Domain Name Resolvers
#
dns {
    nameserver = "master-slave:172.27.88.10:53:40, 172.27.88.1:53:30, 10.195.171.142:53:20, 10.195.171.47:53:10";
}

#
# Rspamd WebUI server access
#
neighbours {
    Charlotte {
        host = "https://mail.example.net:443";
        path = "/rspamd/charlotte";
    }
    Dolores {
        host = "https://mail.urown.net:443";
        path = "/rspamd/dolores";
    }
    Maeve {
        host = "https://mail.urown.net:443";
        path = "/rspamd/maeve";
    }
}
