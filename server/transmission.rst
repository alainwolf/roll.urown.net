.. image:: Transmission-logo.*
    :alt: ownCloud Logo
    :align: right

BitTorrent
==========

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
  :local: 


Preparations
------------

IP Address
^^^^^^^^^^

Add IPv4 and IPV6 network adresses for the keyserver::

    $ sudo ip addr add 192.0.2.36/24 dev eth0
    $ sudo ip addr add 2001:db8::36/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # bt.example.com - BitTorrent Server
    iface eth0 inet static
        address 192.0.2.36/24
    iface eth0 inet6 static
        address 2001:db8::36/64


DNS Records 
^^^^^^^^^^^

============================ ==== ================================ ======== ===
Name                         Type Content                          Priority TTL
============================ ==== ================================ ======== ===
bt                           A    |publicIPv4|                              300
bt                           AAAA |BitTorrentServerIPv6|
_443._tcp.bt                 TLSA 3 0 1 f8df4b2e..........76a2a0e5
============================ ==== ================================ ======== ===

Check the "Add also reverse record" when adding the IPv6 entry.


Firewall Rules
^^^^^^^^^^^^^^

IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
UDP      51413     |BitTorrentServerIPv4|    BitTorrent NAT UDP Port forwarding
TCP      51413     |BitTorrentServerIPv4|    BitTorrent NAT TCP Port forwarding
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
UDP      51413     |BitTorrentServerIPv6|    Allow BitTorrent UDP
TCP      51413     |BitTorrentServerIPv6|    Allow BitTorrent TCP
TCP      80        |BitTorrentServerIPv6|    Allow HTTP to Transmission Web-UI
TCP      443       |BitTorrentServerIPv6|    Allow HTTPS to Transmission Web-UI
======== ========= ========================= ==================================


Installation
------------

Transmission is in the Ubuntu software repository. We install the server only.

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
    $ sudo chown -R debian-transmission:debian-transmission \
        /var/lib/transmission-daemon/downloads/.incomplete


Configuration
-------------

The configuration file cannot be changed while the daemon is running.

::

    $ sudo stop transmission-daemon

Then open :download:`/etc/transmission-daemon/settings.json 
<config-files/etc/transmission-daemon/settings.json>` and change the  following 
lines:

.. literalinclude:: config-files/etc/transmission-daemon/settings.json
    :language: json
    :linenos:
    :emphasize-lines: 9-10,20,23-24,38,47,53-54


Download Automation
-------------------

With the help of the `FlexGet <http://flexget.com/>`_ add-on, Transmission can
start downloading new files as soon as they are available.

FlexGet monitors RSS feeds, websites and similar sources and passes newly
discovered Torrents who meet the configurable selection criteria to Transmission
for downloading.


FlexGet Installation
^^^^^^^^^^^^^^^^^^^^

FlexGet is a Python script and installed via the *Python package installation
program* ``pip``::

    $ sudo apt-get install python-pip

If you already installed Python packages with ``pip`` before, make sure
everything is up-to- date, as they are not managed by Ubuntu software updates::

    $ sudo -H pip list --outdated | sed 's/(.*//g' | xargs sudo -H pip install -U


Install the FlexGet package::

    $ sudo -H pip install --upgrade flexget


For fetching feeds from webservers which use TLS::

    $ sudo -H pip install requests[security]


To work with Transmission FlexGet uses an additional Python package::

    $ sudo -H pip install --upgrade transmissionrpc


FlexGet Configuration
^^^^^^^^^^^^^^^^^^^^^

Configuration is saved in the users home directory in a YAML file. In our case
its the Transmission daemon home directory: `/var/lib/transmission/daemon`::

    $ sudo mkdir -p /var/lib/transmission-daemon/flexget/
    $ touch /var/lib/transmission-daemon/flexget/config.yml
    $ sudo chown -R debian-transmission:debian-transmission \
        /var/lib/transmission-daemon/flexget 


.. note::

    The configuration file is in YAML format, which means, indentation is not
    just for the looks, has to be two spaces and not tabs.


The configuration file format and options are described in the 
`FlexGet Wiki <http://flexget.com/wiki/Configuration>`_

:download:`/var/lib/transmission-daemon/flexget/config.yml 
<config-files/flexget/config.yml>`:

.. literalinclude:: config-files/flexget/config.yml
    :language: yaml
    :linenos:


In the example above we let FlexGet check for new downloads every hour, using
the schedule `plug-in <http://flexget.com/wiki/Plugins/Daemon/scheduler>`_.

The task itself consists of checking the 
`RSS release feed <https://tails.boum.org/torrents/rss/>`_ of the 
`Tails project <https://tails.boum.org/>`_ by the 
`RSS plugin <http://flexget.com/wiki/Plugins/rss>`_ and  submit new Torrents 
found there to the Transmission daemon using the 
`Transmission plugin <http://flexget.com/wiki/Plugins/transmission>`_.

To let FlexGet check the configuration file for errors::

    $ sudo -Hu debian-transmission flexget check


To do a test run of the tasks::

    $ sudo -Hu debian-transmission flexget --test --debug-warnings execute


System Service (Ubuntu Upstart)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/init/flexget.conf <config-files/etc/init/flexget.conf>`:

.. literalinclude:: config-files/etc/init/flexget.conf
    :language: bash
    :linenos:

::

    $ sudo init-checkconf /etc/init/flexget.conf
    File /etc/init/flexget.conf: syntax ok

::

    $ sudo initctl reload-configuration
    $ sudo start flexget


Web Interface
-------------

Nginx Configuration
^^^^^^^^^^^^^^^^^^^

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



Tracker
-------

`opentracker <https://erdgeist.org/arts/software/opentracker/>`_ is a open and
free bittorrent tracker project. It aims for minimal resource usage and is
intended to run at your wlan router. Currently it is deployed as an open and
free tracker instance. Read our free and open tracker blog and announce your
torrents there (but do not hesitate to setup your own free trackers!).


Installation
------------

opentracker is currently not in the Ubuntu software packages repository.

To install from source:

Get needed software libraries and stuff to be able to build your own software
packages on Ubuntu::

    $ sudo apt-get install libowfat-dev build-essential devscripts git autoconf

Get the source code::

    $ cd /usr/local/src
    $ git clone git://erdgeist.org/opentracker
 
Build::

    $ cd opentracker
    $ ./configure
    $ make

