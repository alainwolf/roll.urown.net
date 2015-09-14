Server Default Settings
=======================

In the example server defined earlier there is a **include** statement to load 
various settings, which every website should use for enhanced performance and 
security.

.. literalinclude:: config-files/servers-available/example.com.conf
    :language: nginx
    :lines: 60-63

.. note::

    Some web applications like ownCloud might provide their own settings which
    may duplicate or even conflict with some of the settings defined here. In
    this case only some of the configuration files might be included
    individually.


Browser Cache
-------------

The cache of our visitors web browsers is the best place to improve the website
performance for our visitors and reduce the load on our servers.

We use file 
:download:`/etc/nginx/server-defaults/client-cache.conf 
<config-files/server-defaults/client-cache.conf>` 
to control what and how long is cached by our visitors browser cache.

.. literalinclude:: config-files/server-defaults/client-cache.conf
    :language: nginx
    :linenos:


Compression
-----------

Another trick to save network traffic and increase speed is the server sending
compressed data to clients.

The file 
:download:`/etc/nginx/server-defaults/compression.conf 
<config-files/server-defaults/compression.conf>` 
to set what is to be compressed.

.. literalinclude:: config-files/server-defaults/compression.conf
    :language: nginx
    :linenos:


Server Security
---------------

In the file 
:download:`/etc/nginx/server-defaults/server-security.conf 
<config-files/server-defaults/server-security.conf>` 
we set various security related settings which every website should include..

.. literalinclude:: config-files/server-defaults/server-security.conf
    :language: nginx
    :linenos:

