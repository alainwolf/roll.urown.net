.. warning::
    None of this has been tested yet!

Postfix Mail Server
===================

.. image:: Postfix-logo.*
    :alt: Postfix Logo
    :align: right

`Postfix <http://www.postfix.org/>`_ is a free and open-source mail transfer
agent (MTA) that routes and delivers electronic mail on a Linux system. It is
estimated that around 26% of public mail servers on the internet run Postfix.

.. contents:: \ 


Install Software
----------------

::

    $ sudo apt-get install postfix postfix-mysql

The installed version is Postfix version 2.11, released on January 15, 2014.


Main Configuration
---------------------

Postfix uses a number of different configuration files, with the 
:file:`/etc/postfix/main.cf` being the most important.

The documentation website has `a page dedicated to main.cf
<http://www.postfix.org/postconf.5.html>`_ which includes every possible
configuration paramter.

The whole file, as presented below, is also provided for download at
:download:`main.cf` here.


General Settings
^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: # run "sudo service postfix reload"
    :end-before: # TCP/IP Protocols Settings


TCP/IP Protocols Settings
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: delay_warning_time
    :end-before: # General TLS Settings


General TLS Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: proxy_interfaces
    :end-before: # SMTP Client Settings


SMTP Client Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: tls_high_cipherlist
    :end-before: # SMTP Server Settings


SMTP Server Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: smtp_tls_session_cache_database
    :end-before: # SMTP Server Restrictions

SMTP Server Restrictions
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: smtpd_tls_session_cache_database
    :end-before: # Postscreen Settings


Postscreen Settings
^^^^^^^^^^^^^^^^^^^

90% of todays SMTP connections come from Spambots and Zombies. Postscreen is a
sort of a SMTP mail server firewall. It attempts to reject as many spambots as
possible, before they even get to our main SMTP server, where processing takes a
lot more time and resources, as on the screener. If done well the main SMTP
server has to process only 10% of the connections.

Postscreen is described in detail in a `online readme document 
<http://www.postfix.org/POSTSCREEN_README.html>`_.

.. literalinclude:: main.cf
    :language: ini
    :start-after: body_checks
    :end-before: # Virtual Domain Settings


Virtual Domain Settings
^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: main.cf
    :language: ini
    :start-after: postscreen_bare_newline_action  
    :end-before: # Unocmment to allow catch-all addresses


Map Files and Databases
-----------------------

Postfix uses several maps stored in files to translate things like domains and
mail- addresses at runtime. As these maps can be quite large and change often,
they are not saved in configuration files, but in map-files.

The map files are referenced in the postfix server-configuration. Examples
already used above are the `canonical_maps` or `virtual_mailbox_domains` above.

Such configuration values usually contain a prefix like `hash:` or `mysql:`,
which tell the server in what type of data store the mapping information is
accessible.

If the prefix starts with `hash:` the map is initially is stored as plain text
in the file referenced, but cached later in a hash-database for faster access. A
hashed map or database can change anythime while the server is running, unlike
configuration values, which are only read on server startup, and changes need a
restart of the mail server.


Alias Map
^^^^^^^^^

The file :file:`/etc/aliases` contains information on where mails for certain
system accounts should be delivered to.

This is needed for notification and warning mails created by system programs
(like cronjobs) to reach human beings (like the person responsible for system
adminitration).

..  code-block:: apache

    # See man 5 aliases for format
    # run "sudo newaliases" after changing this file.
    root:       hostmaster@example.com
    postmaster: postmaster@example.com
    webmaster:  webmaster@example.com
    www-data:   webmaster@example.com


The contents of the file are cached in the database :file:`/etc/aliases.db`.
Because of that the database must be refreshed after each and every change made
in :file:`/etc/aliases`::

    $ sudo newaliases


Canonical Sender Map
^^^^^^^^^^^^^^^^^^^^

The :file:`/etc/postfix/sender_canonical` contains information on which sender-
addresses of outgoing mails need to be changed, before mail is sent out.

This is also needed mostly for system generated mails, as they contain local
system account-names as senders, which will not be accepted as valid internet-
mail addresses.

..  code-block:: apache

    # see man 5 canonical
    # run "postmap /etc/postfix/sender_canonical" after changing this file.
    www-data    webmaster@example.com

The contents of the file are cached in the database 
:file:`/etc/postfix/sender-canonical.db`.
Because of that the database must be refreshed after each and every change made
in :file:`/etc/postfix/sender_canonical`::

    $ postmap /etc/postfix/sender_canonical


Canonical Map
^^^^^^^^^^^^^

The file :file:`/etc/postfix/canonical` defines a map on which addresses need
always be changed for sender and recipient in message headers and envelopes.

..  code-block:: apache

    # see man 5 canonical
    # run "sudo postmap /etc/postfix/canonical" after changing this file.this file.
    root        hostmaster@example.com
    postmaster  postmaster@example.com
    webmaster   webmaster@example.com

The contents of the file are cached in the database 
:file:`/etc/postfix/canonical.db`.
To update the database after changes run the following::

    $ sudo postmap /etc/postfix/canonical


SMTP Client Credentials
^^^^^^^^^^^^^^^^^^^^^^^

The file :file:`/etc/postfix/relay_password` contains a lookup table with one
username:password entry per remote hostname or domain used by the Postfix SMTP
client when connecting to other SMTP servers when delivering mail.

..  code-block:: apache
    
    # Usernames and passwords for use at remote SMTP servers.
    # run "sudo postmap /etc/postfix/relay_password" after changing this file.this file.
    smtp.myisp.com server@example.com:********

To update the cache after any changess::

    $ sudo postmap /etc/postfix/relay_password


SMTP Generic Maps
^^^^^^^^^^^^^^^^^

The file :file:`/etc/postfix/generic` contains a lookup table that perform
address rewriting in the Postfix SMTP client, typically to transform a locally
valid address into a globally valid address when sending mail across the
Internet.

..  code-block:: apache

    # Lookup table for address rewriting by the Postfix SMTP client
    # run "sudo postmap /etc/postfix/generic" after changing this file.
    root@server user@example.com
    user@server user@example.com


This is needed when the local machine does not have its own Internet domain
name, but uses something like **localdomain.local** instead.


Sender Address Verification Map
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The file :file:`/etc/postfix/sender_access` contains domain names which often
are used by spammers to forge sender addresses. Postfix will use this list to
verify all sender addresses from the domains listed.

..  code-block:: apache

    # Don't do this when you handle lots of email.
    aol.com     reject_unverified_sender
    hotmail.com reject_unverified_sender
    bigfoot.com reject_unverified_sender
    yahoo.com   reject_unverified_sender


Postscreen Access List
^^^^^^^^^^^^^^^^^^^^^^

In the file :file:`/etc/postfix/postscreen_access.cidr` we define white- and
blacklists for IP subnets and addresses, which allow us to skip Spambot tests by
Postscreen and allow or deny connections right away for certain hosts.

Documentation is available 
`here <http://www.postfix.org/postconf.5.html#postscreen_access_list>`_.

.. code-block:: bash

    # Rules are evaluated in the order as specified.
    # http://www.postfix.org/postconf.5.html#postscreen_access_list

    # Private IPv4 addresses (RFC 1918)
    10.0.0.0/8 permit
    172.16.0.0/12 permit
    192.168.0.0/16 permit

    # Private IPv6 addresses (RFC 4193)
    fc00::/7 permit

    # Link-local IPv4 addresses (RFC 6890 and RFC 3927)
    169.254.0.0/24 permit
    169.254.255.0/24 permit
    169.254.0.0/16 permit

    # Link-local IPv6 addresses (RFC 4862 and RFC 4291)
    fe80::/10 permit

    # Global IPv6 subnet assigned to us (example.com)
    2001:db8::/64 permit


Virtual Domain Map
^^^^^^^^^^^^^^^^^^

We referenced this the file 
:file:`/etc/postfix/mysql-virtual-mailbox-domains.cf` in the main configuration 
file :file:`main.cf` above as *virtual_mailbox_domains*. It contains MySQL 
database server connection information, so Postfix can lookup the virtual 
domains hosted here:

.. code-block:: text

    user = mailuser
    password = ********
    hosts = localhost
    dbname = mailserver
    query = SELECT 1 FROM virtual_domains WHERE name='%s'    


Use the user, password and database defined in :doc:`database`.


Virtual Mailbox Map
^^^^^^^^^^^^^^^^^^^

Same as with the virtual domain map above, the following MySQL connection
defined in :file:`/etc/postfix/mysql-virtual-mailbox-maps.cf` is used to lookup
which mailboxes are hosted here:

.. code-block:: text

    user = mailuser
    password = ********
    hosts = 127.0.0.1
    dbname = mailserver
    query = SELECT 1 FROM virtual_users WHERE email='%s'

Note that the only difference to the above one is the SQL query. looking for mailboxes
instead of domains.


Virtual Alias Map
^^^^^^^^^^^^^^^^^

Finally we also create :file:`/etc/postfix/mysql-virtual-alias-maps.cf` to give
Postfix a way to lookup mailbox aliases at the MySQL database server:

.. code-block:: text

    user = mailuser
    password = ********
    hosts = 127.0.0.1
    dbname = mailserver
    query = SELECT destination FROM virtual_aliases WHERE source='%s'


Master Process Configuration
----------------------------

Postfix consists of many daemons and utilities, some running all the time and
others started when needed. The :file:`/etc/postfix/master.cf` confiugration
file is the centralized control center from where the Postfix master process
gets his guidelines on what, when and how all these programs have to be started.

Where no command-line options are specified, the program uses relevant
configuration values from the :file:`main.cf` configuration file. Alternatively
options can be overridden by command-line parameters like :option:`-o`.

The official documentation website `provides a manual page 
<http://www.postfix.org/master.5.html>`_ online.

The whole file, as presented below, is also provided for download at
:download:`master.cf` here.

The SMTP daemon
^^^^^^^^^^^^^^^

The first daemon specified here is the SMTP daemon **smtpd** which runs on the
dedicated SMTP TCP port 25, it is enabled by default, but as we use postscreen
in front of it we comment that out:

.. literalinclude:: master.cf
    :language: bash
    :lines: 8-11,12,66

Postscreen SMTP Firewall
^^^^^^^^^^^^^^^^^^^^^^^^

We enable **postscreen** on the second line instead of **smtpd** on the first
line. This runs a mininmal SMTP subset to perform some compliance tests on
incoming SMTP client connections. If the client passes all tests he gets
whitelistet and the connection is passed along to the real SMTP server running
behind it. That is what the second line above is for. An **smtpd** daemon that
takes over connections from **postscreen** only. The **tlsproxy** handles TLS
encryption for postscreen and **dnsblog** does the DNS blacklist lookups.

.. literalinclude:: master.cf
    :language: bash
    :lines: 8-11,13-16,66


The Submission Daemon
^^^^^^^^^^^^^^^^^^^^^

The submission daemon runs on TCP port 587 and lets mail clients (:abbr:`MUA
(Mail User Agent)`) to submit mails. The submission daemon accepts only
encrypted connections, allows only authenticated and authorized users, but also
allows mails to be relayed out on the internet, besides accepting mail to its
own hosted domains and mailboxes.

In practice, this is another copy of the SMTP daemon running on TCP port 587 instead of port 25 and some command-line options to override the default SMTP daemon settings from :file:`main.cf`.

It is not enabled by default, we have to remove the comment ('#') symbol at the
start of the line and the options in the following lines:

.. literalinclude:: master.cf
    :language: bash
    :lines: 8-11,17-27,66



References
----------

 * `Postfix Documentation <http://www.postfix.org/documentation.html>`_
