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
:download:`/server/config-files/etc/postfix/mx-main.cf` here.

General Settings
^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # General Mail Server Setttings
    :end-before: # Local Aliases Map


Local Aliases Map
^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Local Aliases Map
    :end-before: # Virtual Relay Maps


Virtual Relay Maps
^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Virtual Relay Maps
    :end-before: # Mail Queue Settings


Mail Queue Settings
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Mail Queue Settings
    :end-before: # TCP/IP Protocols Settings


TCP/IP Protocols Settings
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # TCP/IP Protocols Settings
    :end-before: # General TLS Settings


General TLS Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # General TLS Settings
    :end-before: # SMTP Client Settings


SMTP Client Settings
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTP Client Settings
    :end-before: # SMTP Server Settings


SMTP Server Settings
^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTP Server Settings
    :end-before: # SMTP Relay Restrictions


SMTP Relay Restrictions
^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTP Relay Restrictions
    :end-before: # SMTP Server Restrictions


SMTP Server Restrictions
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # SMTP Server Restrictions
    :end-before: # Mail Filters (Milters)


Mail Filters (Milters)
^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/postfix/mx-main.cf
    :language: ini
    :linenos:
    :lineno-match:
    :start-at: # Mail Filters (Milters)

