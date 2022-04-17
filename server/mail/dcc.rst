Distributed Checksum Clearinghouse (DCC)
========================================

.. contents::
    :local:

`The Distributed Checksum Clearinghouses <https://www.dcc-servers.net/dcc/>`_ or
**DCC** is an anti-spam content filter that runs on a variety of operating
systems. The counts can be used by SMTP servers and mail user agents to detect
and reject or filter spam or unsolicited bulk mail. DCC servers exchange or
"flood" common checksums. The checksums include values that are constant across
common variations in bulk messages, including "personalizations."

Installation
------------

DCC is not available as package.

Download Source-Code::

    $ cd /usr/local/src
    $ wget https://www.dcc-servers.net/dcc/source/dcc.tar.Z
    $ tar xzvf dcc.tar.Z


Create a system user and group::

    $ sudo adduser --force-badname --system --group --home /var/lib/dcc _dcc

Build and install DCC. For a list of valid configuration parameters see
`this table <https://www.dcc-servers.net/dcc/INSTALL.html#envtbl>`_::

    $ cd /usr/local/src/dcc-2.3.168
    $ ./configure --with-64-bits --disable-dccm \
        --homedir=/var/lib/dcc --with-rundir=/run/dcc --with-uid=_dcc
    make
    sudo make install


Configuration
-------------



Main DCC Configuration
^^^^^^^^^^^^^^^^^^^^^^

Edit :file:`/var/lib/dcc/dcc_conf`::

    # GREY_ENABLE turns local greylist server 'on' or 'off',
    GREY_ENABLE=off

    DCCM_LOG_AT=NEVER
    DCCM_REJECT_AT=MANY

    DCCIFD_ENABLE=on
    DCCIFD_ARGS="-p /run/dcc/dccifd.ascii-socket -o /run/dcc/dccifd.smtp-proxy-socket"


Whitelists
^^^^^^^^^^


Public DCC Server List
^^^^^^^^^^^^^^^^^^^^^^


Firewall Rules
^^^^^^^^^^^^^^

DCC traffic is like DNS traffic. You should treat port 6277 like port 53. Allow
outgoing packets to distant UDP port 6277 and incoming packets from distant UDP
port 6277::

    $ sudo ufw allow proto udp from any to port 6277
    $ sudo ufw allow proto udp from port 6277 to any
    $ sudo ufw allow proto udp6 from any to port 6277
    $ sudo ufw allow proto udp6 from port 6277 to any

, then start the daemon by
running `/var/dcc/libexec/rcDCC start`.


Systemd Service
---------------

:file:`/etc/systemd/system/dcc.service`::

    [Unit]
    Description=DCC (Distributed Checksum Clearinghouses) interface daemon
    After=remote-fs.target systemd-journald-dev-log.socket

    [Service]
    Type=forking
    PermissionsStartOnly=true
    RuntimeDirectory=dcc
    ExecStart=/var/lib/dcc/libexec/dccifd
    User=_dcc
    Group=_dcc
    Nice=1

    #DCC writes pid file with "-" at the beginning which confuses systemd
    #PIDFile=/run/dcc/dccifd.pid

    [Install]
    WantedBy=multi-user.target


Cron Jobs
---------

Logfile maintenance
^^^^^^^^^^^^^^^^^^^


Database Pruning
^^^^^^^^^^^^^^^^


Updating DCC
------------







