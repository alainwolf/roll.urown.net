MariaDB System Service
======================

Wait for VPN
------------

Since we use our :doc:`Wireguard VPN </server/wireguard>` for
:doc:`database replication <replication>` between our servers, and set MariaDB
to listen on the Wireguard network interface for incoming connections, we have
to make sure that Wireguard VPN is up and ready before the MariaDB database
server is started.

The Systemd services file for the MariaDB database server
:file:`/lib/systemd/system/mariadb.service` is created as part of the software
package installation. The recommended method is to create a Systemd
override-file and not change anything in the provided service file, as it
would be lost on software package updates.

You can create a override file easily with the help of the
:command:`systemctl` command::

    $ sudo systemctl edit mariadb.service

This will start your editor with an empty file, where you can add your own
custom Systemd service configuration options.

.. code-block:: ini

    [Unit]
    After=sys-devices-virtual-net-wg0.device unbound.service
    BindsTo=sys-devices-virtual-net-wg0.device


The line :code:`After=sys-devices-virtual-net-wg0.device` ensures that the
:code:`wg0` VPN network interface is up before the :code:`mariadb.service` is
started.

The line :code:`BindsTo=wg0` ensures that if the WireGuard network interface
goes down , the MariaDB database server will be stopped too.

After you save and exit of the editor, the file will be saved as
:file:`/etc/systemd/system/mariadb.service.d/override.conf` and Systemd will
reload its configuration.


References
----------

`systemd.unit — Unit configuration <https://www.freedesktop.org/software/systemd/man/systemd.unit.html>`_
