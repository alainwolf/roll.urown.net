Razor
=====

`Vipul's Razor <http://razor.sourceforge.net/>`_ is a distributed,
collaborative, spam detection and filtering network. Through user contribution,
Razor establishes a distributed and constantly updating catalogue of spam in
propagation that is consulted by email clients to filter out known spam.
Detection is done with statistical and randomized signatures that efficiently
spot mutating spam content. User input is validated through reputation
assignments based on consensus on report and revoke assertions which in turn is
used for computing confidence values associated with individual signatures.


Installation
------------

Razor is installed from the Ubuntu software repository::

    $ sudo apt install razor


Systemd Configuration
---------------------

Socket File
^^^^^^^^^^^

Create a new Systemd socket file :file:`/etc/systemd/systemd/razor.socket`:

.. code-block:: ini

    [Unit]
    Description=Razor socket

    [Socket]
    ListenStream=127.0.0.1:11342
    Accept=yes

    [Install]
    WantedBy=sockets.target


Service File
^^^^^^^^^^^^

Create a new Systemd service file :file:`/etc/systemd/system/razor@.service`:

.. code-block:: ini

    [Unit]
    Description=Razor Socket Service
    Requires=razor.socket

    [Service]
    Type=simple
    ExecStart=/bin/sh -c '/usr/bin/razor-check && /bin/echo -n "spam" || /bin/echo -n "ham"'
    StandardInput=socket
    StandardError=journal
    TimeoutStopSec=10

    User=_rspamd
    NoNewPrivileges=true
    PrivateDevices=true
    PrivateTmp=true
    PrivateUsers=true
    ProtectControlGroups=true
    ProtectHome=true
    ProtectKernelModules=true
    ProtectKernelTunables=true
    ProtectSystem=strict

    [Install]
    WantedBy=multi-user.target


Reload and Start
^^^^^^^^^^^^^^^^

Reload the Systemd configuration and start the socket::

    $ sudo systemctl daemon-reload
    $ sudo systemctl enable razor.socket
    $ sudo systemctl start razor.socket


References
----------

See :doc:`/server/mail/rspamd` for the Integration with our spam filter.
