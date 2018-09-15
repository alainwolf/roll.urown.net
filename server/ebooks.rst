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


.. contents::
  :local:


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

    $ tlsa --create --certificate /etc/ssl/certs/example.net.cert.pem books.example.net
    _443._tcp.example.net. IN TLSA 3 0 1 f8df4b2e.......................76a2a0e5
    $ tlsa --create --certificate /etc/ssl/certs/example.net.cert.pem opds.example.net
    _443._tcp.example.net. IN TLSA 3 0 1 f8df4b2e.......................76a2a0e5

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

See :doc:`/router/index`.


Software Installation
---------------------

::

  $ sudo -s
  $ apt install php-sqlite3
  $ mkdir -p /var/www/books.example.net
  $ cd /var/www/books.example.net
  $ git clone git clone --no-checkout https://github.com/seblucas/cops.gi
  $ cd cops
  $ git tag
  1.0.1
  1.1.0
  1.1.1
  $ git checkout 1.1.1
  $ cp config_local.php.example config_local.php
  $ chown -R www-data:www-data /var/www/urown.net/books/cops
  $ exit
  $ cd /var/www/urown.net/books/cops
  $ sudo -u www-data composer install --no-dev --optimize-autoloader
  $ sudo -u www-data cp config_local.php.example config_local.php


COPS Configuration
------------------

Edit :file:`config_local.php`:

.. code-block:: php

    <?php
        if (!isset($config))
            $config = array();

        /*
         ***************************************************
         * Please read config_default.php for all possible
         * configuration items
         ***************************************************
         */

        /*
         * The directory containing calibre's metadata.db file, with sub-directories
         * containing all the formats.
         * BEWARE : it has to end with a /
         */
        $config['calibre_directory'] = '/var/lib/nextcloud/data/user/files/Books/';

        /*
         * SPECIFIC TO NGINX
         * The internal directory set in nginx config file
         * Leave empty if you don't know what you're doing
         */
        $config['calibre_internal_directory'] = '/Books/';

        /*
         * Full URL prefix (with trailing /)
         * useful especially for Opensearch where a full URL is often required
         * For example Mantano, Aldiko and Marvin require it.
         */
        $config['cops_full_url'] = 'https://books.example.net/';

        /*
         * Number of recent books to show
         */
        $config['cops_recentbooks_limit'] = '25';

        /*
         * Catalog's title
         */
        $config['cops_title_default'] = "Books";

        /*
         * Wich header to use when downloading books outside the web directory
         * Possible values are :
         *   X-Accel-Redirect   : For Nginx
         *   X-Sendfile         : For Lightttpd or Apache (with mod_xsendfile)
         *   No value (default) : Let PHP handle the download
         */
        $config['cops_x_accel_redirect'] = "X-Accel-Redirect";

        /*
         * Default timezone
         * Check following link for other timezones :
         * http://www.php.net/manual/en/timezones.php
         */
        $config['default_timezone'] = 'Europe/Paris';

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
        $config['cops_author_split_first_letter'] = '0';

        /*
         * split titles by first letter
         * 1 : Yes
         * 0 : No
         */
        $config['cops_titles_split_first_letter'] = '0';

        /*
         * Update Epub metadata before download
         * 1 : Yes (enable)
         * 0 : No
         */
        $config['cops_update_epub-metadata'] = '1';

        /*
         * Enable and configure Send To Kindle (or Email) feature.
         *
         * Don't forget to authorize the sender email you configured in your
         * Kindle's  Approved Personal Document E-mail List.
         */
        $config['cops_mail_configuration'] = array(
                    "smtp.host"     => "mail.example.net",
                    "smtp.username" => "webmaster@example.net",
                    "smtp.password" => "********",
                    "smtp.secure"   => "1",
                    "smtp.port"     => "587",
                    "address.from"  => "webmaster@example.net",
                    "subject"       => "[eBook] "
                );

        /*
         * Directory to keep resized thumbnails: allow to resize thumbnails only
         * on first access, then use this cache.
         * $config['cops_thumbnail_handling'] must be ""
         * "" : don't cache thumbnail
         * "/tmp/cache/" (example) : will generate thumbnails in /tmp/cache/
         * BEWARE : it has to end with a /
         */
        $config['cops_thumbnail_cache_directory'] = '/tmp/cache/';

        /*
         * Which template is used by default :
         * 'default'
         * 'bootstrap'
         */
        $config['cops_template'] = 'bootstrap';



Nginx Configuration
-------------------


Virtual Server
^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/nginx/servers-available/books.example.net.conf
    :language: nginx


COPS Web Application
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/nginx/webapps/cops.conf
    :language: nginx


Content Security Policy
^^^^^^^^^^^^^^^^^^^^^^^

:doc:`CSP-Builder </server/nginx/nginx-config/nginx-csp>` JSON file
:file:`/etc/nginx/csp/books.example.net.csp.json`:

.. code-block:: json

  {
      "base-uri": {
          "self": true
      },
      "default-src": {
          "self": true
      },
      "img-src": {
          "self": true,
          "data": true
      },
      "script-src": {
          "self": true,
          "unsafe-inline": true,
          "unsafe-eval": true
      },
      "style-src": {
          "self": true,
          "unsafe-inline": true
      },
      "form-action": {
          "self": true
      },
      "frame-ancestors": {
        "self": true
      },
      "plugin-types": [],
      "block-all-mixed-content": true,
      "upgrade-insecure-requests": false
  }


Generated Nginx configuration :file:`/etc/nginx/csp/books.example.net.csp,conf`:

.. code-block:: nginx

  add_header Content-Security-Policy
                 "base-uri 'self';
                  default-src 'self';
                  form-action 'self';
                  frame-ancestors 'self';
                  img-src 'self' data:;
                  script-src 'self' 'unsafe-inline' 'unsafe-eval';
                  style-src 'self' 'unsafe-inline';
                  block-all-mixed-content";



Backup Considerations
---------------------

We should be covered by our previous configuration and no additional steps for
backup are needed.
