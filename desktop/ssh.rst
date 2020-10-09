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
    Host server1.example.net
        Port 63508

    Host server2.example.net
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



Environment
-----------

Unless :file:`/etc/resolv.conf` contains **edns0** and **trust-ad** in options,
glibc using applications (like OpenSSH) aren't going to see that :term:`DNSSEC`
validation is successful. 

This affects our **VerifyHostKeyDNS** configuration option.

Since nowadys :file:`/etc/resolv.conf` is often managed automatically, one can
set these options as spacce separated list in the RES_OPTIONS environment
variable instead, as described in the manpage for :manpage:`resolv.conf`:

Add this to your :file:`~/.profile` file:

.. code-block:: sh

    # Let OpenSSH trust DNSSEC-signed SSHFP records found in DNS. Workaround for
    # https://github.com/NLnetLabs/dnssec-trigger/issues/5 
    export RES_OPTIONS="edns0 trust-ad"


See also
--------

You may also look at these related pages:

 * :doc:`yubikey/yubikey_ssh`
 * :doc:`gpg`
 * :doc:`secrets/keys`
 * :doc:`/server/ssh-server`
