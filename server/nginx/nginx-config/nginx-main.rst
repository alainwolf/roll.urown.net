Main Configuration File
=======================

The main configuration file is :download:`/etc/nginx/nginx.conf </server/config-files/etc/nginx/nginx.conf>`.

A downloadable version is available
:download:`here <config-files/nginx.conf>`

.. literalinclude:: /server/config-files/etc/nginx/nginx.conf
    :language: nginx
    :linenos:


If you don't set **worker_processes** to **auto** on line 13 above. You should
set it to the number of CPU cores of your server. To find out how many CPU cores
are  available, run the following command::

    $ cat /proc/cpuinfo | grep processor | wc -l
    2

The above configuration example will allow a maximum of 4,096 client connections
at the  any given time (2 CPU cores which will handle 2,048 connections each).
