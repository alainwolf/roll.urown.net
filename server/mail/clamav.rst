.. include:: /template_data.rst

Virus Scanner
=============

.. image:: ClamAV-logo.*
    :alt: ClamAV Logo
    :align: right

`Clam AntiVirus (ClamAV) <http://www.clamav.net/>`_ is a free and open-source,
cross-platform antivirus software tool-kit able to detect many types of
malicious software, including viruses. One of its main uses is on mail servers
as a server-side email virus scanner. *(From Wikipedia, the free encyclopedia)*

Software Installation
---------------------

ClamAV is in the Ubuntu software package repository::

	$ sudo apt-get install clamav-daemon libclamunrar6


Configuration
-------------

The default behaviour of Clamav will fit our needs. A daemon is launched
(**clamd**) and signatures are fetched every day. For more Clamav configuration
options, check the configuration files in :file:`/etc/clamav`.

Monitoring and Logs
-------------------

::

	$ multitail /var/log/clamav/freshclam.log \
			-cS clamav /var/log/clamav/clamav.log

