Web-Interface
=============

`Poweradmin <http://www.poweradmin.org/>`_ is a friendly web-based DNS
administration tool for PowerDNS servers. The interface has full support for
most of the features of PowerDNS. It has full support for all zone types
(master, native and slave), for supermasters for automatic provisioning of slave
zones, full support for IPv6 and comes with multi-language support.


Web Server Configuration
------------------------

Create a web-application configuration file for Nginx 
:file:`/etc/nginx/poweradmin.conf`:

.. code-block:: nginx

    #
    # Poweradmin 
    # Webinterface for the PowerDNS Server
    #
    include /etc/nginx/php-handler.conf;

Open the virtual host configuration file  :file:`/etc/nginx/sites-
available/server.lan` and add the line to load the PowerDNS GUI web-application
configuration file:

.. code-block:: nginx

    #
    # Poweradmin 
    # Webinterface for the PowerDNS Server
    #
    location = /poweradmin {
        include poweradmin.conf;
    }

Restart the nginx web server::

    $ sudo service nginx restart


Download
--------

::

    $ cd ~/downloads
    $ wget https://github.com/downloads/poweradmin/poweradmin/poweradmin-2.1.6.tgz
    $ tar -xzf poweradmin-2.1.6.tgz


Installation
------------

Simply move the extracted files to the webserver location and change the owner 
to the user running the webserver.

::

    $ sudo mv poweradmin-2.1.6 /var/www/server.lan/public_html/powerdns
    $ sudo chown -R www-data:www-data /var/www/server.lan/public_html/powerdns


Configuration
-------------

Point your browser to https://server.lan/poweradmin/install/index.php

A wizard will guide you trough the configuration.


DNSSEC Support
--------------

.. todo::     

    There might be a better way to enable access to PNDSSEC with less security
    implications.


Poweradmin uses the :manpage:`pdnssec` command for DNSSEC related stuff. For
these to work, the web-server needs to have read access to the PowerDNS
configuration directory.

::

    $ sudo chgrp -R www-data /etc/powerdns
    $ sudo chmod -R g+rX /etc/powerdns

