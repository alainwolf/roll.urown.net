Database Backup
===============

.. contents::
  :local:


Logical vs Physical Backups
---------------------------

Both of these methods have their own drawbacks and benefits.

Logical Database Backups
^^^^^^^^^^^^^^^^^^^^^^^^

Logical backups consist of the SQL statements necessary to restore the data,
such as `CREATE DATABASE`, `CREATE TABLE` and `INSERT`.

 * Logical backups are more portable, as the *exported* data can be imported
   later on any other server.

 * With logical backups only specific databases or tables or any other specific
   selection of data cab be *exported* and used as backup.

 * Logical backups are bigger in size.

 * Logical backups take considerable more time to backup and to restore.

 * Logical backups will only contain the data, without any configuration
   variables or transactional logs.

 * The huge data exports and full table scans which are unavoidable during any
   logical backup my put your database server under considerable stress and
   defeat the purpose of the servers cache and buffers, thus may result in
   undesirable effects on the operation and performance of your database server.


Physical Database Backups
^^^^^^^^^^^^^^^^^^^^^^^^^

Physical backups are performed by copying the individual data files or
directories.

 * I won't work by just copying the files out of the data directory of a running
   database server. Since data will almost certainly have changed in between the
   first and last byte copied. The result will thus not be usable for restoration.
   Either shut down the server completely before doing so, or use specific tools
   designed for the task. Since we don't want any downtime, the latter is the
   only remaining option.

 * Physical backups wont work on other database server software, probably not
   even on other versions of the same software

 * Physical backups just backup the whole database server, not individual
   databases or files. However, some exceptions may apply depending on the server
   software and the backup tool used.

 * Physical backups are smaller in size.

 * When performed by a specific tools, physical backups normally don't affect
   the normal operation or performance of the database server.



Mariabackup
-----------

`Mariabackup <https://mariadb.com/kb/en/mariabackup-overview/>`_ is an open
source tool provided by MariaDB for performing **physical online backups** of
InnoDB, Aria and MyISAM tables. For InnoDB, “hot online” backups are possible.


Installation
^^^^^^^^^^^^

Install from the same source and version as your MariaDB database server
version::

    $ sudo apt-get install mariadb-backup



Preparing for Backups
---------------------


File-System Directory
^^^^^^^^^^^^^^^^^^^^^

In case of full backups, the file-system directory where the backup will be stored,
needs to be empty and owned by the user who also runs the MySQL server::


    $ sudo mkdir -p /var/backups/mariadb/full
    $ sudo -u mysql rm -rf /var/backups/mariadb/full
    $ sudo chown -R mysql:mysql /var/backups/mariadb


Datbase User
^^^^^^^^^^^^

Let's create a databse user on the server, with all needed privileges
to perform the backups.

::

    $ pwgen --secure 32 1
    ********
    $ mysql -u root -p


.. code-block:: sql

    mysql> CREATE USER 'mariabackup'@'localhost' \
                IDENTIFIED BY '********';

    mysql> GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT \
                ON *.* TO 'mariabackup'@'localhost';

    mysql> FLUSH PRIVILEGES;

    mysql> exit



Configuration Options File
^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's create a configuration file
:file:`/etc/mysql/conf.d/MariaBackup.cnf` to store all the options in a
"[mariabackup]" section.

.. note::

    Despite this being a MariaDB specific configuration file, it needs to be
    stored in /etc/mysql/conf.d/ as [mariadb] is not recognized by mariabackup,
    the file would never be inlcuded otherwise. See
    `MDEV-21298 <https://jira.mariadb.org/browse/MDEV-21298>_`


.. literalinclude:: /server/config-files//etc/mysql/conf.d/MariaBackup.cnf
    :language: ini



Creating a Full Backup
----------------------

Backups are performed as the MariaDB Linux user `mysql`, who also runs the
database server.


.. note::

    Note the space at the beginning of the following command-line. This inhibts
    the storage of the command and password in the shells command-line history.

::

    $  sudo -u mysql mariabackup --backup \
        --target-dir=/var/backups/mariadb/full \


When Mariabackup runs, it issues a global lock to prevent data from changing
during the backup process and ensure a consistent record. If it encounters
statements still in the process of executing, it waits until they complete
before setting the lock.

.. code-block:: txt

    [00] 2020-06-02 04:16:11 Connecting to MySQL server host: localhost
    ...
    [00] 2020-06-02 04:16:22 completed OK!



Restoring a Full Backup
-----------------------

With Mariabackup database restoration is a two-step process.


Preparation
^^^^^^^^^^^

::

    $ mariabackup --prepare


Copy Back
^^^^^^^^^

::

    $ mariabackup --copy-back

