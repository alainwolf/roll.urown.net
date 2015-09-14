--
-- Prosody XMPP Tor hidden server duskgytldkxiuqc6.onion
--
VirtualHost "duskgytldkxiuqc6.onion"

    -- Assign this host a certificate for TLS, otherwise it would use the one
    -- set in the global section (if any).
    ssl = {
        key = "/etc/ssl/private/example.com.key.pem";
        certificate = "/etc/ssl/certs/example.com.chained.cert.pem";
        }

    --
    -- Components

    --- Set up a MUC (multi-user chat) room server on conference.urown.net:
    --- Also needs SRV record in DNS pointing to the XMMP server host and port.
    Component "conference.duskgytldkxiuqc6.onion" "muc"

    -- Set up a SOCKS5 bytestream proxy for server-proxied file transfers:
    --- Also needs host record (A and AAAA) the XMMP IP address.
    Component "proxy.duskgytldkxiuqc6.onion" "proxy65"
