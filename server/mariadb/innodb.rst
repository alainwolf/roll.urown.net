InnoDB Storage Engine
=====================

InnoDB is a general-purpose storage engine that balances high reliability and
high performance.

It is the default storage engine for MariaDB since version 10.2. and MySQL since
5.7.

Key advantages of InnoDB include:

* Its DML operations follow the ACID model, with **transactions** featuring
  **commit**, **rollback**, and  **crash-recovery** capabilities to protect user
  data.

* **Row-level locking** and consistent reads increase **multi-user concurrency**
  and **performance**.

* InnoDB tables arrange your data on disk to optimize queries based on primary
  keys. Each InnoDB table has a primary key index called the clustered index
  that organizes the data to minimize I/O for primary key lookups.

* To maintain data integrity, InnoDB supports FOREIGN KEY constraints. With
  foreign keys, inserts,updates, and deletes are checked to ensure they do not
  result in inconsistencies across different tables.


:download:`/etc/mysql/conf.d/InnoDB.cnf </server/config-files/etc/mysql/conf.d/InnoDB.cnf>`:

.. literalinclude:: /server/config-files/etc/mysql/conf.d/InnoDB.cnf
    :language: ini

Reference
---------

 * `InnoDB Server System Variables <https://mariadb.com/kb/en/library/xtradbinnodb-server-system-variables/>`_
