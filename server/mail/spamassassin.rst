Spam Filter
===========

.. image:: SpamAssassin-logo.*
    :alt: SpamAssassin Logo
    :align: right

`SpamAssassin <http://spamassassin.apache.org/>`_ is free and open source
software used for e-mail spam filtering based on content-matching rules. It is
now part of the Apache Foundation.

SpamAssassin uses a variety of spam-detection techniques, that includes DNS-
based and fuzzy-checksum-based spam detection, :term:`Bayesian filtering`,
external programs, blacklists and online databases.

The program can be integrated with the mail server to automatically filter all
mail for a site.

Software Installation
---------------------

SpamAssassin is in the Ubuntu software package repository::

	$ sudo apt-get --install-suggests install spamassassin 


Configuration
-------------

The SpamAssassin system service and the cron-job for daily rule updates rules
update aren not enabled by default.

Open :download:`/etc/default/spamassassin <config/default/spamassassin>` and
change as follows:

.. literalinclude:: config/default/spamassassin
    :language: ini
    :lines: 7-8

.. literalinclude:: config/default/spamassassin
    :language: ini
    :lines: 28-31

Service Start
-------------

Now start Spamassassin::

	$ sudo /etc/init.d/spamassassin start

