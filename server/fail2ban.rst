Fail2Ban
========

.. image:: fail2ban-logo.*
    :alt: Fail2Ban Logo
    :align: right

`Fail2Ban <http://www.fail2ban.org/>`_ is an intrusion prevention software
framework that protects computer servers from brute-force attacks. Written in
the Python programming language, it is able to run on POSIX systems that have an
interface to a packet-control system or firewall, for example, iptables or TCP
Wrapper.


Software Installation
---------------------

fail2ban is available as package in the Ubuntu software repository.

.. warning::

	Note that the package installed by the current LTS version of Ubuntu Xenial
	(16.04) doesn't support IPv6.

::

	$ sudo apt update
	$ sudo apt install fail2ban


