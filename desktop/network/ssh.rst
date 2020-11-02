Secure-Shell
============

.. note::

    The following is valid for *OpenSSH_8.2p1 Ubuntu-4, OpenSSL 1.1.1f  31 March 2020* 
    as shipped with *Ubuntu 20.04 LTS "Focal Fossa"*. 
    See the `OpenSSH release notes <https://www.openssh.com/releasenotes.html>`_
    for changes since the 7.6 release that came with Ubuntu 18.04.


SSH Server
----------

::

    sudo apt install ssh molly-guard



SSH Client
----------

Client Configuration File
-------------------------

The system-wide default client settings are stored in
:file:`/etc/ssh/ssh_config`. 

Change according to the example below:

.. code-block:: sh

    #
    # Our own servers
    #
    Host dolores.example.net
        Port 63508

    Host maeve.example.net
        Port 49208
        User admin

    Host *.example.net
        ForwardAgent Yes
        StrictHostKeyChecking Yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra

    Host github.com
        User git

    #
    # Global options
    #
    Host *
        HashKnownHosts No
        VerifyHostKeyDNS Yes
        StrictHostKeyChecking Ask



OpenSSH's Trust in DNSSEC
-------------------------

.. warning::

    The following steps imply that you fully trust your DNS resolvers and
    providers.


This affects our **VerifyHostKeyDNS** configuration option.

::

    $ dig dolores.example.net SSHFP | egrep --color "ad|$"
    flags: qr rd ra ad

While the **ad** flag in the DNS answer confirms that the data has been
successfully verified by DNNSEC, the OpenSSH client keeps insisting, they are
not to be trusted.

::

    $ ssh -v dolores.example.net logout 2>&1 | egrep --color "found .* in DNS|$"
    debug1: found 2 insecure fingerprints in DNS

This is caused by the GNU C library and its not just a simple bug, but a rather
complex trust issue described in
`Glibc support encryption by modifying the DNS <http://www.newfreesoft.com/programming/glibc_support_encryption_by_modifying_the_dns_5365/>`_.

Unless :file:`/etc/resolv.conf` contains **edns0** and **trust-ad** as
configuration options, programs who use the GNU C libary (glibc) like OpenSSH
and many others, aren't able to see that the :term:`DNSSEC` validation was
successful.

Nowadys the :file:`/etc/resolv.conf` file is managed by systemd, NetworkManager,
or whatever software you use as your
:doc:`local DNS resolver <unbound>`. 

As an alternative, the options can be set as space separated list in the
**RES_OPTIONS** environment variable, as described in the manpage for
:manpage:`resolv.conf`:

Let's try it out::

    $ RES_OPTIONS="edns0 trust-ad" 
    $ ssh -v dolores.example.net logout 2>&1 | egrep --color "found .* in DNS|$"
    debug1: found 2 secure fingerprints in DNS


Bash User Environment
^^^^^^^^^^^^^^^^^^^^^

To set this as default for your terminal sessions, add the following lines your
:file:`~/.profile` file:

.. code-block:: sh

    # Let Gnu C libary programs see if DNS answers are authenticated by DNSSEC.
    # Required for OpenSSH to trust in DNSSEC-signed SSHFP records.
    export RES_OPTIONS="$RES_OPTIONS edns0 trust-ad"


Systemd Environment
^^^^^^^^^^^^^^^^^^^

You might need this for your own Systemd user services too, so its set also
in your Gnome graphical desktop environnment. This way SSHFP fingerprinte will 
also be verified, while accessing remote filesystems with SFTP in Nautilus.

Create a systemd-environment directory::

    $ mkdir -p ~/.config/systemd/user-environment-generators/

Create a file :download:`~/.config/systemd/user-environment-generators/90res-options <../config-files/systemd/user-environment-generators/90res-options>`
    
.. literalinclude:: ../config-files/systemd/user-environment-generators/90res-options



See also
--------

You may also look at these related pages:

 * :doc:`../yubikey/yubikey_ssh`
 * :doc:`../gpg`
 * :doc:`../secrets/keys`
 * :doc:`/server/ssh-server`
