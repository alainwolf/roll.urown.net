Rspamd Spam Filter
==================

.. image:: rspamd-logo.*
    :alt: Rspamd Logo
    :align: right
    :width: 200

.. contents::
    :local:

`Rspamd <https://www.rspamd.com/>`_ (Rapid spam filtering system) is a fast,
free and open-source spam filtering system.


Topology
--------

In this example we run 3 mail servers.

.. code-block:: text

               +-------------------+
               |  Charlotte (MAS)  |
               |                   |
               |    Postfix        |
               |    Dovecot        |
               |    Rspamd         |
               +-------------------+
                  |             |
                 VPN           VPN
                  |             |
    +----------------+       +----------------+
    |  Dolores (MX)  |       |   Maeve (MX)   |
    |                |       |                |
    |    Postfix     |--VPN--|    Postfix     |
    |    Rspamd      |       |    Rspamd      |
    +----------------+       +----------------+


Mail Access Server (MAS)
^^^^^^^^^^^^^^^^^^^^^^^^

**Charlotte**, in our home network, is where our mailboxes are stored and
where mail clients connect to.

Rspamd on **Charlotte** scans outgoing mails for viruses, increases user
privacy (by removing user-agent and client IP address from the mail-headers)
and signs outgoing mail with :term:`DKIM` and possibly :term:`ARC`.

Users can also train the filters from within there mail account on
**Charlotte**, by moving mail in to "ham" and "spam" folders, where Rspamd
will pick them up, analyze the contents and use it to increase its accuracy in
classifying mails as spam or ham in the future.


Mail Exchangers (MX)
^^^^^^^^^^^^^^^^^^^^

**Dolores** and **Maeve**, running on cheap cloud hosting providers outside of
our home network, are the :term:`MX` hosts responsible for receiving incoming
mails for our domains. With Rspamd installed there, incoming mail is analyzed
at the edge and can be rejected if it is unsolicited, unwanted or dangerous
before entering our network.


========= ======= ================ =========================
Host      Role    IPv4 VPN Address IPv6 VPN Address
========= ======= ================ =========================
Charlotte MAS     10.195.171.241   fdc1:d89e:b128:6a04::29ab
Dolores   MX      10.195.171.142   fdc1:d89e:b128:6a04::7de4
Maeve     MX      10.195.171.47    fdc1:d89e:b128:6a04::961
========= ======= ================ =========================


The 3 instances of Rspamd share their knowledge and experience about good and
bad messages, senders, hosts and networks by storing nearly every bit of data
they gather in the Redis key-value database, which is then replicated between
them over encrypted VPN connections.

They also provide fail-over services for each other in the event of a outage.


Prerequisites
-------------

 * :doc:`/server/dns/unbound`
 * :doc:`/server/wireguard`
 * :doc:`/server/redis`


Installation
------------

Rspamd is not available in the Ubuntu packages repository, but the Rspamd
project
`provides its own software package repository <https://www.rspamd.com/downloads.html>`_
for various Linux and BSD UNIX distributions::

    $ wget -O- https://rspamd.com/apt-stable/gpg.key | sudo apt-key add -
    $ echo "deb [arch=amd64] https://rspamd.com/apt-stable/ $(lsb_release -c -s) main" \
        > /etc/apt/sources.list.d/rspamd.list
    $ echo "deb-src [arch=amd64] https://rspamd.com/apt-stable/ $(lsb_release -c -s) main" \
        >> /etc/apt/sources.list.d/rspamd.list
    $ apt-get update
    $ apt-get --no-install-recommends install rspamd


Configuration
-------------

After the installation, a lot of configuration files are found in
:file:`/etc/rspamd`.

These configuration files use the
`Universal Configuration Language (UCL) <https://www.rspamd.com/doc/configuration/ucl.html>`_.
The syntax is somewhat similar to Nginx and JSON.

The installed configuration files are not intended to be changed by the user,
rather they should be extended with your own files in the directory
:file:`/etc/rspamd/local.d` or overridden with files in the directory
:file:`/etc/rspamd/override.d`. files. This structure ensures seamless
upgrades, if any default value changes or new options are introduces by new
versions of Rspamd.

Rspamd consists of multiple `workers <https://rspamd.com/doc/workers/>`_ and
`modules <https://rspamd.com/doc/modules/>`_, each of which can be enabled or
disabled and configured according to ones needs and topology.


Options
^^^^^^^

:download:`/etc/rspamd/local.d/options.inc </server/config-files/etc/rspamd/options.inc>`:

.. literalinclude:: /server/config-files/etc/rspamd/options.inc
    :language: nginx


Workers
-------


Proxy Worker
^^^^^^^^^^^^

The `proxy worker <https://rspamd.com/doc/workers/rspamd_proxy.html>`_
interacts with the MTA (postfix) via the :term:`milter` protocol.

As a new message arrives, the MTA hands the mail over to the Rspamd proxy for
scanning. The Rspamd proxy passes the message on to a Rspamd scanner (normal
worker). Multiple scanners can be defined for fail-over or load-balancing
purposes.

We define the locally running Rspamd scanner as default scanner and scanners
running on other servers as remote fail-overs.

The proxy by itself listens on localhost only, since the local postfix MTA is
the only instance connecting here.

The proxy worker listens on TCP port **11332**.

Create or modify the file :download:
`/etc/rspamd/local.d/worker-proxy.inc </server/config-files/etc/rspamd/worker-proxy.inc>`:

.. literalinclude:: /server/config-files/etc/rspamd/worker-proxy.inc
    :language: nginx


Normal Worker
^^^^^^^^^^^^^

The `normal worker <https://rspamd.com/doc/workers/normal.html>`_ is the
daemon process, which does the scanning. Its configuration is rather simple.

Apart from "localhost", this workers also listens to the Wireguard VPN
interface for incoming connections. With this other mail servers Rspamd proxy
workers, can use this scanner as fail-over.

The normal worker listens on TCP port **11333**.

Create or modify the file
:download:
`/etc/rspamd/local.d/worker-normal.inc </server/config-files/etc/rspamd/worker-normal.inc>`:

.. literalinclude:: /server/config-files/etc/rspamd/worker-normal.inc
    :language: nginx



Controller Worker
^^^^^^^^^^^^^^^^^

The `controller worker <https://rspamd.com/doc/workers/controller.html>`_ is
used to manage rspamd stats, to learn rspamd and to serve WebUI.

The controller worker listens on TCP port **11334**.

Some operations available on the WebUI might change configuration values or
data of the Rspamd environment. Password protection is therefore recommended.
To generate a password use the following command::

    $ pwgen --secure 32 1
    86lucpetQ6V8B4dYbsIERC5T0owOvUZ7

The password is to be stored as :term:`cryptographic hash <Cryptographic Hash
Function>` in the configuration file. Rspamd provides a utility to safely
generate the hash::

    $ rspamadm pw
    Enter passphrase: ********************************
    $2$ozqwiewyd5uym7cdbr7jo6xxg8yuqsee$sk4h4y6geqmqzqo15d6zfti8q5x8cxrnjbbngsrfqd999je95ddy


Create or modify the file
:download:`/etc/rspamd/local.d/worker-controller.inc </server/config-files/etc/rspamd/worker-controller.inc>`:

.. literalinclude:: /server/config-files/etc/rspamd/worker-controller.inc
    :language: nginx


Fuzzy Storage Workers
^^^^^^^^^^^^^^^^^^^^^

`Fuzzy hashes <https://rspamd.com/doc/modules/fuzzy_check.html>`_ are used by
Rspamd to find similar messages. Unlike normal hashes, these structures are
targeted to hide small differences between text patterns allowing to find
common messages quickly.

Rspamd uses the
`fuzzy storage worker <https://rspamd.com/doc/workers/fuzzy_storage.html>`_
to store these hashes and allows to block spam mass mails based on user’s
feedback that specifies message reputation.

We will store the data for this worker in :doc:`/server/redis`.

The fuzzy storage worker listens on UDP port **11335**.

The Fuzzy Storage Worker follows a Master/Slave model. The data is created and
updated by the users on **Charlotte** while training the spam filter.

Later on this data is used by **Dolores** and **Maeve** for analysis when new
messages arrive there.

Another difference is that the Fuzzy Storage Worker is disabled by default and
has no default configuration. Therefore the configuration file is kept in the
:file:`/etc/rspamd.d/override.d` directory and not in
:file:`/etc/rspamd/local.d`


**Master**:

Create or modify the file
:download:`/etc/rspamd/override.d/worker-fuzzy.inc </server/config-files/etc/rspamd/worker-fuzzy.inc>`:

.. literalinclude:: /server/config-files/etc/rspamd/worker-fuzzy.inc
    :language: nginx


**Slaves**:

.. code-block:: nginx

    #
    # Fuzzy Storage Worker (slave)
    #
    # Stores fuzzy hashes of messages.
    #

    # number of worker instances to run
    count = 1; # Disabled by default

    # Localhost
    bind_socket = "127.0.0.1:11335";
    bind_socket = "[::1]:11335";

    # WireGuard
    bind_socket = "10.70.37.215:11335";
    bind_socket = "[fd24:20d2:519e:94da:3a9b:18fd:1359:48d7]:11335";

    # Store the hashes in Redis
    backend = 'redis';

    # Allow master/slave updates from the following IP addresses
    masters = "";

    # Hosts that are allowed to perform changes to fuzzy storage
    allow_update = "";




Postfix Integration
-------------------


Dovecot Integration
-------------------


Nginx Integration
-----------------


Razor and Pyzor Integration
---------------------------

Create the :file:`/etc/rspamd/local.d/external_services.conf`

.. code-block::

    # default pyzor settings
    pyzor {
        servers = "127.0.0.1:5953"
    }

    # default razor settings
    razor {
        servers = "127.0.0.1:11342"
    }



Configuration Syntax Check
--------------------------

::

    $ rspamadm configtest
    syntax OK


Systemd Service Dependencies
----------------------------

Since our Rspamd server we use various Redis databases to store data, we want
the Redis cache to be up and running, before the Rspamd service starts. To make
the `rspamd.service` dependent on the `redis-server@rspamd.service`, the
`redis-server@rspamd-bayes.service` and the
`redis-server@rspamd-fuzzy.service`.

You can create a Systemd override file easily with the help of the
:command:`systemctl` command::

    $ sudo systemctl edit rspamd.service

This will start your editor with an empty file, where you can add your own
custom Systemd service configuration options.

.. code-block:: ini

    [Unit]
    After=unbound.service
    After=redis-server@rspamd.service redis-server@rspamd-bayes.service redis-server@rspamd-fuzzy.service
    BindsTo=redis-server@rspamd.service redis-server@rspamd-bayes.service redis-server@rspamd-fuzzy.service

After you save and exit of the editor, the file will be saved as
:file:`/etc/systemd/system/rspamd.service.d/override.conf` and Systemd will
reload its configuration.


Reference
---------

 * `Rspamd Documentation <https://www.rspamd.com/doc/>`_

