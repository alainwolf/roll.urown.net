Redis
=====

.. image:: redis-logo.*
    :alt: Redis Logo
    :align: right

`Redis <https://redis.io/>`_ is a fast and persistent key-value database with
a network interface.

As a key-value database it is similar to :term:`Memcache` but the
dataset is not only stored entirely in memory but periodically flushed to
disk. This way the dataset remains persistent across restarts and is no longer
only volatile.

It supports many kind of data structures such as strings, hashes, lists, sets,
sorted sets with range queries, bitmaps and more.

It has built-in replication, :term:`LUA` scripting, :term:`LRU` eviction,
transactions and different levels of on-disk persistence, and provides high
availability via Redis Sentinel and automatic partitioning with Redis Cluster.


Topology
--------

The following server applications in our environment, use Redis to store and
retrieve data fast in memory:

 #. :doc:`mail/rspamd` for ...
    * Ratelimit plugin uses Redis to store limits buckets;
    * Greylisting module stores data and meta hashes inside Redis;
    * DMARC module can save DMARC reports inside Redis keys;
    * Replies plugin requires Redis to save message ids hashes for outgoing messages;
    * IP score plugin uses Redis to store data about AS, countries and networks reputation;
    * Multimap module can use Redis as readonly database for maps;
    * MX Check module uses Redis for caching;
 #. :doc:`mail/rspamd` statistics module to store Bayes tokens;
 #. :doc:`mail/rspamd` storage for fuzzy hashes;
 #. Postfix TLS policies of domains who publish a :doc:`/server/mail/mta-sts` policy;
 #. :doc:`nextcloud-server` for transactional file locking;

For Rspamd we set up a master/slave replication. This way all mail servers can
share their knowledge about connecting SMTP servers and spaminess of messages.

The mail server will act as master, while the the remote MX hosts will act as
slaves::


               +------------------+
               |    Charlotte     |
               |  (Redis Master)  |
               |    Nextcloud     |
               |    Postfix       |
               |    Dovecot       |
               |    Rspamd        |
               +------------------+
                  |             |
                  |             |
      +-----------------+  +-----------------+
      |     Dolores     |  |      Maeve      |
      |  (Redis Slave)  |  |  (Redis Slave)  |
      |     Postfix     |  |     Postfix     |
      |     Rspamd      |  |     Rspamd      |
      +-----------------+  +-----------------+


========= ====== ================ =========================
Host      Role   IPv4 VPN Address IPv6 VPN Address
========= ====== ================ =========================
Charlotte Master 10.195.171.241   fdc1:d89e:b128:6a04::29ab
Dolores   Slave  10.195.171.142   fdc1:d89e:b128:6a04::7de4
Maeve     Slave  10.195.171.47    fdc1:d89e:b128:6a04::961
========= ====== ================ =========================


It is strongly recommended  `not to share
<https://stackoverflow.com/questions/10644158/multiple-redis-instances?rq=1>`_
a Redis database among different applications and although Redis has limited
support for multiple databases, it is also strongly recommended by its author
not to use this feature. Instead one should run a dedicated instance of Redis
with a single dedicated database for every application.

Considering our list of applications above, we need five Redis instances, of
which four are gonna to be replicated across three servers. A total of 13
instances to setup across all servers.

=========================== ============ ======== =================
Application                 Instance     TCP Port Mode of Operation
=========================== ============ ======== =================
Nextcloud Server            nextcloud    6380     Standalone
Rspamd                      rspamd       6381     Master/Slave
Rspamd Statistics Module    rspamd-bayes 6382     Master/Slave
Rspamd Fuzzy Storage Worker rspamd-fuzzy 6383     Master/Slave
Postfix MTA-STS TLS policy  postfix-tls  6384     Master/Slave
=========================== ============ ======== =================


Prerequisites
-------------


WireGuard VPN
^^^^^^^^^^^^^

The data stored in Redis by Rspamd will be replicated across remote connected
servers. Since Redis does not provide any security by itself, we use
:doc:`wireguard` connections between the masters and slaves.


System Control
^^^^^^^^^^^^^^

Background saves might fail under low memory conditions. It therefore might
help to tell Linux to allocate memory more aggressively::

    $ sudo sysctl vm.overcommit_memory=1


To make this persistent across reboots::

    $ echo "vm.overcommit_memory=1" | sudo tee /etc/sysctl.d/60-overcommit-mem.conf
    $ sudo systemctl restart procps.service


Kernel Configuration
^^^^^^^^^^^^^^^^^^^^

The Linux Kernel feature "Transparent Huge Pages (THP)" has negative effects
on memory usage and latency of Redis. Therefore it should be disabled::

    $ echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled


Installation
------------

Redis is installed from packages::

    $ sudo apt install redis-server


Configuration
-------------

Redis configuration is stored in :file:`/etc/redis.conf`.  Most of the
settings can be left at their default. We use a :file:`include` statement to
add the small number of settings which sets each instance apart.


Common Configuration
^^^^^^^^^^^^^^^^^^^^

In the file :file:`/etc/redis/common.conf` we set all the default settings,
which are common to all of our Redis instances. This file can then be included
on each instance configuration file, which keeps the whole thing more
manageable and less cluttered.

We use the default file as template::

    $ sudo mv /etc/redis/redis.conf /etc/redis/common.conf

.. note::

    Make sure the file-name **does not** contain the string **redis**, because
    if it does, **systemd** will try to start an instance with this file as
    configuration.

Things to do here:

 * Comment out any "bind" statements, as they are defined in the instance configuration files;
 * Comment out any "unixsocket" statements.
 * Turn off protected mode, as we will use networking and password protection later;

::

    #bind 127.0.0.1 ::1


::

    # unixsocket /var/run/redis/redis-server.sock
    # unixsocketperm 700


::

    protected-mode no



Nextcloud Standalone Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set localhost address and TCP port;
 * Set a password for the local client(s);

Create a password for Nextcloud::

    $ pwgen --secure 32 1
    Wk7H302Kx4JxW0Beb2WIcvHbLbpRnkse


:download:`/etc/redis/redis-nextcloud.conf <config-files/etc/redis/redis-nextcloud.conf>`:

.. literalinclude:: config-files/etc/redis/redis-nextcloud.conf
    :language: bash


Rspamd Master Instance
^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set a password for slaves and local clients;

Create a password for Rspamd::

    $ pwgen --secure 32 1
    CyJGIROS8CA15qITGd1vZKsPQb6ESwYV


:download:`/etc/redis/redis-rspamd.conf <config-files/etc/redis/redis-rspamd.conf>`:

.. literalinclude:: config-files/etc/redis/redis-rspamd.conf
    :language: bash


Rspamd Slave Instance
^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set password for local clients;
 * Set address of the master;
 * Set password to access the master;

:download:`/etc/redis/redis-rspamd.conf <config-files/etc/redis/redis-rspamd-slave.conf>`:

.. literalinclude:: config-files/etc/redis/redis-rspamd-slave.conf
    :language: bash


Rspamd Bayesian Master Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set a password for slaves and local clients;

Create a password for Rspamd::

    $ pwgen --secure 32 1
    WRTgpIv6Xz6i7lNNMQ13bijAj5ghPR7p


:download:`/etc/redis/redis-rspamd-bayes.conf <config-files/etc/redis/redis-rspamd-bayes.conf>`:

.. literalinclude:: config-files/etc/redis/redis-rspamd-bayes.conf
    :language: bash


Rspamd Bayesian Slave Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set password for local clients;
 * Set address of the master;
 * Set password to access the master;

:download:`/etc/redis/redis-rspamd-bayes.conf <config-files/etc/redis/redis-rspamd-bayes-slave.conf>`:

.. literalinclude:: config-files/etc/redis/redis-rspamd-bayes-slave.conf
    :language: bash


Postfix MTA-STS TLS Master Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set password for local clients;
 * Set address of the master;
 * Set password to access the master;

Create a password for Postifx::

    $ pwgen --secure 32 1
    ZlsQPlZAwMRpBgzEvwH2J7jsWkcpC7Xr

:download:`/etc/redis/redis-postfix-tls.conf <config-files/etc/redis/redis-postfix-tls.conf>`:

.. literalinclude:: config-files/etc/redis/redis-postfix-tls.conf
    :language: bash


Postfix MTA-STS TLS Slave Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Things to do here:

 * Common configuration include statement;
 * Set memory limit;
 * Set Wireguard VPN interface address and TCP port;
 * Set password for local clients;
 * Set address of the master;
 * Set password to access the master;

:download:`/etc/redis/redis-postfix-tls.conf <config-files/etc/redis/redis-postfix-tls-slave.conf>`:

.. literalinclude:: config-files/etc/redis/redis-postfix-tls-slave.conf
    :language: bash


Systemd Services
^^^^^^^^^^^^^^^^

Systemd has a built in support to automatically start multiple instances of a
service. This needs only a couple of small changes in the service file.

Make a copy of the pre-installed service file :file:`/lib/systemd/system/redis-server@.service`::

    $ sudo cp /lib/systemd/system/redis-server@.service /etc/systemd/system/


.. note::

    On some systems I discovered an additional service file
    :file:`/etc/systemd/system/redis.service`. Please remove it, if that's the
    case.


Edit the file :file:`/etc/systemd/system/redis-server@.service`, as follows:

.. literalinclude:: config-files/etc/systemd/system/redis-server@.service
    :language: ini


Since we don't use any clustering features of Redis, we can restrict the
systemd services a bit, by keeping the configuration read-only:

.. code-block:: ini

    # redis-server can write to its own config file when in cluster mode so we
    # permit writing there by default. If you are not using this feature, it is
    # recommended that you replace the following lines with "ProtectSystem=full".
    #ProtectSystem=true
    #ReadWriteDirectories=-/etc/redis
    ProtectSystem=full


If you do this, you have to make sure the configuration files always remain
readable by the **redis** user. I.e. after you edited the configuration files
as root::

    $ sudo chown -Rc redis:redis /etc/redis
    $ sudo systemctl daemon-reload
    $ sudo systemctl restart redis-server.service


References
----------

 * `Rspamd Replication in Redis <https://rspamd.com/doc/tutorials/redis_replication.html>`_
 * `Redis Configuration <https://redis.io/topics/config>`_
 * `Running Multiple Redis Instances <https://medium.com/@MauroMorales/running-multiple-redis-on-a-server-472518f3b603>`_
