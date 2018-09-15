Router Mail
===========

Since most of our routers are working reliably, sometimes for years without
interruption, we tend to forget about them.

We might not be aware that it needs some software-updates or has
a problem with hardware or software configuration .

Therefore we want our router to tell us, whenever something is going on that
we should be aware of.


Prerequisites
-------------

A dedicated SMTP user for the router on your mail server.

We assume you already created the account router@example.net on your mail
server. This account has the ability to login on the Submission server and
send out mails. He does not need any access to a mailbox (IMAP etc.).


Required Software
^^^^^^^^^^^^^^^^^

 * ssmtp - A secure, effective and simple way of getting mail off a system to your mail hub.

To install this::
	
	router$ opkg install ssmtp


Configuration
-------------

The configuration file is located at :file:`/etc/ssmtp/ssmtp.conf`:

.. code-block:: bash
   :linenos:

	#
	# /etc/ssmtp.conf -- a config file for sSMTP sendmail.
	#

	# The person who gets all mail for userids < 1000
	# Make this empty to disable rewriting.
	root=hostmaster@example.net

	# The place where the mail goes. The actual machine name is required
	# no MX records are consulted. Commonly mailhosts are named mail.domain.com
	# The example will fit if you are in domain.com and your mailhub is so named.
	mailhub=mail.example.net:587

	# Where will the mail seem to come from?
	rewriteDomain=router.example.net

	# The full hostname
	hostname=router.example.net

	# Set this to never rewrite the "From:" line (unless not given) and to
	# use that address in the "from line" of the envelope.
	FromLineOverride=YES

	# Use SSL/TLS to send secure messages to server.
	UseTLS=YES
	UseSTARTTLS=Yes

	AuthUser=router@example.net
	AuthPass=********

	# Get enhanced (*really* enhanced) debugging information in the logs
	# If you want to have debugging of the config file parsing, move this option
	# to the top of the config file and uncomment
	#Debug=YES


Protect the configuration, since it contains account details::

	router$ chown root:mail /etc/ssmtp/ssmtp.conf
	router$ chmod 640 /etc/ssmtp/ssmtp.conf


Testing
-------

To send a test mail from the router to you::

	router$ ssmtp -v -F 'OpenWRT Router' -f router@example.net "Testing Router Mail Setup" user@example.net

