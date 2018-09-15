Logs for Machines
=================

The binary logs are used for backup and replication.

The server can be told to record each and every MySQL transaction in a specially
formatted log-file called `the binary log
<https://mariadb.com/kb/en/mariadb/overview-of-the-binary-log/>`_. The binary
log is used for `database replication
<https://mariadb.com/kb/en/mariadb/replication-overview/>`_ between servers but
it is essentially also a backup tool, as it gives us the possibility to restore
the exact state of a database table of any given point in the past by reversing
all transactions found in the binary log.

:download:`/etc/mysql/conf.d/BinLog.cnf</server/config-files/etc/mysql/conf.d/BinLog.cnf>`:

.. literalinclude:: /server/config-files/etc/mysql/conf.d/BinLog.cnf
    :language: ini


Notable settings
----------------

 * Same as before, set **log_bin** to a unique distinguishable and
   identifiable name across all past, present and future instances of your
   database servers.

 * We set the **max_binlog_size** to a more manageable size in case they have to
   be moved across slower networks or media.

 * We set **expire_logs_days** to a value that lets us survive a major outage
   for up to three weeks.


References
----------

 * `Binary Log <https://mariadb.com/kb/en/library/binary-log/>`_
