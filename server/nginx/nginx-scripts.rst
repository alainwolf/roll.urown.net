Nginx Scripts and Tools
=======================

We use the following scripts for various tasks related to our web server. Most
of them are run fully automated and regularly as cron jobs on the server, while
others are called on demand.

Static Compression
------------------

Nginx can be set to serve pre-compressed versions of static files like HMTL-
files, CSS stylesheets, script-files. etc. instead of compressing them on-the-
fly while sending them to clients.

The following script will try to find static files in the website and pre-
compress them for Nginx to to send out.

.. literalinclude:: /server/scripts/nginx_pre_compress
    :language: sh
    :linenos:


OCSP Staples
------------

.. literalinclude:: /server/scripts/nginx_ocsp_staples
    :language: sh
    :linenos:



TLS Session Key Rotation
------------------------

.. literalinclude:: /server/scripts/nginx_session_keys
    :language: sh
    :linenos:


Tor Exit Nodes
--------------

.. literalinclude:: /server/scripts/nginx_tor_exit_nodes
    :language: sh
    :linenos:


Connect Servers
---------------

.. literalinclude:: /server/scripts/nginx_connect_servers
    :language: sh
    :linenos:

