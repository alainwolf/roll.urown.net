Transmissoin BitTorrent Server
==============================

`Transmission <http://transmissionbt.com/>`_ takes care of downloading and 
seeding files in the BitTorrent filesharing network.

Installed on a server as long.running service has substantial benefits from 
running it directly on a personal device.

 * No need to keep a system online or running until download completes.
 * Seed files forever, not only while online.
 * File transfers with residential high-speed connection, while on the road.
 * Tranasfers form multiple users don't get in the way of each other.
 * Completed downloads are available immediately to all users who have access to 
   the server.
 * Web-Interface for access without client software.

On the client side, nothing changes. You use the same client software the same 
way. While there is no noticable difference, behind the scenes all transfers 
take place on the server instead of the users desktop system.

.. contents:: \ 


Installation
------------

Deluge is in the Ubuntu software repository. We install the server only.

::
    
    $ sudo apt-get install transmission-daemon

After the installation there is 
 * A new user and group **debian-transmission**.
 * The users home directory is :file:`/home/debian-transmission`, but it doesn't exist.
 * A directory :file:`/var/lib/transmission-daemon` for the downloads, 
   state-data and configuration.
 * A configuration file :file:`/etc/transmission-daemon/settings.json`.
 * A service configuration file :file:`/etc/default/transmission-daemon`.
 * A Ubuntu Upstart service :file:`/etc/init/transmission-daemon` which will 
   already be running.
 * The daemon is listening on all interfaces on TCP port 9091 and TCP and UDP 
   ports 51413.


Directory for Incomplete Downloads
----------------------------------

::

    $ sudo mkdir -p /var/lib/transmission-daemon/downloads/.incomplete
    $ sudo chown -R debian-transmission:debian-transmission /var/lib/transmission-daemon/downloads/.incomplete


Blocklist
---------

::

    $ sudo mkdir -p /var/www/bt.example.com/{log,public_html}
    $ sudo mkdir -p /var/www/bt.example.com/public_html/blocklist
    $ sudo chown -R www-data:www-data /var/www/bt.example.com

::

    $ sudo wget -O /etc/cron.daily/update-torrent-blocklist \
          https://raw.githubusercontent.com/walshie4/Ultimate-Blocklist/master/UpdateList.sh
    $ sudo editor /etc/cron.daily/update-torrent-blocklist

::

    #-----CONFIG-----
    LIST="list.txt" #This is the name of the final list file
    PATH_TO_LIST="/var/www/bt.example.com/public_html/blocklist/" #This is the path to the final list file
    #---END CONFIG---

::

    $ sudo chmod +x /etc/cron.daily/update-torrent-blocklist


Configuration
-------------

Before changing anything in the configuration the daemon shoulf be shut down.

::

    $ sudo stop transmission-daemon

Then open :file:`/etc/transmission-daemon/settings.json` and change the 
following lines:

.. code-block:: json
   :linenos:
   :emphasize-lines: 9-12,20,23-24,38,47,53-54

    {
        "alt-speed-down": 50, 
        "alt-speed-enabled": false, 
        "alt-speed-time-begin": 540, 
        "alt-speed-time-day": 127, 
        "alt-speed-time-enabled": false, 
        "alt-speed-time-end": 1020, 
        "alt-speed-up": 50, 
        "bind-address-ipv4": "192.0.2.15", 
        "bind-address-ipv6": "2001:db8::15", 
        "blocklist-enabled": true, 
        "blocklist-url": "https://bt.example.com/blocklist/list.txt", 
        "cache-size-mb": 4, 
        "dht-enabled": true, 
        "download-dir": "/var/lib/transmission-daemon/downloads", 
        "download-limit": 100, 
        "download-limit-enabled": 0, 
        "download-queue-enabled": true, 
        "download-queue-size": 5, 
        "encryption": 2, 
        "idle-seeding-limit": 30, 
        "idle-seeding-limit-enabled": false, 
        "incomplete-dir": "/var/lib/transmission-daemon/downloads/.incomplete", 
        "incomplete-dir-enabled": true, 
        "lpd-enabled": false, 
        "max-peers-global": 200, 
        "message-level": 2, 
        "peer-congestion-algorithm": "", 
        "peer-id-ttl-hours": 6, 
        "peer-limit-global": 200, 
        "peer-limit-per-torrent": 50, 
        "peer-port": 51413, 
        "peer-port-random-high": 65535, 
        "peer-port-random-low": 49152, 
        "peer-port-random-on-start": false, 
        "peer-socket-tos": "default", 
        "pex-enabled": true, 
        "port-forwarding-enabled": true, 
        "preallocation": 1, 
        "prefetch-enabled": 1, 
        "queue-stalled-enabled": true, 
        "queue-stalled-minutes": 30, 
        "ratio-limit": 2, 
        "ratio-limit-enabled": false, 
        "rename-partial-files": true, 
        "rpc-authentication-required": true, 
        "rpc-bind-address": "127.0.0.1", 
        "rpc-enabled": true, 
        "rpc-password": "{0286d69a37a92c1faeb593e5533c18e56985597eR/Xlj4wL", 
        "rpc-port": 9091, 
        "rpc-url": "/transmission/", 
        "rpc-username": "transmission", 
        "rpc-whitelist": "127.0.0.1", 
        "rpc-whitelist-enabled": true, 
        "scrape-paused-torrents-enabled": true, 
        "script-torrent-done-enabled": false, 
        "script-torrent-done-filename": "", 
        "seed-queue-enabled": false, 
        "seed-queue-size": 10, 
        "speed-limit-down": 100, 
        "speed-limit-down-enabled": false, 
        "speed-limit-up": 100, 
        "speed-limit-up-enabled": false, 
        "start-added-torrents": true, 
        "trash-original-torrent-files": false, 
        "umask": 18, 
        "upload-limit": 100, 
        "upload-limit-enabled": 0, 
        "upload-slots-per-torrent": 14, 
        "utp-enabled": true
    }


Nginx Configuration
-------------------

:file:`/etc/nginx/sites-available/bt.example.com.conf`

.. code-block:: nginx
   :linenos:

    #
    # bt.example.com BitTorrent Server

    upstream transmission {
        server 127.0.0.1:9091;
        keepalive 4;
    }

    # Unsecured HTTP Site - Redirect to HTTPS
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.10:80;

        # IPv4 private address
        listen                  192.0.2.15:80;

        # IPv6 global address
        listen                  [2001:db8::15]:80;

        server_name             bt.example.com;

        # Redirect to HTTPS
        return                  301 https://bt.example.com$request_uri;
    }

    # Secured HTTPS Site
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.12:443 ssl spdy;

        # IPv4 private address
        listen                  192.0.2.15:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::15]:443 ssl spdy;

        server_name bt.example.com;

        # TLS - Transport Layer Security Configuration, Certificates and Keys
        include                  /etc/nginx/tls.conf;
        include                  /etc/nginx/ocsp-stapling.conf;
        ssl_certificate_key      /etc/ssl/certs/example.com.chained.cert.pem;
        ssl_certificate_key      /etc/ssl/private/example.com.key.pem;
        ssl_trusted_certificate  /etc/ssl/certs/CAcert_Class_3_Root.OCSP-chain.pem;

         # Default common website settings
         include                 /etc/nginx/sites-defaults/*.conf;

        # Public Documents Root
        root                    /var/www/bt.example.com/public_html;

        location /transmission/ {
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_pass_header X-Transmission-Session-Id;

            location /transmission/rpc {
                proxy_pass http://transmission;
            }

            location /transmission/web/ {
                proxy_pass http://transmission;
            }

            location /transmission/upload {
                proxy_pass http://transmission;
            }

            location /transmission/web/style/ {
                alias /usr/share/transmission/web/style/;
            }

            location /transmission/web/javascript/ {
                alias /usr/share/transmission/web/javascript/;
            }

            location /transmission/web/images/ {
                alias /usr/share/transmission/web/images/;
            }
        }

         # Logging Configuration
         access_log              /var/www/bt.example.com/log/access.log;
         error_log               /var/www/bt.example.com/log/error.log;

    }





Tuning TCP/IP
-------------

Receive Buffer
^^^^^^^^^^^^^^

.. code-block:: text

    UDP Failed to set receive buffer: requested 4194304, got 425984 (tr-udp.c:78)
    UDP Please add the line "net.core.rmem_max = 4194304" to /etc/sysctl.conf (tr-udp.c:83)


Requested: 4,194,304

Got: 425,984

Send Buffer
^^^^^^^^^^^

.. code-block:: text

    UDP Failed to set send buffer: requested 1048576, got 425984 (tr-udp.c:89)
    UDP Please add the line "net.core.wmem_max = 1048576" to /etc/sysctl.conf (tr-udp.c:94)


Requested: 1,048,576

Got: 425,984

Solution
^^^^^^^^

::

    $ sudo -s
    $ echo "net.core.rmem_max = 4194304" >> /etc/sysctl.d/60-transmission-daemon.conf
    $ echo "net.core.wmem_max = 1048576" >> /etc/sysctl.d/60-transmission-daemon.conf
    $ service procps start 
    $ exit



