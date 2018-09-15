Global HTTP Settings
====================

.. contents::
  :local:


Following are the global HTTP server settings loaded from the
:file:`/etc/nginx/http-conf.d/` directory.

Since the order in which these configurations are applied does matter, the files
are numbered.

The configuration options are explained in the files comments


TCP Options
-----------

The file
:download:`/etc/nginx/http-conf.d/10_tcp-options.conf </server/config-files/etc/nginx/http-conf.d/10_tcp-options.conf>`
contains optimizations on the TCP/IP network level.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/10_tcp-options.conf
    :language: nginx
    :linenos:


HTTPS Options
-------------

The file
:download:`/etc/nginx/http-conf.d/20_https-options.conf </server/config-files/etc/nginx/http-conf.d/20_https-options.conf>`
for global SSL/TLS settings.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/20_https-options.conf
    :language: nginx
    :linenos:


Limits
------

The file
:download:`/etc/nginx/http-conf.d/20_limits.conf </server/config-files/etc/nginx/http-conf.d/20_limits.conf>`
can be used to set various network related limitations, like number of allowed
connections per IP address  or various buffer sizes. At this time we limit
connections only and stick with  Nginx default values for the rest.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/20_limits.conf
    :language: nginx
    :linenos:


Character-Sets and MIME-Types
-----------------------------

The file
:download:`/etc/nginx/http-conf.d/30_charsets.conf </server/config-files/etc/nginx/http-conf.d/30_charsets.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/30_charsets.conf
    :language: nginx
    :linenos:


HTTP Server Security
--------------------

We group settings who affect the global HTTP server security in the file
:download:`/etc/nginx/http-conf.d/30_http-server-security.conf </server/config-files/etc/nginx/http-conf.d/30_http-server-security.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/30_http-server-security.conf
    :language: nginx
    :linenos:

There will be more security settings in the individual virtual hosts later on.


Logging
-------

Format
^^^^^^

This sets the pretty much standard log format for websites.

Note that we don't set *what* will be logged here in any way, but only *how* and
*where*. More on this will follow later on.

File:
:download:`/etc/nginx/http-conf.d/40_log-format.conf </server/config-files/etc/nginx/http-conf.d/40_log-format.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/40_log-format.conf
    :language: nginx
    :linenos:


Don't Log Anything
^^^^^^^^^^^^^^^^^^

File:
:download:`/etc/nginx/http-conf.d/50_no-log.conf </server/config-files/etc/nginx/http-conf.d/50_no-log.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/50_no-log.conf
    :language: nginx
    :linenos:


Compression
-----------

Brötli Compression
^^^^^^^^^^^^^^^^^^

The file :download:`/etc/nginx/http-conf.d/60_compression_brotli.conf </server/config-files/etc/nginx/http-conf.d/60_compression_brotli.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/60_compression_brotli.conf
    :language: nginx
    :linenos:

GZip Compression
^^^^^^^^^^^^^^^^

The file :download:`/etc/nginx/http-conf.d/60_compression_gzip.conf </server/config-files/etc/nginx/http-conf.d/60_compression_gzip.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/60_compression_gzip.conf
    :language: nginx
    :linenos:


Open Files Cache
----------------

In the file
:download:`/etc/nginx/http-conf.d/60_open-file-cache.conf </server/config-files/etc/nginx/http-conf.d/60_open-file-cache.conf>`
we set how Nginx can cache files it has opened already to save disk operations
while serving requests.

 Configures a cache that can store:

 * open file descriptors, their sizes and modification times;
 * information on existence of directories;
 * file lookup errors, such as “file not found”, “no permission”, and so on.

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/60_open-file-cache.conf
    :language: nginx
    :linenos:


PHP Backend
-----------

The file :download:`/etc/nginx/http-conf.d/70_php-backend.conf </server/config-files/etc/nginx/http-conf.d/70_php-backend.conf>`

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/70_php-backend.conf
    :language: nginx
    :linenos:


FastCGI Cache
-------------

The file :download:`/etc/nginx/http-conf.d/90_fastcgi_cache.conf </server/config-files/etc/nginx/http-conf.d/90_fastcgi_cache.conf>`

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/90_fastcgi_cache.conf
    :language: nginx
    :linenos:


Tor Exit Nodes
--------------

The file :download:`/etc/nginx/http-conf.d/90_tor-exits-map.conf </server/config-files/etc/nginx/http-conf.d/90_tor-exits-map.conf>`

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/90_tor-exits-map.conf
    :language: nginx
    :linenos:


Default Server
--------------

The file :file:`/etc/nginx/conf.g/default.conf` is installed with Nginx and
usually serves a test page to show that the installation has been successful and
the server is working.

However this should be changed immediately to something more useful and secure.

First I like to rename it to make its purpose easier recognizable::

    $ sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/http-conf.d/99_default-site.conf

Then edit
:download:`/etc/nginx/http-conf.d/99_default-server.conf </server/config-files/etc/nginx/http-conf.d/99_default-server.conf>`
as follows:

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/99_default-server.conf
    :language: nginx
    :linenos:

This "website" has only one purpose. Immediately closing any connections
made to it. Whatever is connecting to your IP address with HTTP or HTTPS, but
does not know the name of any website actually hosted here (like www.example.net)
can safely be assumed to be either a malicious bot or a script kiddie probing
for security holes.

The certificate and key defined here, need not to be valid, as normal clients
will never connect here.
