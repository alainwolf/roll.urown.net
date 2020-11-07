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

In the previous section, we have set our SSH client to verify the servers SSH
public key with the fingeprints published in DNS trough the **VerifyHostKeyDNS**
configuration option. Unfortunately this wont work out of the box, as the
following tests will show:

Set this to your own servers hostname for the following checks to work::

    $ export TEST_HOST=dolores.example.net

Lets check if the fingerprints of our server are present in DNS and that these
DNS records are secured by DNSSEC::

    $ dig $TEST_HOST SSHFP | egrep "ad|$"
    flags: qr rd ra ad

The **ad** flag in the DNS answer stands for "**a**\ uthenticated **d**\ ata" and
confirms that the DNS records requested have been successfully verified by
DNNSEC. But the OpenSSH client will still insist, that the fingerprints, while
visible, are not to be trusted::

    $ ssh -v $TEST_HOST logout 2>&1 | egrep "found .* in DNS|$"
    debug1: found 2 insecure fingerprints in DNS

This is caused by the GNU C library and its not just a simple bug, but a rather
complex trust issue described in
`Glibc support encryption by modifying the DNS <http://www.newfreesoft.com/programming/glibc_support_encryption_by_modifying_the_dns_5365/>`_.

Unless :file:`/etc/resolv.conf` contains **edns0** and **trust-ad** as
configuration options, programs who use the GNU C libary (glibc) like OpenSSH
and many others, aren't able to see that the :term:`DNSSEC` validation was
successful.

Nowadys the :file:`/etc/resolv.conf` file is managed by systemd, NetworkManager,
the resolvconf service or whatever you use as your
:doc:`local DNS resolver <unbound>`. Its therefore no longer possible and not
recomended to change anything in this file manually.

As as described in the
`manpage for resolv.conf(5) <https://manpages.ubuntu.com/manpages/focal/en/man5/resolv.conf.5.html>`_
as sn alternative, the options can also be set as space separated list in the
**RES_OPTIONS** environment variable, :

Let's try this out::

    $ RES_OPTIONS="edns0 trust-ad"
    $ ssh -v $TEST_HOST logout 2>&1 | egrep "found .* in DNS|$"
    debug1: found 2 secure fingerprints in DNS


.. warning::

    The following system-wide configuration settings should only be made, if
    trust your DNS resolvers and providers.
    `dnssec-trigger <unbound.html#unbound-and-dnssec-trigger>`_ can help to
    establish this trust.


Bash Environment
^^^^^^^^^^^^^^^^

To set this as a system-wide default for terminal sessions and shell scripts,
add the following file to :file:`/etc/profile.d` directory:

.. code-block:: sh

    #!/usr/bin/env bash
    #
    # Let programs who use the GNU C libary (glibc) see if DNS answers are
    # authenticated by DNSSEC. Required for OpenSSH to trust in DNSSEC-signed
    # SSHFP records.
    # See man resolv.conf(5)

    # Set the value, preserve existing if already set.
    export RES_OPTIONS="$RES_OPTIONS edns0 trust-ad"


Systemd Environment
^^^^^^^^^^^^^^^^^^^

Gnome desktop applications, like remote SFTP folders in Nautilus, may not read
your bash environment, as they are not running in your terminal session. Since
these are managed by Systemd, we set these trough a `systemd environment file
generator
<https://manpages.ubuntu.com/manpages/focal/en/man7/systemd.environment-generator.7.html>`_.

Create the systemd user environment directory::

    $ sudo mkdir -p /etc/systemd/user-evironment-generators

Create the file
:file:`/etc/systemd/user-environment-generators/90res-options` or
:download:`download it <../config-files/etc/systemd/user-environment-generators/90res-options>`

.. literalinclude:: ../config-files/etc/systemd/user-environment-generators/90res-options

It needs to be executable::

    $ sudo chmod +x /etc/systemd/user-evironment-generators/90res-options


See also
--------

You may also look at these related pages:

 * :doc:`../yubikey/yubikey_ssh`
 * :doc:`../gpg`
 * :doc:`../secrets/keys`
 * :doc:`/server/ssh-server`
