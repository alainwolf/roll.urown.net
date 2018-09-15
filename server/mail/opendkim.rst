DomainKeys Identified Mail (DKIM)
=================================

`DomainKeys Identified Mail (DKIM) <http://en.wikipedia.org/wiki/DKIM>`_ is an
email validation system designed to detect email spoofing by providing a
mechanism to allow receiving mail exchangers to check that incoming mail from a
domain is authorized by that domain's administrators and that the email
(including attachments) has not been modified during transport. A digital
signature included with the message can be validated by the recipient using the
signers public key published in the DNS. In technical terms, DKIM is a technique
to authorize the domain name which is associated with a message through
cryptographic authentication.

We use `OpenDKIM <http://www.opendkim.org/>`_  for signing our outgoing mails
and verifying any incoming mails. OpenDKIM is a mail-filter (aka "milter") for
Postfix.


Installation
------------

OpenDKIM is in the Ubuntu software package repository::

    $ sudo aptitude install opendkim opendkim-tools


The package installs ...

 * The system user and group **opendkim**
 * The configuration files :file:`/etc/opendkim.conf` and 
   :file:`/etc/default/opendkim`
 * The system service :file:`opendkim` in the :file:`/etc/init.d` directory
 * A runtime directory :file:`/var/run/opendkim/` for the PID file and UNIX 
   socket.
 * Various binaries and tools in :file:`/usr/bin`:
       * opendkim
       * opendkim-atpszone 
       * opendkim-genkey
       * opendkim-genzone 
       * opendkim-spam 
       * opendkim-stats
       * opendkim-testadsp 
       * opendkim-testkey   
       * opendkim-testmsg


Configuration
-------------

Allow Access for Postfix
^^^^^^^^^^^^^^^^^^^^^^^^

To allow our Postfix MTA to interact with OpenDKIM, the user running postfix
needs access to some OpenDKIM files, especially the UNIX socket path to connect
with OpenDKIM. This can be achieved by adding the postfix user to the opendkim
group::

    $ usermod -g mail opendkim


Create Signing Keys
^^^^^^^^^^^^^^^^^^^

Mails sent out trough our mail-server will be signed using 1024bit RSA keys. So
receiving mail-servers can verify that they have been sent by us and nobody has
tampered with them along the way.

To create those RSA keys the `opendkim-genkey 
<http://manpages.ubuntu.com/manpages/trusty/en/man8/opendkim-genkey.8.html>`_ 
tool can be used::

    $ opendkim-genkey --directory=/etc/mail --selector=${HOSTNAME} --testmode


Configuration File
^^^^^^^^^^^^^^^^^^

Configuration is in the file :download:`/etc/opendkim.conf
<config/opendkim.conf>` and described in the manpage `opendkim.conf(5)
<http://manpages.ubuntu.com/manpages/trusty/man5/opendkim.conf.5.html>`_


.. literalinclude:: config/opendkim.conf
    :language: shell


References
----------
 * `OpenDKIM README file <http://www.opendkim.org/opendkim-README>`_
 * `Ubuntu Community Help Wiki - Postfix DKIM 
   <https://help.ubuntu.com/community/Postfix/DKIM>`_
 * `Wikipedia on DKIM <http://en.wikipedia.org/wiki/DKIM>`_