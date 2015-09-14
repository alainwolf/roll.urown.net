Electronic Books Library
========================

.. image:: OPDS-logo.*
    :alt: OPDS Logo
    :align: right

`COPS <http://blog.slucas.fr/en/oss/calibre-opds-php-server>`_ is the Calibre
:term:`OPDS` and HTML server written in PHP. A web-based light alternative to
the Calibre built-in content server. It allows you to serve electronic books
(epub, mobi, pdf, etc.) from your eBook library website either trough web pages
accessible with a webbrowser or directly with a reading device or reading app on
a mobile device trough OPDS.

In this setup we assume, you manage your eBook collection with the
:doc:`/desktop/calibre` electronic book library software on your desktop
computer and synchronize the library with :doc:`/desktop/owncloud-client` to the
:doc:`/server/owncloud-server`. This way all changes made in Calibre on your
desktop are instantly abvailable anywhere else.


Prerequisites
-------------

 * Installed and running :doc:`/server/owncloud-server`
 * Installed :doc:`/desktop/calibre` on a desktop system.
 * Working :doc:`/desktop/owncloud-client` synchronization of the Calibre 
   database and ebook folder.


Network Configuration
---------------------


IP Addresses
^^^^^^^^^^^^

Edit the :file:`/etc/network/interfaces`.

Add additional static IPv4 and IPv6 addresses for the HTML and OPDS servers::

    # books.example.net
    iface eth0 inet static
        address 192.0.2.33/24
    iface eth0 inet6 static
        address 2001:db8::33/64

    # opds.example.net
    iface eth0 inet static
        address 192.0.2.34/24
    iface eth0 inet6 static
        address 2001:db8::34/64


DNS Records
^^^^^^^^^^^

Create TLSA records::

    $ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem books.example.com
    _443._tcp.example.com. IN TLSA 3 0 1 f8df4b2e.......................76a2a0e5
    $ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem opds.example.com
    _443._tcp.example.com. IN TLSA 3 0 1 f8df4b2e.......................76a2a0e5

Add host names and TLSA records as follows:

================ ==== ============================================= ======== ===
Name             Type Content                                       Priority TTL
================ ==== ============================================= ======== ===
books            A    |publicIPv4|                                           300
books            AAAA |BOOKserverIPv6|
_443._tcp.books  TLSA 3 0 1 f8df4b2e.......................76a2a0e5
opds             A    |publicIPv4|                                           300
opds             AAAA |OPDSserverIPv6|
_443._tcp.opds   TLSA 3 0 1 f8df4b2e.......................76a2a0e5
================ ==== ============================================= ======== ===


Firewall Rules
^^^^^^^^^^^^^^

See :doc:`/router/ebooks`.


Software Installation
---------------------
::

    sudo apt-get install php5-gd php5-sqlite
    cd $HOME/downloads
    wget -O cops-1.0.0RC2.zip https://github.com/seblucas/cops/archive/1.0.0RC2.zip
    sudo mkdir -p /var/www/books.example.net/public_html
    cd /var/www/books.example.net/public_html
    unzip $HOME/downloads/cops-1.0.0RC2.zip
    sudo mv cops-1.0.0RC2 cops
    sudo cops/cp config_local.php.example cops/config_local.php


COPS Configuration
------------------

.. code-block:: php

    <?php
        if (!isset($config))
            $config = array();
      
        /*
         * The directory containing calibre's metadata.db file, with sub-directories
         * containing all the formats.
         * BEWARE : it has to end with a /
         */
        $config['calibre_directory'] = '/var/www/owncloud/data/username/files/Calibre/';
        
        /*
         * Full URL prefix (with trailing /)
         * useful especially for Opensearch where a full URL is often required
         * For example Mantano, Aldiko and Marvin require it.
         */
        $config['cops_full_url'] = 'https://books.example.net/';

        /*
         * Catalog's title
         */
        $config['cops_title_default'] = "example.net eBooks";

        /*
         * Catalog's subtitle
         */
        $config['cops_subtitle_default'] = "ownCloud Calibre eBooks Library";
        
        /*
         * Wich header to use when downloading books outside the web directory
         * Possible values are :
         *   X-Accel-Redirect   : For Nginx
         *   X-Sendfile         : For Lightttpd or Apache (with mod_xsendfile)
         *   No value (default) : Let PHP handle the download
         */
        $config['cops_x_accel_redirect'] = "X-Accel-Redirect";

        /*
         * SPECIFIC TO NGINX
         * The internal directory set in nginx config file
         * Leave empty if you don't know what you're doing
         */
        $config['calibre_internal_directory'] = '/Calibre/';

        /*
         * Default timezone
         * Check following link for other timezones :
         * http://www.php.net/manual/en/timezones.php
         */
        $config['default_timezone'] = "Europe/Zurich";

        /*
         * use URL rewriting for downloading of ebook in HTML catalog
         * See README for more information
         *  1 : enable
         *  0 : disable
         */
        $config['cops_use_url_rewriting'] = "1";

        /*
         * split authors by first letter
         * 1 : Yes
         * 0 : No
         */
        $config['cops_author_split_first_letter'] = "0";

        /*
         * split titles by first letter
         * 1 : Yes
         * 0 : No
         */
        $config['cops_titles_split_first_letter'] = "0";

        $config['cops_mail_configuration'] = array( "smtp.host"     => "localhost",
                                                    "smtp.username" => "webmaster@example.net",
                                                    "smtp.password" => "********",
                                                    "smtp.secure"   => "",
                                                    "address.from"  => "webmaster@example.net"
        );


Nginx Virtual Hosts
-------------------


HTML Server
^^^^^^^^^^^

.. code-block:: nginx

    #
    # books.example.net
    # COPS - Calibre OPDS and HTML Server
    # https://github.com/seblucas/cops
    #

    # Unsecured HTTP Site - Redirect to HTTPS
    server {

        # Port-forwarded IPv4 private address from firewall-router
        listen                  192.0.2.30:80;

        # IPv4 private address
        listen                  192.0.2.33:80;

        # IPv6 global address
        listen                  [2001:db8::33]:80;

        server_name             books.example.net;

        # Redirect to HTTPS
        return                  301 https://books.example.net$request_uri;
    }

    # Secured HTTPS Site
    server {

        # Port-forwarded IPv4 private address from firewall-router
        listen                  192.0.2.30:443 ssl spdy;

        # IPv4 private address
        listen                  192.0.2.33:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::33]:443 ssl spdy;

        server_name             books.example.net;

        # TLS - Transport Layer Security Configuration, Certificates and Keys
        include                 /etc/nginx/tls.conf;
        include                 /etc/nginx/ocsp-stapling.conf;
        ssl_certificate         /etc/ssl/certs/example.chained.cert.pem;
        ssl_certificate_key     /etc/ssl/private/example.key.pem;
        ssl_trusted_certificate /etc/ssl/certs/StartCom_Class_2_Server.OCSP-chain.pem;

        # Safe site defaults
        include                 /etc/nginx/sites-defaults/sites-security.conf;
        include                 /etc/nginx/sites-defaults/google-pagespeed.conf;
        include                 /etc/nginx/sites-defaults/compression.conf;

        # Public Documents Root
        root                    /var/www/books.example.net/public_html/cops;

        # PHP Server Configuration
        include                 /etc/nginx/php-handler.conf;

        # # Useful only for Kobo eReader
        location /download/ {
          rewrite ^/download/(\d+)/(\d+)/.*\.(.*)$ /fetch.php?data=$1&db=$2&type=$3 last;
          rewrite ^/download/(\d+)/.*\.(.*)$ /fetch.php?data=$1&type=$2 last;
          break;
        }

        location /Calibre {
            root /var/www/owncloud/data/username/files;
            internal;
        }

        # Temporary Debug Loggin, please remove when done
        #include /etc/nginx/debug.conf;
    }


OPDS Server
^^^^^^^^^^^

.. code-block:: nginx

    #
    # books.example.net
    # COPS - Calibre OPDS and HTML Server
    # https://github.com/seblucas/cops
    #

    # Unsecured HTTP Site - Redirect to HTTPS
    server {

        # Port-forwarded IPv4 private address from firewall-router
        listen                  192.0.2.30:80;

        # IPv4 private address
        listen                  192.0.2.34:80;

        # IPv6 global address
        listen                  [2001:db8::34]:80;

        server_name             opds.example.net;

        # Redirect to HTTPS
        return                  301 https://opds.example.net$request_uri;
    }

    # Secured HTTPS Site
    server {

        # Port-forwarded IPv4 private address from firewall-router
        listen                  192.0.2.30:443 ssl spdy;

        # IPv4 private address
        listen                  192.0.2.34:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::34]:443 ssl spdy;

        server_name             opds.example.net;

        # TLS - Transport Layer Security Configuration, Certificates and Keys
        include                 /etc/nginx/tls.conf;
        include                 /etc/nginx/ocsp-stapling.conf;
        ssl_certificate         /etc/ssl/certs/example.chained.cert.pem;
        ssl_certificate_key     /etc/ssl/private/example.key.pem;
        ssl_trusted_certificate /etc/ssl/certs/StartCom_Class_2_Server.OCSP-chain.pem;

        # Safe site defaults
        include                 /etc/nginx/sites-defaults/sites-security.conf;
        include                 /etc/nginx/sites-defaults/google-pagespeed.conf;
        include                 /etc/nginx/sites-defaults/compression.conf;

        # Public Documents Root
        root                    /var/www/books.example.net/public_html/cops;

        # PHP Server Configuration
        include                 /etc/nginx/php-handler.conf;

        # Use OPDS XML as as directory index
        index feed.php;
        
        location = / {
            index feed.php;
        }

        # Useful only for Kobo reader
        location /download/ {
          rewrite ^/download/(\d+)/(\d+)/.*\.(.*)$ /fetch.php?data=$1&db=$2&type=$3 last;
          rewrite ^/download/(\d+)/.*\.(.*)$ /fetch.php?data=$1&type=$2 last;
          break;
        }

        location /Calibre {
            root /var/www/owncloud/data/username/files;
            internal;
        }

        # Temporary Debug Loggin, please remove when done
        #include /etc/nginx/debug.conf;
    }


Backup Considerations
---------------------

We should be covered by our previous configuration and no additional steps for
backup are needed.
