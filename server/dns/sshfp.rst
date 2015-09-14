Publish SSH Server Keys
^^^^^^^^^^^^^^^^^^^^^^^

By publishing you SSH server public keys on DNS, connecting clients can verify
the server identity without the need to distribute and update your server public
keys on all clients.

.. note::

    You need to already have setup a DNSSEC secured DNS server for the servers
    domain. See :doc:`/server/dns/powerdns` and :doc:`/server/dns/dnssec`.

::

    sshfp -s server.example.com
    # server.example.com SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2
    server.example.com IN SSHFP 1 1 5E677..............................21447


If you use PowerDNS server with the poweradmin web interface, add records as
follows:

===================== ===== ============================================
Name                  Type  Content                                                               
===================== ===== ============================================
server.example.com    SSHFP 1 1 5E677..............................21447
===================== ===== ============================================
