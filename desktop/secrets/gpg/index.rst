.. image:: gnupg-logo.*
    :alt: GNU Privacy Guard Logo
    :align: right


OpenPGP
=======

`GnuPG <https://gnupg.org/>`_ allows to encrypt and sign your data and
communication, features a versatile key management system as well as access
modules for all kinds of public key directories.

GnuPG is a complete and free implementation of the OpenPGP standard as defined
by :RFC:`4880` (also known as `PGP or Pretty Good Privacy
<https://en.wikipedia.org/wiki/Pretty_Good_Privacy>`_).

.. note::

    Throughout this documentation we assume GnuPG version 2.2.x as
    pre-installed in Ubuntu 20.04.


Contents:

.. toctree::
    :maxdepth: 1

    gpg_setup
    gpg_keys
    gpg_publish
    gpg_ssh
    gpg_remote
    gpg_tools

.. contents::
    :depth: 2
    :local:
    :backlinks: top


Yubikey Neo
^^^^^^^^^^^

Store your private keys on a secure hardware device, and use it everywhere,
instead of storing the as files on disks.

See :doc:`/desktop/secrets/yubikey/yubikey_gpg`.


Enigmail
^^^^^^^^

Encrypt, decrypt, digitally sign and verify your mail communications.

See :doc:`/desktop/thunderbird`.


References
----------

 * `Ubuntu GNU Privacy Guard How To
   <https://help.ubuntu.com/community/GnuPrivacyGuardHowto>`_

 * `Gnu Privacy Guard 2.2.4 manpage
   <https://manpages.ubuntu.com/manpages/bionic/en/man1/gpg.1.html>`_

 * `GnuPG Agent manpage
   <http://manpages.ubuntu.com/manpages/bionic/man1/gpg-agent.1.html>`_


