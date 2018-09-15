Web-based Administration
------------------------

.. image:: phpMyAdmin-logo.*
    :alt: phpMyAdmin Logo
    :align: right

`phpMyAdmin <http://www.phpmyadmin.net/>`_ is a free software tool written in
PHP, intended to handle the administration of MySQL over the Web. phpMyAdmin
supports a wide range of operations on MySQL, MariaDB and Drizzle. Frequently
used operations (managing databases, tables, columns, relations, indexes, users,
permissions, etc) can be performed via the user interface, while you still have
the ability to directly execute any SQL statement.


Download and Install
^^^^^^^^^^^^^^^^^^^^

Due to their frequent updates, its easier to clone their STABLE branch from
GitHub, instead of download, unpacking and installing packages, along with
moving configuration files around.

::

    $ cd /var/www/server/public_html/
    $ sudo -u www-data -s
    $ git clone --branch STABLE --depth=1 git://github.com/phpmyadmin/phpmyadmin.git
    $ cd phpmyadmin
    $ composer update --no-dev

The ``git clone`` command creates a new sub-directory on the local system and
fills it with the contents of a remote repository.

Where:
 * ``--branch STABLE`` refers to the STBALE branch of their GitHub repository;
 * ``--depth=1`` selects only latest changes, without fetching the whole commit history.


Configuration
^^^^^^^^^^^^^

Create a configuration-setup directory with write-access to everybody::

    $ mkdir /var/www/server/public_html/phpmyadmin/config
    $ chmod o+rw /var/www/server/public_html/phpmyadmin/config

Now point your browser to `<https://server.lan/phpmyadmin/setup/>`_. A
configuration file will be created where you make the necessary settings.

When done save the configuration and move the created configuration file to the
phpmyadmin root directory, remove write-access and delete the :file:`config`
subdirectory::

    $ mv /var/www/server/public_html/phpmyadmin/config/config/config.inc.php \
        /var/www/server/public_html/phpmyadmin/
    $ chmod o-rw /var/www/server/public_html/phpmyadmin/config.inc.php
    $ rm -rf /var/www/server/public_html/phpmyadmin/config
    $ exit


Upgrade
^^^^^^^

Download  and install the new version in its version specific directory::


    $ cd /var/www/server/public_html/phpmyadmin
    $ sudo -u www-data -s
    $ git pull -q origin STABLE
    $ composer update --no-dev
    $ exit

Done.
