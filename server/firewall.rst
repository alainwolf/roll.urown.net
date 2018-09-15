Firewall
========

Software Installation
---------------------

Ubuntu dekstop clients and servers have Uncomplicated Firewall (UFW) already installed, but not enabled by default.


Firewall Configuration
----------------------


::

	$ sudo ufw allow ssh/tcp
	$ sudo ufw logging on


Logging
^^^^^^^

By default UFW logs everything in the systems log as kernels messages to
:file:`/var/log/kern.log`. To redirect those messages to a separate log file,
open the log configuration file :file:`/etc/rsyslog.d/20-ufw.conf` and make sure
the following lines are not commented out::

	# Log kernel generated UFW log messages to file
	:msg,contains,"[UFW " /var/log/ufw.log

	# Uncomment the following to stop logging anything that matches the last rule.
	# Doing this will stop logging kernel generated UFW log messages to the file
	# normally containing kern.* messages (eg, /var/log/kern.log)
	& stop


After that the system logging facility needs to be restarted::

	$ sudo systemctl restart rsyslog.service


.. note::
	There is currently no way I know of, to keep the Firewall messages out of
	the systemd journal.


Enabling UFW
------------

::

	$ sudo ufw enable
	$ sudo ufw status


References
----------

 * `UFW <https://help.ubuntu.com/community/UFW>`_

