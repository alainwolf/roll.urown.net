.. index::
    single: Internet Protocols; IMAP
    single: Internet Protocols; POP
    single: Internet Protocols; LMTP


MAS - Mail Access Server
========================

.. image:: Dovecot-logo.*
    :alt: Dovecot Logo
    :align: right

`Dovecot <http://www.dovecot.org/>`_ is an open source :abbr:`IMAP (Internet
Message Access Protocol)` and :abbr:`POP3 (Post Office Protocol)` server for
Linux/UNIX-like systems, written primarily with security in mind. Dovecot is an
excellent choice for both small and large installations. It's fast, simple to
set up, requires no special administration and it uses very little memory.

.. contents:: \


Install Software
----------------

Dovecot is in the Ubuntu software packages repository::

    $ sudo apt-get install dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved


You will be asked about security certificate, and if a self-signed certificate
should be created for you. Answer **<No>** to that, as we will use the already
created :doc:`../server-tls`.

The installation creates the following items:

 * The user and group **dovecot** for the mail server.
 * The user and group **dovenull** to process mail server logins.
 * The directory :file:`/etc/dovecot`
 * The main configuration file :file:`/etc/dovecot/dovecot.conf`
 * Various other configuration files in the directory
   :file:`/etc/dovecot/conf.d`
 * The Ubuntu Upstart service configuration :file:`/etc/init/dovecot.conf`

Other example configuration files are found in the
:file:`/usr/share/doc/dovecot-core/example-config/` directory.


Main Configuration
------------------

The main configuration file
:download:`/etc/dovecot/dovecot.conf
</server/config-files/etc/dovecot/dovecot.conf>` has a limited amount of
settings, as most things are included from individual files in the
:file:`/etc/dovecot/conf.d` directory.


.. index::
    single: Internet Protocols; IMAP
    single: Internet Protocols; LMTP


Services
^^^^^^^^

Dovecot can provide a number of mail services. We activate |IMAP| and |LMTP|.

.. literalinclude:: /server/config-files/etc/dovecot/dovecot.conf
    :language: bash
    :start-after: # --sysconfdir=/etc --localstatedir=/var
    :end-before: # A comma separated list of IPs or hosts


IP-Addresses
^^^^^^^^^^^^

Dovecot would bind to all available addresses, to change that, we remove the
comment hashtag and set the IP address the |IMAP| server should listen to
connections:

.. literalinclude:: /server/config-files/etc/dovecot/dovecot.conf
    :language: ini
    :start-after: protocols = imap lmtp
    :end-before: # Base directory where to store runtime data.


Database Connection
-------------------

Dovecot can use our mailserver database to validate domains, mailboxes and
authenticate users. The configuration is set in the file
:download:`/etc/dovecot/dovecot-sql.conf.ext
</server/config-files/etc/dovecot/dovecot-sql.conf.ext>`.


Type of Database
^^^^^^^^^^^^^^^^

What type of database or server to use:

.. literalinclude:: /server/config-files/etc/dovecot/dovecot-sql.conf.ext
    :language: ini
    :lines: 30-33


Database Server Login
^^^^^^^^^^^^^^^^^^^^^

How to connect to the database server and what username and password to use:

.. literalinclude:: /server/config-files/etc/dovecot/dovecot-sql.conf.ext
    :language: ini
    :lines: 34,70

The database-name, user and password are identical to what you have set in
:file:`/etc/postfix/mysql-virtual-mailbox-maps.cf` for :doc:`postfix-mta`.


Password Scheme
^^^^^^^^^^^^^^^

How are passwords stored (hashed) in the password database:

.. literalinclude:: /server/config-files/etc/dovecot/dovecot-sql.conf.ext
    :language: ini
    :lines: 72,78

The Dovecot Wiki describes the available `password schemes
<See http://wiki2.dovecot.org/Authentication/PasswordSchemes>`_.


Database Query
^^^^^^^^^^^^^^

The MySQL query to retrieve username and (hashed) password for a mail-address.

.. literalinclude:: /server/config-files/etc/dovecot/dovecot-sql.conf.ext
    :language: ini
    :lines: 80-84, 110


.. index::
    single: IMAP
    single: LMTP
    single: AUTH


Services
--------

The file :download:`/etc/dovecot/conf.d/10-master.conf
</server/config-files/etc/dovecot/conf.d/10-master.conf>` defines the
properties of the services Dovecot provides to other hosts.

We use Dovecot to provide the following services:

    * |IMAP| - for MUA to access their mailbox
    * |LMTP| & |LDA| - Delivery of mail to local mailboxes
    * AUTH - let other services (i.e. |MSA| or |XMPP|) authenticate users by
      Dovecot.


IMAP Settings
^^^^^^^^^^^^^

The |IMAP| service configuration can be left at its defaults.

In the file :download:`/etc/dovecot/conf.d/20-imap.conf
</server/config-files/etc/dovecot/conf.d/20-imap.conf>` we add
the :command:`imap_sieve` pluing as loaded (more on sieve later).

It also advisable to increase the number of IMAP connections per user from the
default 10, considering multiple devices (PC, Laptop, Notebook, Tablet,
Smartphone) and probably most of it trough NAT.


LMTP - Local Mail Transport
^^^^^^^^^^^^^^^^^^^^^^^^^^^

*   When the |MTA| server has accepted a message from the Internet he uses an
    |LDA| to send it to the server who holds the recipients mailbox.

*   When the |MSA| server has accepted a message from an |MUA| he then sends it
    by |LMTP| to the |MTA| who takes care of the transer to other  Internet
    domains.

*   A script running on a web-server creates a mail to a user, as part of some
    transaction (registraion confirmation, password-reset). The web server uses
    |LMTP| to send it to the |MTA|.

To allow our |MTA| Postfix to deliver mails to mailboxes trough the Dovecot
|LMTP| service:

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-master.conf
    :language: ini
    :lines: 48-53

The configuration file
:download:`/etc/dovecot/conf.d/20-lmtp.conf
</server/config-files/etc/dovecot/conf.d/20-lmtp.conf>`
holds settings specific to the |LMTP| service.

We load the Dovecot :term:`Sieve` plugin.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/20-lmtp.conf
    :language: ini
    :start-after: #lmtp_rcpt_check_quota = no


LDA - Local Delivery Agent
^^^^^^^^^^^^^^^^^^^^^^^^^^

Local delivery happens when mails are to be delivered to a mailbox of the local
system. Here are some uses-cases:

The file :download:`/etc/dovecot/conf.d/15-lda.conf
</server/config-files/etc/dovecot/conf.d/15-lda.conf>` is used to set-up local
delivery.

The name and domain of our server is only availabel in our local LAN and not
valid on the Internet. We therefore need to override the server-name and the
postmaster mail address to values which are valid and recognizible, as these
will be inserted in the header of messages.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/15-lda.conf
    :language: ini
    :lines: 4-11

We load the Dovecot :term:`Sieve` plugin.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/15-lda.conf
    :language: ini
    :start-after: lda_mailbox_autosubscribe = yes


AUTH Settings
^^^^^^^^^^^^^

Other services can use Dovecot for user authentication instead of maintaining
their own user-database. A registred user on our mail server can use the same
username and password with other services.

To allow our |MSA| Postfix to use the user authentication service, the UNIX
socket that Postifx will access, needs specific access rights:

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-master.conf
    :language: ini
    :lines: 77, 97-102


Transport Layer Security
------------------------

See also the `Dovecot SSL configuration
<http://wiki2.dovecot.org/SSL/DovecotConfiguration>`_ in the Dovecot wiki.

The file :download:`/etc/dovecot/conf.d/10-ssl.conf
</server/config-files/etc/dovecot/conf.d/10-ssl.conf>` contains settings
for TLS protocol settings, certificates and keys.

We enforce encryption and server authentication on all connections:

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 5-6

Where the servers certificate and private key are stored:

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 14-15

..  note::
    Note the "**<**" character in front of the filenames. Dovecot will fail with
    errors about unreadable :term:`PEM encoded` key files, if they are omitted.


Diffie-Hellmann Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^

Encryption strenght of session keys negotiated by :term:`Diffie-Hellman key
exchange`.

Dovecot creates its own :term:`DH parameters` and also refesehes them
periodically. There is no need to provide a :term:`DH parameters` file, as with
some other servers.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 47-48


SSL & TLS Protocol Versions
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 50-52


.. index:: Cipher Suite; Set in Dovecot


Set our selected :ref:`cipher-suite`.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 53-55


Let the server choose the cipher-suite during handhake.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-ssl.conf
    :language: ini
    :lines: 57-58


Authentication
--------------

The file :download:`/etc/dovecot/conf.d/10-auth.conf
</server/config-files/etc/dovecot/conf.d/10-auth.conf>` defines how users
logins are processed.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-auth.conf
    :language: ini
    :start-after: #auth_ssl_username_from_cert = no
    :end-before: ##

Disable login for system users and enable the MySQL user database, by
commenting out the first line with a hashtag and activating the *auth-
sql.conf.ext* line with a exclamation mark:

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-auth.conf
    :language: bash
    :start-after: # <doc/wiki/UserDatabase.txt>

The now included file :download:`/etc/dovecot/conf.d/auth-sql.conf.ext
</server/config-files/etc/dovecot/auth-sql.conf.ext>` contains references to
the database configuration file.

First where (hashed) paswords are retrieved for authenticating users:

.. literalinclude:: /server/config-files/etc/dovecot/auth-sql.conf.ext
    :language: bash
    :start-after: # <doc/wiki/AuthDatabase.SQL.txt>
    :end-before: # "prefetch" user database

And how other used properties, like mailbox directory, are retrieved:

.. literalinclude:: /server/config-files/etc/dovecot/auth-sql.conf.ext
    :language: bash
    :lines: 32-

The parameter **static** above means. they are not retrieved from the database,
but are all the same for all our users according to the values in **args**.

The **args** values are translated as follows:

 * The system user profile and group used who accesses the mailbox directory
    is **vmail**.

 * Mailboxes are stored in the directory :file:`/var/vmail/%d/%n/` where
    **%d** will be replaces by the domain name (e.g. example.net) and %n will
    be replaced by the user name.

 *  **allow_all_users=yes**, is to allow mail delivery, also for mails to users
    not found yet in the database.

This basically means, that mails for **user@example.net** will be stored in the
:file:`/var/vmail/example.net/user` directory.


Mailbox Locations
-----------------

In the file :download:`/etc/dovecot/conf.d/10-mail.conf
</server/config-files/etc/dovecot/conf.d/10-mail.conf>` we set up parameters
for our virtual mailboxes.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-mail.conf
    :language: bash
    :lines: 31


.. literalinclude:: /server/config-files/etc/dovecot/conf.d/10-mail.conf
    :language: bash
    :lines: 103-108


IMAP Folder Creation
--------------------

Most mail clients use a common set of IMAP folders, besides the "Inbox" for
storing various types of mails:

    * Drafts
    * Sent
    * Archives
    * Junk
    * Trash

We can tell Dovecot to create these folders automatically, if they don't
already exists, on users login. The user will also be subcribed to them,
depending on settings. If a user accidentely deletes one of these folders,
they will be re-created automatically on the next login.

:download:`/etc/dovecot/conf.d/15-mailboxes.conf
</server/config-files/etc/dovecot/conf.d/15-mailboxes.conf>`.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/15-mailboxes.conf
    :language: bash



Sieve Filter Management Server
------------------------------

Todays users access their mail from multiple devices and locations. Desktop
computers at the office and at home, laptops, notebooks, tablets, smartphones,
while commuting or from coffee-shops, hotel-rooms etc. They use dedicated mail
clients like Thunderbird or Outlook, but also with their browser on webmail
clients.

Classic client-side mail filter-rules don't cut it anymore. Mail has to be
categorized and filtered on the server on delivery, to provide a consistent
view accross all clients.

:term:`Sieve` is a basic script language to manage mail on the server, by
triggering simple actions (move to folder, delete, mark as read, etc.), based
on message attributes like sender or recipient, spam-flags, mailing-listss,
headers, etc. The famous "Out-of Office" or "Vacation" auto-answer is a
typical use case.

The ManageSieve server allows administrators to define a set of sieve-scripts
for all accounts on the server, but also lets users to manage their own mail
filters.

User can manage their own filter-scripts with a sieve client. Either integrated
in their mail-client, on their webmail-page or with standalone software which
then connects to the ManageSieve server provided by dovecot.

The ManageSieve server is configured in the file
:download:`/etc/dovecot/conf.d/20-managesieve.conf
</server/config-files/etc/dovecot/conf.d/20-managesieve.conf>`.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/20-managesieve.conf
    :language: bash


Pigeonhole Sieve interpreter
----------------------------

Sieve plugin itself is configured in the file
:download:`/etc/dovecot/conf.d/90-sieve.conf
</server/config-files/etc/dovecot/conf.d/90-sieve.conf>`.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/90-sieve.conf
    :language: bash


Dovecot Sieve & RSPAMD
----------------------

Sieve is also used to intergrate Dovecot nicely with the RSPAMD Spamfilter:

    * Mail marked as Spam by RSPAMD is moved to the Junk folder, instead of the
      Inbox.
    * When a user moves a message from any folder to the Junk folder, that
      message is passed on to RSPAMD as training data to improve its
      reliablitly in detecting spam.
    * When a user is movin a message out of the Junk folder, its also passed on
      to RSPAMD for training to reduce false postives.

`darix on GitHub <https://github.com/darix/dovecot-sieve-antispam-rspamd>`_ has
prepared a set of scripts and configurations for doing all that.


Installation
^^^^^^^^^^^^

Clone and install darix's repository::

    $ cd /usr/local/src/
    $ git clone git@github.com:darix/dovecot-sieve-antispam-rspamd.git
    $ cd dovecot-sieve-antispam-rspamd
    $ make install


Configuration
^^^^^^^^^^^^^

The dovecot sieve scripts need access to the RPSPAMD controller socket.
Write your RPSPAMD controller password in to the file
:file:`/etc/dovecot/rspamd-controller.password`.

Most other settings are found in the file
:file:`/etc/dovecot/conf.d/99-antispam_with_sieve.conf`.

Change the lines containing the Spamfolder to the one we use::

    ...
    imapsieve_mailbox1_name = Junk
    ...
    imapsieve_mailbox2_from = Junk


The same needs to be done in the sieve script
:file:`/usr/lib/dovecot/sieve/global-spam.sieve`::

    ...
    fileinto :create "Junk";
    ...


Mailbox Quota
-------------

Quota Plugins Activation
^^^^^^^^^^^^^^^^^^^^^^^^

In the file :file:`/etc/dovecot/conf.d/20-imap.conf`:

.. code-block:: bash

    # Enable quota plugin for tracking and enforcing the quota.
    mail_plugins = $mail_plugins quota

    # Enable the IMAP QUOTA extension, allowing IMAP clients to ask for the
    # current quota usage.
    mail_plugins = $mail_plugins imap_quota


Qupta Plugins Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Quota plugins configurations in the file
:download:`/etc/dovecot/conf.d/90-quota.conf
</server/config-files/etc/dovecot/conf.d/90-quota.conf>`.

.. literalinclude:: /server/config-files/etc/dovecot/conf.d/90-quota.conf
    :language: bash


Quota Warning Mails
^^^^^^^^^^^^^^^^^^^

Create the simple shell script :file:`/usr/local/bin/dovecot-quota-warning`::

    #!/bin/sh

    PERCENT=$1
    USER=$2

    cat << EOF | /usr/lib/dovecot/dovecot-lda -d "$USER" \
        -o "plugin/quota=maildir:User quota:noenforcing"
    From: postmaster@urown.net
    Subject: Mail service quota warning

    Your mailbox $USER is now $PERCENT% full.

    You should delete some messages from the server.


    WARNING: Do not ignore this message as if your mailbox
    reaches 100% of quota, new mail will be rejected.

    EOF


Make it executable::

    $ chmod +x /usr/local/bin/dovecot-quota-warning
