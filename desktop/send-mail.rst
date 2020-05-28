Personal Mail Server
====================

Usually personal computers are not set up to send mail out on their own.

However like every Linux system, their are lot of things going on in the
background, mostly invisible to the user. Their are some useful features which
are only possible if the system can tell you about.

For example, did you know that, of somebody tries to log-in on your personal
computer and fails, the system tries to notify you by mail?

This works only if the system is able to send out mails.


Null Client
-----------

We want our personal computer to send out mails on its own, but not receive any,
or deliver mails to its local user accounts.

This particular configuration is called a A **null client** and can be described
as follows:

 * It never receives any mail from the network
 * It can only send mail out to a mail gateway/smart-host. 
 * It does not deliver any mail locally. All mails are sent to outside mail accounts.

In the following example, our personal workstation will be called **torres**. 
We have purchased an set-up our own domain **example.net**. 
We call our mail-server **mail.example.net**. 

This mail server accepts only mails from registered mail accounts who login with
their full mail address and password on the SMTP submission server running on
port 587.

The connection needs to be encrypted by TLS.

Prerequisites
-------------

Mail-Server Account
^^^^^^^^^^^^^^^^^^^

Like your desktop mail client any other client, **torres** will need to login 
(as "torres@example.net"), before being allowed to deliver mails on 
**mail.example.net**.

We therefore create a mail account for it on our mail server.

Create a mail account password for the mail account **torres@example.net**::

    $ pwgen --secure 32 1
    ********

`Create a mail account </server/mail/virtual.html#adding-a-mailbox>`_ for your
workstation on your mail server. You can use the mail servers
:doc:`/server/mail/vimbadmin` for that.


Installation
------------

To install::

    $ sudo apt install postfix mailutils


The installation process will ask you a series of questions:

.. note ::

    You can restart this configuration wizard again anytime later with the
    command::

        $ sudo dpkg-reconfigure postfix


Unfortunately the "null client" configuration we need here is not in the list.
Therefore we have to choose: "No configuration" here.


Postfix Configuration
---------------------

Make a copy of the sample configuration file::

    $ sudo cp /etc/postfix/main.cf.proto /etc/postfix/main.cf


Set the group for postfix to run tasks in :file:`/etc/postfix/main.cf`::

    # setgid_group: The group for mail submission and queue management
    # commands.  This must be a group name with a numerical group ID that
    # is not shared with other accounts, not even with the Postfix account.
    #
    setgid_group = postdrop


Client Authentication
^^^^^^^^^^^^^^^^^^^^^

As mentioned before, for the central mail server **mail.example.net**, our
workstation is just another mail client, which needs to login before being
allowed to send any mails.

This is how we tell our workstation to login on the remote server
**mail.example.net**.

We store the login password in the file :file:`/etc/postfix/smtp_password`.

The format is

    `<SMTP server> <user-name>:<password>`

::

    mail.example.net torres@example.net:********


After that update the relevant postfix database and protect it::

    $ sudo postmap /etc/postfix/smtp_password
    $ sudo chown root:root /etc/postfix/smtp_password*
    $ sudo chmod 0600 /etc/postfix/smtp_password*


Rerouting Local Mails
^^^^^^^^^^^^^^^^^^^^^

Notification and warning mails created by system programs (like cronjobs) are
usually sent to local profiles like "root", "webmaster" or other local Unix user
profiles. Since these are local profiles, their mail address is just a user id,
there is no "@" and there is no domain part.

Local mail is delivered by storing it in a mailbox the users home directory,
where it never ever will be found or read, since these "user" accounts are not
real human users.

We want these mails to be re-routed to mailboxes owned by real humans stored on
remote mail-servers. To yourself, the owner or the person responsible for this
computer.

To re-route all mails to one single address, we can use a 
:term:`Regular Expression`. Regular expression need to be defined in a map file, 
for Postfix to interpret it.

So instead of the usual :file:`/etc/aliases` file, we create a virtual alias 
table with regular expression in the map file 
:download:`/etc/postfix/virtual_alias <config-files/etc/postfix/virtual_alias>`.

.. literalinclude:: config-files/etc/postfix/virtual_alias
    :language: ini
    :linenos:


The contents of the file are cached in the database
:file:`/etc/postfix/virtual_alias.db`. That database needs a refresh every time
changes have been made to :file:`/etc/postfix/virtual_alias`:

::

    $ cd /etc/postfix
    $ sudo postmap /etc/postfix/virtual_alias


Main Configuration File
^^^^^^^^^^^^^^^^^^^^^^^

Fortunately a "null client" needs very little configuration. Just a few of lines
in the file :download:`/etc/postfix/main.cf <config-files/etc/postfix/main.cf>` 
are enough:

.. literalinclude:: config-files/etc/postfix/main.cf
    :language: ini
    :linenos:




Configuration Check
^^^^^^^^^^^^^^^^^^^

::

    $ sudo postfix check


Reload Postfix
--------------

::

    sudo systemctl reload-or-restart postfix.service
