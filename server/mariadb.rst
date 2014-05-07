MariaDB Database Server
=======================

Software Installation::

	$ sudo apt-get install mariadb-server

Configuration files are found in the :file:`/etc/mysql` directory.

MariaDB runs as service **mysql**::

	$ sudo service mysql status
	 * /usr/bin/mysqladmin  Ver 9.0 Distrib 5.5.37-MariaDB, for debian-linux-gnu on x86_64
	Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.

	Server version		5.5.37-MariaDB-0ubuntu0.14.04.1
	Protocol version	10
	Connection		Localhost via UNIX socket
	UNIX socket		/var/run/mysqld/mysqld.sock
	Uptime:			1 day 14 hours 36 min 43 sec

	Threads: 1  Questions: 569  Slow queries: 0  Opens: 329  Flush tables: 4  Open tables: 22  Queries per second avg: 0.004
