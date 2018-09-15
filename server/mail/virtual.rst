Virtual Domains and Mailboxes
=============================

Aside from us the system administrators, there are no human users working
interactively on the server. The typical user works on his own device and
accesses services on the server. The server contains websites, delivers mails,
synchronizes files and delivers instant messages under the hosted domain names
and various accounts on each domain. This concept is known as virtual domains
and users. Virtual becuase unlike real users, they don't work on the server-
system interactively like on their own devices.

In the case of virtual mail, the mailbox-accounts are referenced in a database
instead of the system user-profiles and the incoming mails are stored in a
virtual mailbox directory instead of the users home-directory.


Virtual Mail User and Group
---------------------------

Following we create a system user profile and group to access the virtual mailbox
directory.

::
    
    $ sudo addgroup --gid 5000 vmail
    $ sudo adduser  --system --uid=5000 --ingroup vmail --home /var/vmail vmail

This creates the user and group **vmail** and also the directory
:file:`/var/vmail` where mails will be stored.


Mail Server Database
--------------------


Preparing the database
^^^^^^^^^^^^^^^^^^^^^^

:doc:`Create and store a password </desktop/secrets/passphrases>` for 
postfix to access the database.

Create the mail-server database::

    $ mysqladmin -u root -p create mailserver


Create a database user for the mail-server to access the database::

    $ mysql -u root -p mailserver

.. code-block:: mysql

    GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1' 
        IDENTIFIED BY '********';

    FLUSH PRIVILEGES;
    EXIT;


Create a SQL file :download:`mailserver-tables.sql
<config/mailserver-tables.sql>` with the following contents:

.. literalinclude:: config/mailserver-tables.sql
    :language: mysql
    :linenos:

Add the tables to the mail-server database::

    $ mysql -u root -p mailserver < mailserver-tables.sql


Adding a Domain
^^^^^^^^^^^^^^^

::

    $ mysql -u root -p mailserver

.. code-block:: mysql

    INSERT INTO `mailserver`.`virtual_domains` (
      `id` ,
      `name`
    )
    VALUES (
      '1', 'example.org'
    );


Adding a Mailbox
^^^^^^^^^^^^^^^^

::

    $ mysql -u root -p mailserver

.. code-block:: mysql

    INSERT INTO `mailserver`.`virtual_users` (
            `id` ,
            `domain_id` ,
            `password` ,
            `email`
        )
        VALUES (
            '1', 
            '1', 
            ENCRYPT (
                '********', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))
            ), 
            'email1@example.net'
    );

The above encrypts the password with 512-bit SHA-2 before it is stored in the
database.


Adding an Alias
^^^^^^^^^^^^^^^

::

    $ mysql -u root -p mailserver

.. code-block:: mysql

    INSERT INTO `mailserver`.`virtual_aliases` (
      `id`,
      `domain_id`,
      `source`,
      `destination`
    )
    VALUES (
      '1', '1', 'jack@example.org', 'john@example.org'
    );
