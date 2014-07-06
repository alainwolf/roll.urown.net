Administration Web Interface
============================

.. image:: ViMbAdmin-logo.*
    :alt: ViMbAdmin Logo
    :align: right

The `ViMbAdmin <http://www.vimbadmin.net/>`_ project (vim-be-admin) provides a
web based virtual mailbox administration system allowing mail administrators to
manage domains, mailboxes and aliases.

.. contents:: \ 

Software Installation
---------------------

ViMbAdmin is not in the Ubuntu software package repository.

ViMbAdmin is written in PHP and can be installed using the :term:`composer`
dependencies managegement system for PHP. But for  this to work we need to
install :term:`composer` first.

::

    $ curl -sS https://getcomposer.org/installer | www-data php
    $ sudo mv composer.phar /usr/local/bin/composer


As per `installation instructions 
<https://github.com/opensolutions/ViMbAdmin/wiki/Installation>`_ in their Wiki
we define and create a installation directory:

::

    $ export INSTALL_PATH=/var/www/server.lan/public_html/vimbadmin
    $ mkdir -p $INSTALL_PATH
    $ sudo chown www-data:www-data $INSTALL_PATH
    $ cd $INSTALL_PATH


Done that ViMbAdmin can be installed:

::

    $ composer create-project opensolutions/vimbadmin $INSTALL_PATH -s dev


Answer **"No"** when asked: *"Do you want to remove the existing VCS (.git, 
.svn..) history?"*


Configuration
-------------

Next we copy the sample configuration file to create a configuration for our
server. Assuming you are still in the :file:`$INSTALL_PATH` directory:

::

    $ cp application/configs/application.ini.dist application/configs/application.ini


Open the file :download:`application/configs/application.ini 
<config/vimbadmin/application.ini>`.


Installation Keys and Salts
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :lines: 17-26


Database Connection
^^^^^^^^^^^^^^^^^^^

Find the lines with database connection 
settings and set the password:

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: resources.frontController.params.displayExceptions
    :end-before: ;; Doctrine2 requires Memcache for maximum efficency
    :emphasize-lines: 9


Database
--------

Next we create the MySQL database for ViMbAdmin::

    $ mysqladmin -u root -p create vimbadmin

And set the privileges, after creating a secure password with 
:doc:`/desktop/keepassx`::

    $ mysql -u root -p vimbadmin


.. code-block:: mysql

    GRANT ALL ON `vimbadmin`.* TO `vimbadmin`@`localhost` IDENTIFIED BY '********';
    FLUSH PRIVILEGES;
    QUIT;


Now the tables can be created.

::

    $ ./bin/doctrine2-cli.php orm:schema-tool:create
