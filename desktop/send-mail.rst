Mail for Personal Computers
===========================

Usually personal computers are not set up to send mail out on their own.

However like every Linux system, their are lot of things going on in the
background, mostly invisible to the user. Their are some useful features which
are only possible if the system can tell you about.

For example, did you know that, of somebody tries to log-in on your personal
computer and fails, the system tries to notify you by mail?

This works only if the system is able to send out mails.

To install::

    $ sudo apt install postfix mailutils


The installation process will ask you a series of questions:


Postfix Configuration
---------------------

General type of mail configuration:

    Select **Satellite system**

System mail name:

    Insert your favorite domain name (does not really matter for a satellite).

SMTP relay host (blank for none):

    Your regular mail servers hostname (where you have an account and are able to send out mails)::

     [mail.example.net]:587


Root and postmaster mail recipient:

    Your own personal mail address.

Other destinations to accept mail for (blank for none)::

    $myhostname, pc, localhost.localdomain, localhost

Force synchronous updates on mail queue?

    **No**

Local networks::

    127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

Mailbox size limit (bytes)::

    51200000

Local address extension character::

    +

Internet protocols to use:

    **All**

Since the mail server we use for sending needs authentication wee need to supply
the login information.

Create or edit the file :file:`/etc/postfix/relay_password`::

    mail.example.net user@example.net:********

The format is

    <mail server hostname> <mail server login user-name>:<mail server login password>

After that update the relevant postfix database::

    $ sudo postmap relay_password




