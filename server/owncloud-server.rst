.. image:: ownCloud-logo.*
    :alt: ownCloud Logo
    :align: right

Cloud Storage
=============

`ownCloud <https://owncloud.org/>`_ provides universal access to your files via
the web, your computer or  your mobile devices — wherever you are.

It also provides a platform to easily view & sync your contacts, calendars and 
bookmarks across all your devices and enables basic editing right on the web.

.. contents:: \ 


Software Package Repository
---------------------------

Add the official owncloud.org Ubuntu package repository hosted on OpenSuse Build
Service::

    $ sudo -s
    $ echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_14.04/ /' \
    	>> /etc/apt/sources.list.d/owncloud.list
    $ exit

Add the package signing key to the systems trusted packages keyring::

    $ wget -O - http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_14.04/Release.key \ | 
    	sudo apt-key add -

Update the systems packages list::

    $ sudo apt-get update

ownCloud Package
----------------

Install the ownCloud server package::

    $ sudo apt-get install owncloud 

The ownCloud server PHP scripts will be installed in the 
:file:`/var/www/owncloud` directory.

There is also a long list of additional software installed.

The package is installed in :file:`/var/www/owncloud` and package updates will 
be applied there.

Stop the installed Apache service, as we will run ownCloud under Nginx::

    $ sudo service apache2 stop
    
Additional Packages
-------------------

ownCloud can use a number of software packages to incerease preformance and 
offer additional features if they are installed::

    $ sudo apt-get install php-apcu libav-tools libreoffice imagemagick


APCu - APC User Cache
^^^^^^^^^^^^^^^^^^^^^

The ownCloud package source and the website recommend installation of 
of `php5-apc <http://php.net/manual/en/book.apc.php>`_ for better 
performance.

Starting with PHP version 5.5 the 
`Zend Opcache <http://www.php.net/manual/en/book.opcache.php>`_ is 
integrated and shipped with PHP. Zend Opcache is faster then APC in opcode 
caching.

Ubuntu started to use PHP 5.5 with Release 13.10. The now obsolete 
package php5-apc is no longer available.

For variable cache storage, there is the stripped down 
`APCu <http://pecl.php.net/package/APCu>`_ extension. APCu adds
support to store PHP variables in shared user space.

.. note::
   The version of APCu shipped with PHP on Ubuntu 14.04 LTS is unstable.
   Download and install the updated version 4.0.7 package from Launchpad.

::

    $ cd downloads
    $ wget https://launchpad.net/~ondrej/+archive/ubuntu/php5/+build/6149263/+files/php5-apcu_4.0.6-1%2Bdeb.sury.org~utopic%2B1_amd64.deb
    $ sudo dpkg -i php5-apcu_4.0.6-1+deb.sury.org~utopic+1_amd64.deb
    $ sudo restart php-fpm



libav - Open source audio and video processing tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ownCloud package source and the website recommend installation of 
`FFmpeg <http://www.ffmpeg.org/>`_.

Since Ubuntu 11.04 ffmpeg has been replaced by `libav <http://www.libav.org/>`_. 
While Ubuntu Desktop systems have this installed by default, server systems need 
to add it manually.


libreoffice and imagemagick
^^^^^^^^^^^^^^^^^^^^^^^^^^^

To properly handle various document and file formats ownCloud needs to be able 
to read and understand them. This is used for example when creating previews of 
documents. Therefore its adviable to install LibreOffice and ImageMagick.


ownCloud Data Directory
-----------------------

For better security the ownCloud server administration guide, recommends using a
data-directory outside of the ownCloud webserver document root directory:

Create ownCloud server data-directory and logs::

	$ cd /var/www
	$ sudo mkdir -p cloud.example.com/{log,oc_data}

Re-adjust ownerships and access rights::

    $ sudo chown -R www-data:www-data cloud.example.com/{log,oc_data}


ownCloud Database
-----------------

ownCloud needs a database we have to prepare.

In this example we will create a user **owncloud_example** and a database with
the same name which we later will give to the ownCloud server for use.

Start by creating a secure (more then 128 bits) and hard to guess password for
the database user::

    $ pwgen --secure 24 1
    ********

Start database command session::
    
    $ mysql -u root -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 28
    Server version: 5.5.37-MariaDB-0ubuntu0.14.04.1 (Ubuntu)

    Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.


Create a new user for ownCloud, replace the asterisks below with 
the password created earlier:

.. code-block:: mysql

    > CREATE USER 'owncloud_example'@'localhost' IDENTIFIED BY '********';
    Query OK, 0 rows affected (0.01 sec)


Create the database for ownCloud:

.. code-block:: mysql

    > CREATE DATABASE IF NOT EXISTS owncloud_example;
    Query OK, 1 row affected (0.01 sec)


Now grant the user access to the database:

.. code-block:: mysql

    > GRANT ALL PRIVILEGES ON owncloud_example.* TO 'owncloud_example'@'localhost';
    Query OK, 0 rows affected (0.00 sec)

    
Access rights are only acvtivated after the database server has reloaded its privileges table:

.. code-block:: mysql

    > FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0.00 sec)

Close the session with the database server:

.. code-block:: mysql

    > QUIT
    Bye


Nginx Configuration
-------------------

Create the Nginx configuration for ownCloud as documented in the official 
`ownCloud Installation Guide <http://doc.owncloud.org/server/6.0/admin_manual/installation/installation_source.html#nginx-configuration>`_.

Following is the Web application configuration file 
:file:`/etc/nginx/owncloud.conf` for the ownCloud server on Nginx:

.. code-block:: nginx
   :linenos:

    #
    # Nginx OwnCloud Server Configuration
    # http://doc.owncloud.org/server/6.0/admin_manual/installation/installation_source.html#nginx-configuration

    # Allow file uploads up to 16 GigaBytes
    # php.ini settings "upload_max_filesize", "post_max_size" and "output_buffering"
    # must match this.
    client_max_body_size 16G;

    # Number and size of the buffers for reading response from FastCGI server
    fastcgi_buffers 64 4K;

    rewrite ^/caldav(.*)$ /remote.php/caldav$1 redirect;
    rewrite ^/carddav(.*)$ /remote.php/carddav$1 redirect;
    rewrite ^/webdav(.*)$ /remote.php/webdav$1 redirect;

    index index.php;
    error_page 403 /core/templates/403.php;
    error_page 404 /core/templates/404.php;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~ ^/(data|config|\.ht|db_structure\.xml|README) {
        deny all;
    }

    location / {

        # The following 2 rules are only needed with webfinger
        rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
        rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;

        rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
        rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;

        rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;

        try_files $uri $uri/ index.php;
    }

    # Handle PHP scripts
    location ~ ^(.+?\.php)(/.*)?$ {
        try_files $1 = 404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$1;
        fastcgi_param PATH_INFO $2;

        # Improve performance and allow pause/resume on static file downloads
        fastcgi_param MOD_X_ACCEL_REDIRECT_ENABLED on;

        # Allow file uploads up to 10 GigaBytes
        # Nginx setting "client_max_body_size" must match this.
        fastcgi_param PHP_VALUE "post_max_size = 16G \n upload_max_filesize = 16G \n output_buffering = 16384";

        fastcgi_pass php-backend;
    }

    # Improve performance and allow pause/resume on static file downloads
    location ~ ^/tmp/oc-noclean/.+$ {
        internal;
        root /;
    }

    # Set long EXPIRES header on static assets
    location ~* ^.+\.(jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
        expires 30d;

        # Optional: Don't log access to assets
        access_log off;
    }


Virtual Host Example
^^^^^^^^^^^^^^^^^^^^

Next set up a secured virtual host and include the ownCloud configuration. 

The following would be saved as 
:file:`/etc/nginx/sites-available/cloud.example.com.conf`. Your mileage may 
vary on server_name and IP addresses:

.. code-block:: nginx
   :linenos:
   :emphasize-lines: 40,43-45,49

    #
    # cloud.example.com OwnCloud Server

    # Unsecured HTTP Site - Redirect to HTTPS
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.11:80;

        # IPv6 global address
        listen                  [2001:db8::11]:80;

        server_name             cloud.example.com;

        # Redirect to HTTPS
        return                  301 https://cloud.example.com$request_uri;
    }

    # Secured HTTPS Site
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.12:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::12]:443 ssl spdy;

        server_name             cloud.example.com;

        # TLS - Transport Layer Security Configuration, Certificates and Keys
        include                    /etc/nginx/tls.conf;
        include                    /etc/nginx/ocsp-stapling.conf;
        ssl_certificate_key      /etc/ssl/certs/example.com.chained.cert.pem;
        ssl_certificate_key      /etc/ssl/private/example.com.key.pem;
        ssl_trusted_certificate  /etc/ssl/certs/CAcert_Class_3_Root.OCSP-chain.pem;

        # Web server documents root directory (where owncloud is installed)
        root                    /var/www/owncloud;

        # ownCloud data directory (recommended to be outside the server documents root)
        location ~ ^/var/www/cloud.example.com/oc_data {
            internal;
            root /;
        }

        # OwnCloud Server Configuration
        include                 /etc/nginx/owncloud.conf;

        # Access and Error Logging Configuration
        access_log              /var/www/cloud.example.com/log/access.log;
        error_log               /var/www/cloud.example.com/log/error.log;
    }

Activate the new website and restart the Nginx server::

    $ sudo ln -s /etc/nginx/sites-available/cloud.example.com.conf /etc/nginx/sites-enabled/
    $ sudo service nginx restart

