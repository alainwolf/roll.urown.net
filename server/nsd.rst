Domain Name Server
==================

`NSD Domain Server <https://www.nlnetlabs.nl/projects/nsd/>`_ is an 
authoritative only, high performance, simple and open source name server.


Software Installation
---------------------

NSD is in the Ubuntu software packages repository.

.. note::
    Currently there is an 
    `issue <https://bugs.launchpad.net/ubuntu/+source/nsd/+bug/1311886>`_ 
    with the installation package of **NSD**. The installation appears to fail, 
    as the service can't be started. As a work-around, create the user and group 
    **nsd** *before* starting the installation.

::
    
    $ sudo adduser --system --group --no-create-home --home /etc/nsd nsd
    $ sudo apt-get install nsd

The installation does the following

 * A configuration directory structure :file:`/etc/nsd/`.
 * The configuration structure in the :file:`/etc/nsd` directory contains:
    * The empty configuration file :file:`/etc/nsd/nsd.conf`
    * A pair of RSA private key and certificate called nsd_control in PEM format.
    * A pair of RSA private key and certificate called nsd_server in PEM format.
    * The directory :file:`/etc/nsd/nsd.conf.d`.
 * A directory :file:`/var/lib/nsd` owned by **root** for storing dynamically 
   added zones 
   :file:`/var/lib/nsd/nsd.db`.
 * A directory :file:`/var/lib/nsddb/` owned by root containing various 
`  :file:`*.db` and one `:file:pcks11.txt` files.
 * The Ubunntu Upstart job configuration :file:`/etc/init/nsd.conf` is created 
   and the job started.
 * A system service script :file:`/etc/init.d/nsd` is created. But its 
   configured no to start, if an already running Ubuntu Upstart Job is detected.


Server Configuration
--------------------

:file:`/etc/nsd/nsd.conf`

.. code-block:: text
    :linenos:


