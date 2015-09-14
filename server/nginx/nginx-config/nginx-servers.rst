Websites
========

Websites are defined in as "Servers" in Nginx and stored as configuration
files in the directory :file:`/etc/nginx/servers-available`. 

They are not loaded automatically. To activate a server a symbolic link in the
directory :file:`/etc/nginx/sites-enabled` is created (See line 46 in the main
configuration file :file:`nginx.conf`).

The only notable exception (the default server defined in
:file:`/etc/nginx/conf.d/default-server.conf` is always loaded).


Example Static Website
----------------------

Along the way trough this documentation we will define many more websites for
different purposes with a variating degree of complexity.

For the sake of a clear example, lets show a simple static website who just
serves HTML documents from the directory
:file:`/var/www/example.com/public_html/`.

.. literalinclude:: config-files/servers-available/example.com.conf
    :language: nginx
    :linenos:


Server Default Settings
^^^^^^^^^^^^^^^^^^^^^^^

Similar to the global HTTP settings, we have a set of default configuration
options for all our servers. By placing them in the directory 
:file:`/etc/nginx/servers-conf.d`, they can be included automatically.

.. literalinclude:: config-files/servers-available/example.com.conf
    :language: nginx
    :lines: 60-63

See :doc:`nginx-servers-conf` for the details.


TLS Settings
^^^^^^^^^^^^

Common settings which define how we handle HTTPS secured connections are defined
in the files :file:`/etc/nginx/tls.conf` and 
:file:`/etc/nginx/ocsp-stapling.conf`.

.. literalinclude:: config-files/servers-available/example.com.conf
    :language: nginx
    :lines: 52-55

See :doc:`nginx-tls-conf` for the details.

This does not include the certificates and keys itself, as each server may have
its own certificate. Also the HTTP header for Public-Key-Pinning (or HKP) is
derived from the private keys of the sever and must be set for every server
individually.

.. literalinclude:: config-files/servers-available/example.com.conf
    :language: nginx
    :lines: 56-59
