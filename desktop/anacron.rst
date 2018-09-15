Anacron
=======

Since personal computers, unlike servers, are not running 24 hours a day, the
daily user data backups should be started by
`anacron <http://manpages.ubuntu.com/manpages/xenial/en/man8/anacron.8.html>`_
instead of the usual **cron**.

Anacron will run the backup job once a day, whenever the computer is turned on
and not running on battery.

Unlike **cron**, **anacron** is normally used for system administrative jobs
only and does not run individual user jobs. This document describes how to setup
**anacron** for individual users, so they can run their personal periodic jobs.


Directory Structure
-------------------

Create anacron directories in the users home directory::

	$ mkdir -p ~/.anacron/cron.{daily,weekly,monthly} ~/.anacron/spool


This creates the following directory structure:

 * :file:`~/.anacron/cron.daily`
 * :file:`~/.anacron/cron.monthly`
 * :file:`~/.anacron/cron.weekly`
 * :file:`~/.anacron/spool`


The anacrontab File
-------------------

Anacron reads the list of jobs from the configuration file
`anacrontab <http://manpages.ubuntu.com/manpages/xenial/en/man5/anacrontab.5.html>`_

Create and edit the file :file:`~/.anacron/anacrontab` and replace username and home directory with your own literal values (shell variables won't work here)::

	# See anacron(8) and anacrontab(5) for details.
	MAILTO=user@example.net
	SHELL=/bin/bash
	LOGNAME=${USER}
	PATH=/home/user/bin:/home/user/.local/bin:/usr/local/bin:/bin:/usr/bin

	# period  delay  job-id       command
	1          5     daily-cron   nice run-parts --report /home/user/.anacron/cron.daily
	7         10     weekly-cron  nice run-parts --report /home/user/.anacron/cron.weekly
	@monthly  15     monthly-cron nice run-parts --report /home/user/.anacron/cron.monthly


Run on Login
------------

To run anacron on every login edit the file :file:`~/.profile` and add the
following line at the bottom::

	...
	/usr/sbin/anacron -t /home/user/.anacron/anacrontab -S /home/user/.anacron/spool


Run every Hour
--------------

To make anacron check every hour, if there is anything to do, edit the users
`crontab <http://manpages.ubuntu.com/manpages/xenial/en/man5/crontab.5.html>`_
file as follows::

	$ crontab -e


This opens an editor, where the following lines need to be added at the bottom::

	...
	MAILTO=user@example.net
	...
	# Run anacron every hour to check for daily/monthly/weekly jobs to run
	@hourly /usr/sbin/anacron -t /home/user/.anacron/anacrontab -S /home/user/.anacron/spool

