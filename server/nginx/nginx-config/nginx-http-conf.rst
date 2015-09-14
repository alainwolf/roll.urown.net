Default HTTP Settings
=====================

Following are the global HTTP server settings loaded from the
:file:`/etc/nginx/conf.d/` directory.


Character-Sets and MIME-Types
-----------------------------

The :file:`/etc/nginx/conf.d/charsets.conf`.

A downloadable version is available 
:download:`here <config-files/conf.d/charsets.conf>`

.. literalinclude:: config-files/conf.d/charsets.conf
    :language: nginx
    :linenos:


HTTP Server Security
--------------------

We group settings who affect the global HTTP server security in the file 
:download:`/etc/nginx/conf.d/http-security.conf 
<config-files/conf.d/http-security.conf>`.

.. literalinclude:: config-files/conf.d/http-security.conf
    :language: nginx
    :linenos:

There will be more security settings in the individual virtual hosts later on.


Limits
------

The file :file:`/etc/nginx/conf.d/limits.conf` can be used to set various 
network related limitations, like number of allowed connections per IP address 
or various buffer sizes. At this time we limit connections only and stick with 
Nginx default values for the rest.

A downloadable version is available 
:download:`here <config-files/conf.d/limits.conf>`

.. literalinclude:: config-files/conf.d/limits.conf
    :language: nginx
    :linenos:


Logging
-------

This sets the pretty much standard log format for websites. 

Note that we don't set *what* will be logged here in any way, but only *how* and
*where*. More on this will follow later on.

File: 
:download:`/etc/nginx/conf.d/log-format.conf <config-files/conf.d/log-format.conf>`.


.. literalinclude:: config-files/conf.d/log-format.conf
    :language: nginx
    :linenos:


Open Files Cache
----------------

In the file  
:download:`/etc/nginx/conf.d/open-file-cache.conf <config-files/conf.d/open-file-cache.conf>` 
we set how Nginx can cache files it has opened already to save disk operations
while serving requests.

 Configures a cache that can store:

 * open file descriptors, their sizes and modification times;
 * information on existence of directories;
 * file lookup errors, such as “file not found”, “no permission”, and so on. 

.. literalinclude:: config-files/conf.d/open-file-cache.conf
    :language: nginx
    :linenos:


TCP Options
-----------

The file 
:download:`/etc/nginx/conf.d/tcp-options.conf <config-files/conf.d/tcp-options.conf>` 
contains some optimizations on the TCP/IP network level.

.. literalinclude:: config-files/conf.d/tcp-options.conf
    :language: nginx
    :linenos:


Default Server
--------------

The file :file:`/etc/nginx/conf.g/default.conf` is installed with Nginx and
usually serves a test page to show that the installation has been successful and
the server is working.

However this should be changed immediately to something more useful and secure.

First I like to rename it to make its purpose easier recognizable::

    $ sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default-server.conf

Then edit 
:download:`/etc/nginx/conf.d/default-server.conf 
<config-files/conf.d/default-server.conf>` 
as follows:

.. literalinclude:: config-files/conf.d/default-server.conf
    :language: nginx
    :linenos:

This "website" has only one purpose. Immediately closing any connections
made to it. Whatever is connecting to your IP address with HTTP or HTTPS, but
does not know the name of any website actually hosted here (like www.example.com)
can safely be assumed to be either a malicious bot or a script kiddie probing
for security holes.

The certificate and key defined here, need not to be valid, as normal clients
will never connect here.
