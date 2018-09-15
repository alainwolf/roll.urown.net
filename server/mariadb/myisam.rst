MyISAM Storage Engine
=====================

`MyISAM <https://mariadb.com/kb/en/library/myisam-storage-engine/>`_ was the
default storage engine from MySQL 3.23 until it was replaced by the :doc:`innodb`.
We will not use it for any database ourselves but it is still in use by the
server internally as default for various tasks, so we set its footprint as small
as possible.

:download:`/etc/mysql/conf.d/MyISAM.cnf</server/config-files/etc/mysql/conf.d/MyISAM.cnf>`:

.. literalinclude:: /server/config-files/etc/mysql/conf.d/MyISAM.cnf
    :language: ini

Reference
---------
 * `MyISAM System Variables <https://mariadb.com/kb/en/library/myisam-system-variables/>`_
