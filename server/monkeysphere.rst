.. image:: monkeysphere-logo.*
    :alt: Monkeysphere Logo
    :align: right


Monkeysphere
============

The `Monkeysphere <http://web.monkeysphere.info/>`_ tools allow to verify secure
connections, servers and clients, without the need to trust any (often
commercial) third party.

Instead the proven Web-of-Trust from PGP is used to certify secure connections.

Currently this can be used to verify TLS/SSL servers and SSH servers and clients.


Software-Installation
---------------------

Monkeysphere is in the Ubuntu Software repository, but those packages are often
out of date. Installation from the projects own repositories is recommended.


Software Package Signing Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Software packages published by the Monkeysphere project are signed with their
own release key.

Your Ubuntu system needs to trust the "Monkeysphere Archive Signing Key" to be
able to verity and install software packages from the Monkeysphere project::

    $ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x18e667f1eb8af314


Software Package Repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo add-apt-repository 'deb http://archive.monkeysphere.info/debian experimental monkeysphere'


Software Installation
^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo apt-get install monkeysphere


Let SSH clients verify your server
----------------------------------


