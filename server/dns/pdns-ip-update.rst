Dynamic Updates
===============

Chances are your public IPv4 address changes from time to time.

We have to make sure that if this happens our DNS records get updated as quickly
as possible to the new address.

Since we run our own DNS server, we can do this directly on the server, or more
precisely in its MySQL database.

The MySQL query to do this looks like this:

.. code-block:: sql

    UPDATE `records` SET content = "<NEW IP ADDRESS>", change_date "<TIME_NOW>" 
        WHERE `type` = "A" AND `content` = "<OLD IP ADDRESS>";

This replaces the IPv4 addresses on every host record (A) in all domains we are
authoritative for.

To do this automatically a small script can be started as cronjob every five
minutes, which does the following:

 1. Check public IP address;
 2. Compare to known address;
 3. If its different, update database records, else exit;
 4. Exit;

Update Shell Script
-------------------

.. literalinclude:: config/pdns_update.sh
    :language: bash
    :linenos:


Database User
-------------

Create a database user **pdns_updater** with a very restrictive set of
privileges:

.. code-block:: sql

    CREATE USER 'pdns_updater'@'localhost' 
        IDENTIFIED BY '********';
    GRANT SELECT (`type`, `content`), UPDATE (`content`, `change_date`) 
        ON `pdns`.`records` TO 'pdns_updater'@'localhost';
    FLUSH PRIVILEGES;


Job Schedule
------------

To define a cronjob which runs this every five minutes::

    $ crontab -e


.. code-block:: sh

    */5 * * * * /$HOME/bin/pdns_update.sh

