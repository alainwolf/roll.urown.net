Pyzor
=====

Pyzor is a collaborative, networked system to detect and block spam using
digests of messages.

Using Pyzor client a short digest is generated that is likely to uniquely
identify the email message. This digest is then sent to a Pyzor server to:

* check the number of times it has been reported as spam or whitelisted as
  not-spam
* report the message as spam
* whitelist the message as not-spam

Since the entire system is released under the GPL, people are free to host their
own independent servers.

There is, however, a well-maintained and actively used public server available
(courtesy of SpamExperts) at:

.. code-block:: text

    public.pyzor.org:24441


Installation
------------

Pyzor is installed from the Ubuntu software repository::

    $ sudo apt install pyzor


Pyzor Home Directory
--------------------

Since we will run the Pyzor service by the **_rspamd** user-profile, we have to
create the Pyzor home directory::

    $ sudo -u _rspamd mkdir /var/lib/rspamd/.pyzor


Systemd Configuration
---------------------

Socket File
^^^^^^^^^^^

Create a new Systemd socket file :file:`/etc/systemd/systemd/pyzor.socket`:

.. code-block:: ini

    [Unit]
    Description=Pyzor socket

    [Socket]
    ListenStream=127.0.0.1:5953
    Accept=yes

    [Install]
    WantedBy=sockets.target


Service File
^^^^^^^^^^^^

Create a new Systemd service file :file:`/etc/systemd/system/razor@.service`:

.. code-block:: ini

    [Unit]
    Description=Pyzor Socket Service
    Requires=pyzor.socket

    [Service]
    Type=simple
    ExecStart=-/usr/bin/pyzor check
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
    $ sudo systemctl enable pyzor.socket
    $ sudo systemctl start pyzor.socket

References
----------

See :doc:`/server/mail/rspamd` for the Integration with our spam filter.
