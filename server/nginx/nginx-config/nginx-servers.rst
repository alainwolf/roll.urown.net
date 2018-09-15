Virtual Web Servers
===================

.. contents::
  :local:

Websites are defined in as "Servers" in Nginx and stored as configuration
files in the directory :file:`/etc/nginx/servers-available`.

They are not loaded automatically. To activate a server a symbolic link in the
directory :file:`/etc/nginx/servers-enabled` is created (See the main
configuration file :file:`nginx.conf`).

The only notable exception (the default server defined in
:file:`/etc/nginx/http-conf.d/99_default-server.conf` is always loaded).


Example Static Website
----------------------

Along the way trough this documentation we will define many more websites for
different purposes with a variating degree of complexity.

For the sake of a clear example, lets show a simple static website who just
serves HTML documents from the directory
:file:`/var/www/example.net/public_html/`.

.. literalinclude:: /server/config-files//etc/nginx/servers-available/example.net.conf
    :language: nginx
    :linenos:


TLS Session Tickets Keys
^^^^^^^^^^^^^^^^^^^^^^^^

Every server needs its own set of TLS session keys. The session keys are to be
rotated every 12 hours, but remain valid for 36 hours.

As one might guess, we need a cron job.

tbd;




