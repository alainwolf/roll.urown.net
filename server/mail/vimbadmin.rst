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

    $ export INSTALL_PATH=/var/www/vimbadmin
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


Virtual Mailbox Storage
^^^^^^^^^^^^^^^^^^^^^^^

Set the system user and groupd ID and the filesystem location for virtual
mailboxes to match our settings in the section "Mailbox Location" of
the :doc:`dovecot`:

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: defaults.list_size.multiplier
    :end-before: ;minimum mailbox password length


Password Scheme
^^^^^^^^^^^^^^^

As the login procedure is handled by Dovecot, one of Dovecots password schemes
can be selected. This should match our configuration of :doc:`dovecot` in the
section "Password Scheme".

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: defaults.mailbox.min_password_length
    :end-before: ; The path to (and initial option(s) if necessary) the Dovecot password generator.


Mailbox Archives Storage
^^^^^^^^^^^^^^^^^^^^^^^^

vimbadmin allows to archive entire mailboxes. We need to adjust the path, where
those archives are stored:

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: mailboxAliases =
    :end-before: ; Enable mailbox deletion on the file system


Mail-Server Defaults
^^^^^^^^^^^^^^^^^^^^

Default configuration settings for new accounts include the server settings for
accessing the mailboxand submitting mail messages:

The SMTP server needs to be changed to reflect a :term:`Submission` server
instead of the legacy SMTP server.

Also POP3, IMAP and Webmail access needs adjustments to server names and
encryption protocols used.

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: defaults.export_settings.allowed_subnet[] = "192.168."
    :end-before: ;; Identity



Identity
^^^^^^^^

At least the domain names have to be adjusted to your own one here:

.. literalinclude:: config/vimbadmin/application.ini
    :language: ini
    :start-after: server.webmail.user  = "%m"
    :end-before: ;; Skinning
    :emphasize-lines: 7,9,11,14,21


Database
--------

Next we create the MySQL database for ViMbAdmin::

    $ mysqladmin -u root -p create vimbadmin

And set the privileges, after creating a :doc:`secure password 
</desktop/secrets/passphrases>`::

    $ mysql -u root -p vimbadmin


.. code-block:: mysql

    GRANT ALL ON `vimbadmin`.* TO `vimbadmin`@`localhost` IDENTIFIED BY '********';
    FLUSH PRIVILEGES;
    QUIT;

We wont use the :file:`.htaccess` file with NGinx, but the script doesn't run
without it:

::

    $ cp $INSTALL_PATH/public/.htaccess.dist $INSTALL_PATH/public/.htaccess

Now the tables can be created.

::

    $ cd $INSTALL_PATH
    $ ./bin/doctrine2-cli.php orm:schema-tool:create
    ATTENTION: This operation should not be executed in a production environment.

    Creating database schema...
    Database schema created successfully!


Nginx Configuration
-------------------

Create a new web-application configuration file 
:download:`/etc/nginx/webapps/vimbadmin.conf 
</server/config-files/etc/nginx/webapps/vimbadmin.conf>`:

.. literalinclude:: /server/config-files/etc/nginx/webapps/vimbadmin.conf
    :language: nginx


Include the new web-application in your server configuration:

.. code-block:: nginx

        # ViMbAdmin - Virtual Mailbox Administration
        include             webapps/vimbadmin.conf;


Restart the Nginx webserver::

    $ sudo service nginx restart


ViMbAdmin Upgrades
------------------


::

    $ export INSTALL_PATH=/var/www/vimbadmin
    $ export NEW_VERSION=3.0.12
    $ cd $INSTALL_PATH
    $ git fetch
    $ git checkout $NEW_VERSION
    $ sudo composer self-update
    $ sudo composer update
    $ sudo chown -R www-data:www-data $INSTALL_PATH
    $ bin/doctrine2-cli.php orm:validate-schema
    $ bin/doctrine2-cli.php orm:schema-tool:update --force
