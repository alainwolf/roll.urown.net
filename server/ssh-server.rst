SSH
===

.. contents::


.. note::

    The following is valid for *OpenSSH_7.6p1 Ubuntu-4, OpenSSL 1.0.2n  7 Dec 2017* 
    as shipped with *Ubuntu 18.04.1 LTS "Bionic Beaver"*


SSH Server
----------

.. warning::

    Please be advised that any change in the SSH-Settings of your server might
    cause problems connecting to the server or starting/reloading the SSH-Daemon
    itself. So every time you configure your SSH-Settings on a remote server via
    SSH itself, ensure that you have a second open connection to the server,
    which you can use to reset or adapt your changes!


Re-create Server Keys
^^^^^^^^^^^^^^^^^^^^^

After we improved our systems :doc:`/server/entropy`, its time to discard the
old SSH server keys, who have been created by the Ubuntu server installation
process, with a
`fresh set <http://manpages.ubuntu.com/manpages/trusty/en/man1/ssh-keygen.1.html>`_

Note that we only create *ed25519* and *RSA* keys. Other types are not
recommended.

The supported key types depend on the SSH software version. Both client and
server must support it. You can check which key types are supported by your
version of OpenSSH with the command :file:`ssh -Q key`.

::

    cd /etc/ssh
    sudo rm ssh_host_*key*
    sudo ssh-keygen -t ed25519 -f ssh_host_ed25519_key
    sudo ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key


.. note::

    Don't forget to re-distribute the new server public keys to any SSH clients
    you connect to from this host.


To create DNS server records of you key::

    ssh-keygen -r host.example.net -f ssh_host_ed25519_key.pub
    ssh-keygen -r host.example.net -f ssh_host_rsa_key


Server Configuration File
^^^^^^^^^^^^^^^^^^^^^^^^^

The server settings are stored in :file:`/etc/ssh/sshd_config`.
Change according to the example below.

The complete configuration file described here is available for
:download:`download <config-files/etc/ssh/sshd_config>` also.


Network and Protocol Settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By changing the default TCP listening port, we avoid thousands of malicious
login attempts every day.

.. note::

    Changing the TCP listening port **is not a security feature**, but keeps
    our logs more readable by avoiding this kind of junk.


It also helps, if you have multiple servers in your LAN behind a NAT.

The following small bash shell script will choose a random TCP port, which is
unlikely to interfere with other services on your server::

    $ shuf -i 49152-65535 -n 1
    63508


Add this port to your configuration:

.. literalinclude:: config-files/etc/ssh/sshd_config
    :language: ini
    :end-before: # HostKeys


Server Keys
^^^^^^^^^^^

They point to our newly created set of *ed25519* and *RSA* host keys:

.. literalinclude:: config-files/etc/ssh/sshd_config
    :language: ini
    :start-after: #ListenAddress 0.0.0.0
    :end-before: # Authentication


Authentication Settings
^^^^^^^^^^^^^^^^^^^^^^^

The *root* user is not allowed at all to login remotely. Others need their SSH
public-key installed.

Password logins are not allowed.

.. literalinclude:: config-files/etc/ssh/sshd_config
    :language: ini
    :start-after: HostKey /etc/ssh/ssh_host_rsa_key
    :end-before: # Ciphers suite selections


Ciphers Suites
^^^^^^^^^^^^^^

Similar to our :doc:`ciphers` we limit our SSH server to a safe and
recommended set of encryption algorithms and set preferences as which ones are
preferred over others.


.. note::

    The supported cipher suites are highly dependent on the SSH software. Both
    client and server must support it.


**Key exchange:**

You can check which key exchange algorithms are supported by your version of
OpenSSH with the command::

    $ ssh -Q kex


Recommended:
    * curve25519-sha256@libssh.org
    * diffie-hellman-group-exchange-sha256

Avoid if better alternatives are available:
    * ecdh-sha2-nistp521
    * ecdh-sha2-nistp384
    * ecdh-sha2-nistp256

Unknown, but probably OK:
    * curve25519-sha256
    * diffie-hellman-group14-sha256
    * diffie-hellman-group16-sha512
    * diffie-hellman-group18-sha512

Don't use:
    * diffie-hellman-group1-sha1
    * diffie-hellman-group14-sha1
    * diffie-hellman-group-exchange-sha1


**Symmetric ciphers:**

You can check which symmetric ciphers are supported by your version of
OpenSSH with the command::

    $ ssh -Q cipher


Preferred:
    * chacha20-poly1305@openssh.com

Recommended:
    * aes256-gcm@openssh.com
    * aes128-gcm@openssh.com

Avoid if better alternatives are available:
    * aes256-ctr
    * aes192-ctr
    * aes128-ctr

Don't use:
    * 3des-cbc, see :term:`3DES`
    * aes128-cbc
    * aes192-cbc
    * aes256-cbc
    * rijndael-cbc@lysator.liu.se


**Message authentication (MAC):**

You can check which message integrity codes are supported by your version of
OpenSSH with the command::

    $ ssh -Q mac


Preferred:
    * hmac-sha2-512-etm@openssh.com
    * hmac-sha2-256-etm@openssh.com
    * umac-128-etm@openssh.com

Recommended:
    * hmac-sha2-512
    * hmac-sha2-256
    * umac-128@openssh.com

Don't use:
    * hmac-sha1
    * hmac-sha1-96
    * hmac-md5
    * hmac-md5-96
    * umac-64@openssh.com
    * hmac-sha1-etm@openssh.com
    * hmac-sha1-96-etm@openssh.com
    * hmac-md5-etm@openssh.com
    * hmac-md5-96-etm@openssh.com
    * umac-64-etm@openssh.com


.. literalinclude:: config-files//etc/ssh/sshd_config
    :language: ini
    :start-after: PrintMotd
    :end-before: # Allow client to pass locale environment variables


Other Settings
^^^^^^^^^^^^^^

.. literalinclude:: config-files/etc/ssh/sshd_config
    :language: ini
    :start-after: MACs hmac-sha2-512-etm@openssh.com


Restart SSH Server
^^^^^^^^^^^^^^^^^^

After the new host keys and sevrer configurations are in place, restart the SSH
server::

    $ sudo systemctl reload ssh



SSH Client
----------

There will be SSH connections out of the server to other SSH servers (i.e. for
storing backups or accessing remote files). In that case, the server-system acts
as a client to a remote SSH server. Therefore also a "server" needs a well
configured SSH client.


Client Configuration File
^^^^^^^^^^^^^^^^^^^^^^^^^

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


Client Keys
^^^^^^^^^^^

As with the SSH server keys, we generate a fresh set of *ed25519* and *RSA*
client keys for our own user-profile::

    $ rm ~/.ssh/id_* .ssh/id_*.pub
    $ ssh-keygen -t ed25519
    $ ssh-keygen -t rsa -b 4096


The same has to be done also for the root user::

    $ sudo rm /root/.ssh/id_* /root/.ssh/id_*.pub
    $ sudo -sH ssh-keygen -t ed25519
    $ sudo -sH ssh-keygen -t rsa -b 4096


As well as for all other profiles on the system, who will initiate SSH client
connections out of this system::

    $ sudo rm /home/<username>/.ssh/id_* /home/<username>/.ssh/id_*.pub
    $ sudo -u <username> -sH ssh-keygen -t ed25519
    $ sudo -u <username> -sH ssh-keygen -t rsa -b 4096


.. note::

    Don't forget to re-distribute your public client keys to any SSH servers you
    connect to from this host.


SSH and DNS
-----------

.. warning::

    If you domain is not secured with DNSSEC, you should **NOT** use this
    feature, as the information received by the clients over DNS can not be
    trusted.


The hash of the SSH server keys can be published in DNSSEC secured domains.

By publishing a fingerprint of your SSH server public keys in DNS, connecting
clients can verify the server identity, without the need to distribute and
update your server public keys on all clients.

As of now RSA and ed25519 keys can both be published in DNS according to the
IANA assignments `DNS SSHFP Resource Record Parameters
<https://www.iana.org/assignments/dns-sshfp-rr-parameters/dns-sshfp-rr-parameters.xhtml>`_.
But OpenSSH isn't ready to read and check ed25519 fingerprints from DNS. The
message "Error calculating host key fingerprint." will be displayed and keys
need to be manually accepted.

Prerequisites
^^^^^^^^^^^^^

 * Setup your :doc:`DNS Sever </server/dns/powerdns>`
 * Secured your domain with :doc:`DNSSEC </server/dns/dnssec>`


Show DNS Record
^^^^^^^^^^^^^^^

The
`ssh-key-gen <http://manpages.ubuntu.com/manpages/trusty/en/man1/ssh-keygen.1.html>`_
utility can be used to display the fingerprints of you host keys pre-formatted
for publishing in DNS::

    $ ssh-keygen -r server.example.net. -f /etc/ssh/ssh_host_rsa_key.pub
    server.example.net. IN SSHFP 1 1 de63........................0851
    server.example.net. IN SSHFP 1 2 466b................................e409

The first line shows the SHA-1 fingerprint and the second line the SHA-256
fingeprint of our RSA key.


If you use PowerDNS server with the  :doc:`Poweradmin web interface
</server/dns/powerdns-admin>`, add the SHA-256 record as follows:

===================== ===== ============================================
Name                  Type  Content
===================== ===== ============================================
server                SSHFP 1 2 466b................................e409
===================== ===== ============================================


Testing
-------

The `CryptCheck website <https://tls.imirhil.fr/ssh/>`_ has an online SSH
test.



References
----------

* `Ubuntu Manpage: sshd_config — OpenSSH SSH daemon configuration file
  <http://manpages.ubuntu.com/manpages/bionic/en/man5/sshd_config.5.html>`_
* `Secure Secure Shell <https://stribika.github.io/2015/01/04/secure-secure-shell.html>`_
* `BetterCrypto OpenSSH <https://bettercrypto.org/static/applied-crypto-hardening.pdf#section.2.2>`_
* `MozillaWiki - Security/Guidelines/OpenSSH <https://wiki.mozilla.org/Security/Guidelines/OpenSSH>`_
