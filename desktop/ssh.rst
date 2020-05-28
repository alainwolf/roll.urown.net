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
:file:`/etc/ssh/ssh_config`. Change according to the example below:

.. code-block:: sh

    # Github sometimes needs diffie-hellman-group-exchange-sha1
    Host github.com
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1

    Host *
        HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com




