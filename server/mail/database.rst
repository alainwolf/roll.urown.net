Mail Server Database
====================

Preparing the database
----------------------

Create and store a password for postfix to access the database in
:doc:`/desktop/keepassx`.

Create the mail-server database::

    $ mysqladmin -u root -p create mailserver


Create a database user for the mail-server to access the database::

    $ mysql -u root -p mailserver

.. code-block:: mysql

    GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1' 
        IDENTIFIED BY '********';

    FLUSH PRIVILEGES;
    EXIT;


Create a SQL file :file:`mailserver-tables.sql` with the following contents:

.. literalinclude:: mailserver-tables.sql
    :language: mysql
    :linenos:

The complete configuration file described here is available for 
:download:`download <mailserver-tables.sql>` also.

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
      '1', '1', MD5( 'summersun' ) , 'john@example.org'
    );


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
