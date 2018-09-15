Nginx Configuration
====================

We use a modular approach here, with most configuration settings outsourced to
individual files.


.. toctree::
   :maxdepth: 2

   nginx-main
   nginx-http-conf
   nginx-servers-conf
   nginx-extra-conf
   nginx-servers
   nginx-csp


HTTP Settings
-------------

On line 47 in the above :file:`/etc/nginx/nginx.conf` various options from the
directory :file:`/etc/nginx/conf.d` are included.

They are discussed in :doc:`nginx-http-conf`.


Virtual Servers
---------------

Nginx can host multiple websites on a single installation. In Nginx a website
is called a "server". (Apache HTTPd calls them "virtual hosts"). Servers are
identified by their hostname and or IP address.

Sticking to our modular approach, we define individual servers in the directory
:file:`/etc/nginx/servers-available`.

So to activate or disable servers, symbolic links are created or deleted in
:file:`/etc/nginx/servers-enabled`, pointing to server definitions in
:file:`/etc/nginx/servers-available`.

To activate a server::

    $ sudo ln -s /etc/nginx/servers-available/example.net.conf \
        /etc/nginx/servers-enabled/
    $ sudo service nginx reload

De-Activate::

    $ sudo rm /etc/nginx/servers-enabled/example.net.conf
    $ sudo service nginx reload

Configuration of individual sites depends heavily on the nature of the website.

As reference we show a simple website who serves static HTML pages in
:doc:`nginx-servers`.


Test and Activate
-----------------

The configuration is always tested for errors before the Nginx service starts.
Alternatively a test can be requested manually::

    $ sudo service nginx configtest
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
