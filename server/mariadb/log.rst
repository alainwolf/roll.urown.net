Logs for Humans
===============

Where and how to save human readable logs. Not to be confused with
**binary-logs**, where database transactions are logged for backup and
replication purpose in machine-readable format.

Unless while debugging or developing software who has database queries, we want
to keep the logging overhead on a small footprint.

:download:`/etc/mysql/conf.d/Logging.cnf</server/config-files/etc/mysql/conf.d/Logging.cnf>`:


.. literalinclude:: /server/config-files/etc/mysql/conf.d/Logging.cnf
    :language: ini


Notable settings
----------------

 * Its important to set **Log-basename** to a unique distinguishable and
   identifiable name across all past, present and future instances of database
   servers.
 * We want to see aborted and failed connections from database clients and
   failed logins in the system journal.


Monitoring the Server
---------------------

::

	journalctl -u mariadb.service -f --no-tail

