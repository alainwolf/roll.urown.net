Domain Name Resolving
=====================



Installation
------------

::
    
    $ opkg update
    $ opkg install unbound


Configuration
-------------

::
    
    $ cd /etc/unbund
    $ wget -O ICANN.cache ftp://FTP.INTERNIC.NET/domain/named.cache
    $ wget -O ORSN.cache http://www.orsn.org/roothint/root-hint.txt
    $ wget http://ftp.isc.org/www/dlv/dlv.isc.org.key


Edit :file:`/etc/unbound/unbound.conf`:

.. code-block:: ini

    ...

        # file to read root hints from.
        # get one from ftp://FTP.INTERNIC.NET/domain/named.cache
        # root-hints: ""
        #root-hints: "/etc/unbound/named.cache"
        root-hints: "/etc/unbound/ORSN.cache"

    ...

        # Allow the domain (and its subdomains) to contain private addresses.
        # local-data statements are allowed to contain private addresses too.
        # private-domain: "example.net"
        private-domain: "lan"

    ...

        # if yes, the above default do-not-query-address entries are present.
        # if no, localhost can be queried (for testing and debugging).
        # do-not-query-localhost: yes
        do-not-query-localhost: no

    ...

        # File with DLV trusted keys. Same format as trust-anchor-file.
        # There can be only one DLV configured, it is trusted from root down.
        # Download http://ftp.isc.org/www/dlv/dlv.isc.org.key
        dlv-anchor-file: "dlv.isc.org.key"

    ...

        # Ignore chain of trust. Domain is treated as insecure.
        # domain-insecure: "example.net"
        domain-insecure: "lan."
        domain-insecure: "168.192.in-addr.arpa."    
    ...

        # a number of locally served zones can be configured.
        #   local-zone: <zone> <type>
        #   local-data: "<resource record string>"
        # o deny serves local data (if any), else, drops queries. 
        # o refuse serves local data (if any), else, replies with error.
        # o static serves local data, else, nxdomain or nodata answer.
        # o transparent gives local data, but resolves normally for other names
        # o redirect serves the zone data for any subdomain in the zone.
        # o nodefault can be used to normally resolve AS112 zones.
        # o typetransparent resolves normally for other types and other names
        #
        # defaults are localhost address, reverse for 127.0.0.1 and ::1
        # and nxdomain for AS112 zones. If you configure one of these zones
        # the default content is omitted, or you can omit it with 'nodefault'.
        # 
        # If you configure local-data without specifying local-zone, by
        # default a transparent local-zone is created for the data.
        #
        # You can add locally served data with
        # local-zone: "local." static
        # local-data: "mycomputer.local. IN A 192.0.2.51"
        # local-data: 'mytext.local TXT "content of text record"'
        #
        # You can override certain queries with
        # local-data: "adserver.example.net A 127.0.0.1"
        #
        # You can redirect a domain to a fixed address with
        # (this makes example.net, www.example.net, etc, all go to 192.0.2.3)
        # local-zone: "example.net" redirect
        # local-data: "example.net A 192.0.2.3"
        local-zone: "168.192.in-addr.arpa" nodefault

    ...

    forward-zone:
            name: "lan."
            forward-addr: 127.0.0.1@5553
        
    forward-zone:
            name: "20.172.in-addr.arpa."
            forward-addr: 127.0.0.1@5553
