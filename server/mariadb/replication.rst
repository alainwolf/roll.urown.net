Database Replication
====================

.. contents::
  :local:


In the following example we have MariaDB master server called "**Aiken**"[#f1]_
and a slave server called "**Gannibal**"[#f2]_.

The master is our home server located behind a router and firewall. He has a
private LAN IPv4 address (behind NAT with a dynamic public address) and a fixed
global IPv6 address.

The slave is a virtual server of a cloud provider at a remote data-center with a
direct Internet connection and a fixed public IPs for each IPv4 and IPv6.

Master and slave servers run MariaDB server version 10.2.x.

We will replicate the two **InnoDB** databases **pdns** and **vimbadmin**.

**pdns** is our :doc:`PowerDNS </server/dns/powerdns>` database so we don't rely
on :term:`AXFR` for updating our domain servers.

**vimbadmin** is contains our virtual mailboxes and aliases, so our
:doc:`/server/mail/postfix` can check incoming mail for valid recipients
addresses.

Since part of setup is to provide DNS services it must be itself independent
from any DNS address resolving. All connections use numerical IP addresses only.

Since the public IPv4 address can change anytime and can not be resolves trough DNS, we use IPv6 exclusively.

======== ========= ====== ====================
Name     Server-ID Role   Global IPv6
======== ========= ====== ====================
Aiken            1 Master 2001:db8:c0de::10
Gannibal         2 Slave  2001:db8:c1de::17
======== ========= ====== ====================


On the Master *Aiken*
---------------------


Setup Secure Connections
^^^^^^^^^^^^^^^^^^^^^^^^

See :doc:`tls`.


Setup Logging
^^^^^^^^^^^^^

See :doc:`log`.


Setup Binary Logging
^^^^^^^^^^^^^^^^^^^^

See :doc:`binlog`,


Setup as Replication Master
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create the file
:download:`/etc/mysql/conf.d/ReplicationMaster.cnf </server/config-files/etc/mysql/conf.d/ReplicationMaster.cnf>`
and set :file:`server-id` to **1** and :file:`report-host` to **Aiken**:

.. literalinclude:: /server/config-files/etc/mysql/conf.d/ReplicationMaster.cnf
    :language: ini


Restart the master for any of the above settings to take effect::

    $ sudo systemctl restart mariadb.service


Create Slave User Profiles
^^^^^^^^^^^^^^^^^^^^^^^^^^

Create random passwords for the slave users::

    $ pwgen -1 32 2
    ooPhujohJuC0booche4queewoh2noopa


Create the user profile for the slave on the master for incoming IPv4 and
IPv6 :doc:`/server/wireguard` connections, using the generated password above::

    $ mysql -u root -p


.. code-block:: sql

    GRANT REPLICATION SLAVE ON *.* TO 'gannibal'@'10.195.171.88'
        IDENTIFIED BY 'ooPhujohJuC0booche4queewoh2noopa';

    GRANT REPLICATION SLAVE ON *.* TO 'gannibal'@'dc1:d89e:b128:6a04::13a6'
        IDENTIFIED BY 'ooPhujohJuC0booche4queewoh2noopa';

    -- Reload the privileges table to make the changes active.
    FLUSH PRIVILEGES;
    exit


Export Databases
^^^^^^^^^^^^^^^^

.. warning::

    Note that the following procedure is specifically for **InnoDB** tables.
    *Don't do this at home* if your database uses any other storage engine.
    Consult the
    `MariaDB Knowledge Base <https://mariadb.com/kb/en/library/backup-restore-and-import-clients/>`_
    for the correct procedure with your setup.

Export the databases we want to to replicate with **mysqldump**::

    $ mysqldump -u root  -p \
        --databases pdns vimbadmin \
        --add-drop-database \
        --single-transaction --flush-logs \
        --master-data=1 --gtid \
            | gzip > ~/master_dump_$(date --utc +"%Y-%m-%d_%H-%M-%S-%Z").sql.gz


**mysqldump** reads one or more complete databases and exports the content in
SQL files. SQL files can be imported on any other server.

We use the following **mysqldump** command-line options:

 * :file:`--databases pdns vimbadmin` specifies the databases to export.

 * :file:`--add-drop-database` will add SQL statements to remove any
   pre-existing data with the same name on the slave server, to make sure that
   we have a clean slate before the data of the master is imported.

 * :file:`--single-transaction` acquires a global read lock on all tables (using
   FLUSH TABLES WITH READ LOCK) at the beginning of the dump. As soon as this
   lock has been acquired, the binary log coordinates are read and the lock is
   released.

 * :file:`--flush-logs` will make sure all data from masters binary logs and
   memory cache is safely stored before the data-dump begins.

 * :file:`--master-data=1` will add the current filename and position of the
   binary log to to the output. If set to **1**, will print it as a CHANGE
   MASTER command;

 * :file:`--gtid` will add a SQL statement with the current global transaction
   ID. This tells the slave at the exact position of the binary log (on the
   master) where replication has to begin.
 * Also the output is compressed with **gzip** so we have lighter luggage when
   we transfer the dump to the slave.
 * The file name contains the date and time of the export provided by the
   embedded **date** command.

If successful we have now a compressed copy of the database in the file
:file:`master_dump_2017-12-24_04-44-01-UTC.sql.gz` in our home directory.

You can take a peek with::

    $ zless master_dump_2017-12-24_04-44-01-UTC.sql.gz


Transfer the Dump to the Slave
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Note the escaped brackets:

 * Since we don't have DNS setup yet, we connect using IP address instead of
   hostname.
 * Since we use IPv6 we need brackets to tell the IP address apart from the rest
   of the command.

::

    scp ~/master_dump_2017-12-24_04-44-01-UTC.sql.gz \
        \[2001:db8:c1de::17\]:~/


Allow Remote Connections
^^^^^^^^^^^^^^^^^^^^^^^^

Setup the firewall to allow incoming connections on TCP port 3306 from both
replication slaves. One ore more of the following may apply, depending on your
network environment:

 * With UFW on the master server::

    $ sudo ufw allow proto tcp6 from 2001:db8:c1de::17 to port 3306


 * With a LEDE/OpenWRT firewall/router running Linux:

    $ ...


 * With a MikroTik firewall/router running RouterOS::

    $ ...


This concludes the steps on the master. *Aiken* is now ready as replication
master.


On the Slave *Gannibal*
-----------------------


Setup Secure Connections
^^^^^^^^^^^^^^^^^^^^^^^^

See :doc:`tls`.


Setup Logging
^^^^^^^^^^^^^

See :doc:`log`.


Setup Binary Logging
^^^^^^^^^^^^^^^^^^^^

See :doc:`binlog`,


Setup as Replication Slave
^^^^^^^^^^^^^^^^^^^^^^^^^^

Create the file
:download:`/etc/mysql/conf.d/ReplicationSlave.cnf </server/config-files/etc/mysql/conf.d/ReplicationSlave.cnf>`
and set :file:`server-id` to **2** and :file:`report-host` to **Gannibal**:

.. literalinclude:: /server/config-files/etc/mysql/conf.d/ReplicationSlave.cnf
    :language: ini


Import the Database
^^^^^^^^^^^^^^^^^^^

::

    gunzip --to-stdout ~/master_dump_2017-12-24_04-44-01-UTC.sql.gz | \
        mysql -u root -p


Set Replication Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: sql

    -- Note the commas at the end of each line!
    CHANGE MASTER TO
        MASTER_HOST = '2001:db8:c0de::10',
        MASTER_PORT = 3306,
        MASTER_USER='gannibal',
        MASTER_PASSWORD = '********',
        MASTER_CONNECT_RETRY = 10,
        MASTER_SSL_CA = '/etc/mysql/ssl/ca.example.net.pem',
        MASTER_SSL_CRL = '/etc/mysql/ssl/ca.example.net.crl',
        MASTER_SSL_VERIFY_SERVER_CERT,
        MASTER_SSL_CERT = '/etc/mysql/ssl/gannibal.example.net.cert.pem',
        MASTER_SSL_KEY = '/etc/mysql/ssl/gannibal.example.net.key.pem',
        master_use_gtid = slave_pos;


Start Replication
^^^^^^^^^^^^^^^^^


.. code-block:: sql

        START SLAVE;


Monitoring Replication
----------------------

On the Master
^^^^^^^^^^^^^

.. code-block:: sql

    SHOW MASTER STATUS;


================ ======== ============ ================
File             Position Binlog_Do_DB Binlog_Ignore_DB
================ ======== ============ ================
Aiken-bin.000306 23935243
================ ======== ============ ================

.. code-block:: sql

    SHOW SLAVE HOSTS;

========= ======== ==== =========
Server_id Host     Port Master_id
========= ======== ==== =========
        2 Gannibal 3306 1
========= ======== ==== =========


On the Slave
^^^^^^^^^^^^

.. code-block:: sql

    SHOW SLAVE STATUS;

    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 2001:db8:c0de::10
                      Master_User: gannibal
                      Master_Port: 3306
                    Connect_Retry: 10
                  Master_Log_File: Aiken-bin.000306
              Read_Master_Log_Pos: 24018622
                   Relay_Log_File: Gannibal-relay-bin.000013
                    Relay_Log_Pos: 18716376
            Relay_Master_Log_File: Aiken-bin.000306
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB: pdns,vimbadmin
              Replicate_Ignore_DB:
               Replicate_Do_Table:
           Replicate_Ignore_Table:
          Replicate_Wild_Do_Table:
      Replicate_Wild_Ignore_Table:
                       Last_Errno: 0
                       Last_Error:
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 24018622
                  Relay_Log_Space: 18716733
                  Until_Condition: None
                   Until_Log_File:
                    Until_Log_Pos: 0
               Master_SSL_Allowed: Yes
               Master_SSL_CA_File: /etc/mysql/ssl/ca-cert.pem
               Master_SSL_CA_Path:
                  Master_SSL_Cert: /etc/mysql/ssl/margeret.example.net.cert.pem
                Master_SSL_Cipher: kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM
                   Master_SSL_Key: /etc/mysql/ssl/margeret.example.net.key.pem
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: Yes
                    Last_IO_Errno: 0
                    Last_IO_Error:
                   Last_SQL_Errno: 0
                   Last_SQL_Error:
      Replicate_Ignore_Server_Ids:
                 Master_Server_Id: 1
                   Master_SSL_Crl: /etc/mysql/ssl/ca-cert.pem
               Master_SSL_Crlpath:
                       Using_Gtid: Slave_Pos
                      Gtid_IO_Pos: 0-1-8695681
          Replicate_Do_Domain_Ids:
      Replicate_Ignore_Domain_Ids:
                    Parallel_Mode: conservative
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
    1 row in set (0.01 sec)


References
----------

 * `MariaDB Replication <https://mariadb.com/kb/en/library/high-availability-performance-tuning-mariadb-replication/>`_

 * `Setting Up Replication <https://mariadb.com/kb/en/library/setting-up-replication/>`_

 * `Global Transaction ID <https://mariadb.com/kb/en/library/gtid/>`_

 * `Replication with Secure Connections <https://mariadb.com/kb/en/library/replication-with-secure-connections/>`_

 * `mysqldump <https://mariadb.com/kb/en/library/mysqldump/>`_


.. rubric:: Footnotes

.. [#f1] William Aiken of Colleton, South Carolina was one of the biggest slave owners in in American history.

.. [#f2] `Abram Petrovich Gannibal <https://en.wikipedia.org/wiki/Abram_Petrovich_Gannibal>`_ was slave sold to Russia 1704.
