.. _amavis2:

Mail Filter
===========

.. image:: Amavis-logo.*
    :alt: Amavis Logo
    :align: right

`Amavis <http://www.amavis.org/>`_ is an open source content filter for
electronic mail, implementing mail message transfer, decoding, some processing
and checking, and interfacing with external content filters to provide
protection against :index:`spam`, :index:`viruses <single: virus>` and other
malware. It can be considered an  interface between a mailer (MTA, Mail Transfer
Agent) and one or more content  filters.

We will use Amavis for the following tasks:

*   DKIM signing our outgoing mails.
*   Checking DKIM signatures of incoming mails.
*   Scanning all mails for viruses (using ClamAV).
*   Scanning inccoming mails for spam (using SpamAssassin).

Software Installation
---------------------

Amavis is available as package in the Ubuntu software repository::

    $ sudo apt-get install amavisd-new

The installation creates the following items:

 * The system user and group **amavis**.
 * The directory :file:`/etc/amavis` with configuration files.
 * The directory :file:`/usr/share/amavis/conf.d/` with read-only configuration 
   files.
 * The directory :file:`/var/lib/amavis`
 * The directory :file:`/usr/share/doc/amavis-new` with documentation and 
   configuration examples.
 * The system service **amavis** (see :file:`/etc/init.d/amavis`)


Additional Archive Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^

With the following software packages installed, it will be possible to look
inside various types of file-archives and scan the contents for viruses::

    $ sudo apt-get install arj cabextract lzop nomarch p7zip-full rar ripole rpm2cpio unrar-free zip zoo

The following documentation is relevant to our installation and will be used as
reference for what lies ahead:

    * :file:`/usr/share/doc/amavis-new/amavisd-new-docs.html`
    * :file:`/usr/share/doc/amavis-new/README.debian.gz`
    * :file:`/usr/share/doc/amavis-new/NEWS.Debian.gz`
    * :file:`/usr/share/doc/amavis-new/README.postfix.html`

Note that any Ubuntu specific notes are included in the above Debian files by
the Ubuntu package maintainers.


Group Memberships
-----------------

Add **clamav** user to the **amavis** group and vice versa in order for Clamav
to have access to the files it needs to scan::

    $ sudo adduser clamav amavis
    $ sudo adduser amavis clamav


Configuration
-------------

Enable Scanning for Virus and Spam
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mail content scanners are disabled by deafult. To activate them open 
:download:`/etc/amavis/conf.d/15-content_filter_mode 
<config/amavis/15-content_filter_mode>` and uncomment the following lines:

.. literalinclude:: config/amavis/15-content_filter_mode
    :language: perl
    :lines: 6-14

.. literalinclude:: config/amavis/15-content_filter_mode
    :language: perl
    :lines: 17-25

Database for Virtual Domains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Amavis needs to be able to lookup our hosted virtual mail-domains to decide if a
mail is incoming or outgoing.

We create the :download:`/etc/amavis/conf.d/50-user <config/amavis/50-user>` and 
define the database server connection there.

Use the same credentials as we defined in the database connection of our 
:doc:`ViMbAdmin </server/mail/vimbadmin>` configuration.

.. literalinclude:: config/amavis/50-user
    :language: perl


Service Re-Start
----------------

Now re-start Amavis::

    $ sudo service amavis restart


Reference
---------

    * `Integrating amavisd-new in Postfix <http://www.amavis.org/README.postfix.html>`_

