.. index::
    single: Internet Protocols; SMTP

MX - Mail Exchange Servers
==========================

.. image:: Postfix-logo.*
    :alt: Postfix Logo
    :align: right

`Postfix <http://www.postfix.org/>`_ is a free and open-source mail transfer
agent (MTA) that routes and delivers electronic mail on a Linux system. It is
estimated that around 26% of public mail servers on the internet run Postfix.

.. contents:: \


Prerequisites
-------------

    * :doc:`/server/dns/unbound`
    * :doc:`/server/mariadb/index`
    * :doc:`/server/mail/rspamd`
    * :doc:`/server/dehydrated`
    * :doc:`/server/mail/mta-sts`


Install Software
----------------

::

    $ sudo apt-get install postfix postfix-mysql


On Ubuntu server 20.04 (focal) the installed version is Postfix version 3.4.13,
released on June 14, 2020.


Main Configuration
---------------------

Postfix uses a number of different configuration files, with the
:file:`/etc/postfix/main.cf` being the most important.

The documentation website has `a page dedicated to main.cf
<http://www.postfix.org/postconf.5.html>`_ which includes every possible
configuration paramter.

The whole file, as presented below, is also provided for download at
:download:`/server/config-files/etc/postfix/main-mx.cf` here.


General Mail Server Setttings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # General Mail Server Setttings
    :end-before: # Trusted (allowed to relay) Networks Maps


Trusted Networks Maps
^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Trusted (allowed to relay) Networks Maps
    :end-before: # Local & Virtual (Relay) Domains and Aliases Maps


Local & Virtual Domains and Aliases Maps
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Local & Virtual (Relay) Domains and Aliases Maps
    :end-before: # Relayed and Outgoing Mail Transport Maps


Relayed and Outgoing Mail Transport Maps
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Relayed and Outgoing Mail Transport Maps
    :end-before: # TCP/IP Protocols Settings


TCP/IP Protocols Settings
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # TCP/IP Protocols Settings
    :end-before: # General TLS Settings


General TLS Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # General TLS Settings
    :end-before: # SMTP TLS Client Settings


SMTP TLS Client Settings
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTP TLS Client Settings
    :end-before: # SMTPD TLS Server Settings


SMTPD TLS Server Settings
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTPD TLS Server Settings
    :end-before: # SMTPD Server Relay Restrictions


SMTPD Server Relay Restrictions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTPD Server Relay Restrictions
    :end-before: # SMTPD Server Restrictions


SMTPD Server Restrictions
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTPD Server Restrictions
    :end-before: # Spam Filter (Milter) and DKIM Mail Message Signing


Spam Filter (Milter) and DKIM Mail Message Signing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/main-mx.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Spam Filter (Milter) and DKIM Mail Message Signing


Systemd Service Dependencies
----------------------------

Our Postfix MX depends on various other services, we want to ensure that
Postfix is always able to connect to them while running:

    * Wireguard VPN network interface
    * MariaDB database server
    * Rspamd Spam Filter
    * ClamAV virus scanner
    * Postfix MTA-STS resolver

The Systemd services file for the Postfix server
:file:`/lib/systemd/system/postfix@.service` is created as part of the software
package installation. The recommended method is to create a Systemd
override-file and not change anything in the provided service file, as it
would be lost on software package updates.

You can create a override file easily with the help of the
:command:`systemctl` command::

    $ sudo systemctl edit postfix@.service

This will start your editor with an empty file, where you can add your own
custom Systemd service configuration options.

.. code-block:: ini

    [Unit]
    After=sys-devices-virtual-net-wg0.device
    After=mariadb.service rspamd.service clamav-daemon.service postfix-mta-sts-resolver.service
    BindsTo=sys-devices-virtual-net-wg0.device mariadb.service

The configuration statement :code:`After=mariadb.service` ensures that
:code:`mariadb.service` is fully started up before the :code:`postfix@.service`
is started.

The line :code:`BindsTo=mariadb.service` ensures that if the Database
service is stopped, the PowerDNS server will be stopped too.

After you save and exit of the editor, the file will be saved as
:file:`/etc/systemd/system/postfix@.service.d/override.conf` and Systemd will
reload its configuration::

    systemctl show postfix@.service |grep -E "After=|BindsTo="
