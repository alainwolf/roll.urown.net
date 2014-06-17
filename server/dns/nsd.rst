:orphan:

Domain Name Server - Alternative
================================

`NSD Domain Server <https://www.nlnetlabs.nl/projects/nsd/>`_ is an 
authoritative only, high performance, simple and open source name server.

Planning
--------

Prerequisites
-------------

IP Addresses
^^^^^^^^^^^^

Firewall-Gateway
^^^^^^^^^^^^^^^^


Software Installation
---------------------

NSD is in the Ubuntu software packages repository.

.. note::
    As of |today| there is an 
    `issue <https://bugs.launchpad.net/ubuntu/+source/nsd/+bug/1311886>`_ 
    with the installation package of **NSD**. The installation appears to fail, 
    as the service can't be started. As a work-around, create the user and group 
    **nsd** *before* starting the installation.

::
    
    $ sudo adduser --system --group --no-create-home --home /etc/nsd nsd
    $ sudo apt-get install nsd

The installation does the following

 * A configuration directory structure :file:`/etc/nsd/` with ...

   * The main configuration file :file:`/etc/nsd/nsd.conf`
   * Private key and certificate called nsd_control in PEM format.
   * Private key and certificate called nsd_server in PEM format.
   * The subdirectory :file:`/etc/nsd/nsd.conf.d` to include additional
     configuration files.
 
 * A directory :file:`/var/lib/nsd` owned by **root** for storing dynamically 
   added zones, the database :file:`/var/lib/nsd/nsd.db`, the transfer state 
   file :file:`var/lib/nsd/xfrd.state`.
 * A directory :file:`/var/lib/nsddb/` owned by root containing various 
   :file:`*.db` and one :file:`pcks11.txt` files.
 * The Ubunntu Upstart job configuration :file:`/etc/init/nsd.conf` is created 
   and the job started.
 * There is also a system service script :file:`/etc/init.d/nsd` created. But 
   it starts only if no running Ubuntu Upstart job is detected.


Server Configuration
--------------------

The main configuration file :file:`/etc/nsd/nsd.conf` installed is emtpy. But a
sample configuration files :file:`/usr/share/doc/nsd/examples/nsd.conf.gz` is 
provided in compressed format. To read it one can use the following command::

  $ zless /usr/share/doc/nsd/examples/nsd.conf.gz

Additionally there is a manpage :manpage:`nsd.conf(5)` and the official online 
documentation 


.. code-block:: text
    :linenos:


Monitoring
----------

.. todo:: *Add log files to monitor*
    

.. todo::
   This function is not suitable for sending spam e-mails.

Backup Considerations
---------------------

.. coming soon
