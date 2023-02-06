UNIX Sockets & TCP/IP
=====================

.. note::

    Current versions of MariaDB and MySQL servers can be set to listen to either
    none, one single IP Address or all of them, regardless of IP version.

    So for a dual stacked host listening on IPv6 and IPv4, or a host which has
    to be reachable on the localhost/127.0.0.1 interface and a real network
    interface, the server must be set to listen on all interfaces. It can not be
    constrained to listen to e.g. localhost and one IP address. **Its either a
    single one or all of them**.


.. warning::

    Since the database server we will be open to connections from everywhere we
    have to ...

     * ... manage the access rights of our database server users extra
       carefully.

     * ... setup TLS/SSL certificates and keys for clients and server and setup the
       user profiles on the server accordingly.

     * ... set our firewall to block unwanted remote access.


Edit the relevant sections of the file
:download:`/etc/mysql/my.cnf </server/config-files/etc/mysql/mariadb.cnf>`
as follows:

.. literalinclude:: /server/config-files/etc/mysql/mariadb.cnf
    :language: ini
    :lines: 10,15-20,22,50-73
