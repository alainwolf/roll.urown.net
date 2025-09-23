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

    $ cd /usr/local/src/dcc-2.3.169
    $ ./configure --with-64-bits --homedir=/var/lib/dcc --with-uid=_dcc \
        --bindir=/usr/local/bin --libexecdir=/usr/local/libexec/dcc \
        --disable-dccm --disable-server --disable-dccproc \
        --with-rundir=/run/dcc --enable-64-bits
    make
    sudo make install

Configuration
-------------



Main DCC Configuration
^^^^^^^^^^^^^^^^^^^^^^

Edit :file:`/var/lib/dcc/dcc_conf`::

    # from $Revision: 1.89 $
    DCC_CONF_VERSION=4

    # Don't set DCC_HOMEDIR since this file was found, it must have been already set
    # DCC_HOMEDIR=/var/lib/dcc

    # Directory where the DCC programs are installed
    DCC_LIBEXEC=/var/lib/dcc/libexec

    # Where to store pid (process id) files
    DCC_RUNDIR=/run/dcc

    # User id which runs the DCC server and clients
    DCCUID=_dcc

    # ---------------------------------------------------------
    # dccifd - The DCC Milter interface client for Postfix,
    # RSPAMD, SpamAssassin and other mail filters
    # https://www.dcc-servers.net/dcc/dcc-tree/dccifd.html
    # ---------------------------------------------------------

    # Enabled for Rspamd
    DCCIFD_ENABLE=on

    # Command-line arguments used when dccifd is started
    # Put greylist parameters in GREY_CLIENT_ARGS but not in DCCM_ARGS.

    # Either use local UNIX socket or IP address and port, not both

    # UNIX socket where dccifd listens requests
    #DCCIFD_ARGS="-p /run/dcc/dccifd.ascii-socket"

    # IP listening address and port and netmask for access control
    DCCIFD_ARGS="$DCCIFD_ARGS -p 10.70.37.217,10045,10.70.37.0/24"

    # UNIX socket for SMTP proxy mode, ddcifd sits in between SMTP client and server
    # instead of milter mode, where dccifd is called by the MTA
    # DCCIFD_ARGS="$DCCIFD_ARGS -o /run/dcc/dccifd.smtp-proxy-socket"

    # Only query for, but don't report any checksums
    # Mailservers not acting as MX should use this to avoid double-reporting.
    # DCCIFD_ARGS="$DCCIFD_ARGS -Q"

    # Name or path of the memory mapped parameter file. Default is /var/dcc/map
    # The map can be created with the cdcc(8) command.
    # If your mail system handles fewer than 100,000 mail messages per day, use the#
    # default /var/dcc/map file that points to the public DCC servers.
    # DCCIFD_ARGS="$DCCIFD_ARGS -m /var/dcc/map"

    # The log directories should be cleaned with the /var/lib/dcc/libexec/cron-dccd
    # nightly cron job.  DCCM_LOGDIR can start with D? H? or M? as in
    # DCCM_LOGDIR='D?log'  See -l in the man page.
    # Set DCCM_LOGDIR to the empty or null string to disable logging.
    DCCIFD_LOGDIR="D?log"

    # Optional file containing filtering parameters as well as SMTP client IP
    # addresses, SMTP envelope values, and header values of mail that is spam or is
    # not spam and does not need a X-DCC header, and whose checksums should not be
    # reported to the DCC server.
    DCCIFD_WHITECLNT=whiteclnt

    # Enables per-user whiteclnt files and log directories.
    # If both dccm and dccifd are used set different userdir files for each.
    DCCIFD_USERDIRS="/var/lib/dcc/userdirs.dccifd"

    # Set DCCIFD_LOG_AT to a number that determines "bulk mail" for your situation.
    # 50 is a typical value.
    DCCIFD_LOG_AT=50

    # Leave DCCIFD_REJECT_AT blank until you are confident that most sources of
    # solicited bulk mail have been whitelisted.
    # Then set it to the number that defines "bulk mail" for your site.
    # This rejection or "bulk" threshold does not affect the blacklisting of the
    # DCCM_WHITECLNT whitelist file.
    DCCIFD_REJECT_AT=

    # override basic list of checksums controlling rejections or logging
    DCCIFD_CKSUMS=

    # additional DCC server checksums worthy of rejections or logging
    DCCIFD_XTRA_CKSUMS=


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







