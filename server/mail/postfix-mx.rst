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
^^^^^^^^^^^^^^^^^^^^^^

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
