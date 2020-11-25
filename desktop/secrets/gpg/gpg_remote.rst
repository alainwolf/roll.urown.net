Using OpenPGP on Remote Systems
===============================

If you frequently you work on remote systems, you can use GnuPG on these
systems, without the need to transfer and install any private keys there.

You can use GnuPG as in the same way as on your local machine, while signing or
decrypting, files and mails, perform signed git operations, signing software
packages or use the GnuPG ssh-agent while opening remote sessions to further
systems or transferring files. All the while your private keys never leave your
local machine.

This is even more useful if you keep your private keys ona a hardware token
(like a :doc:`YubiKey </desktop/secrets/yubikey/index>` or a smartcard), since
you can't plug-in your hardware key in the remote system.

The GnuGP agent can be told to use an additional socket on the local system and
forward it to the remote system trough the secure SSH connection. On the remote
system that socket is then connected to the gpg-agent socket and used by gpg,
as if it where a locally running gpg-agent.


Remote System Setup
-------------------

The **remote SSH server** needs to be told how to manage these remote sockets.

Add the following line to your remote
:doc:`SSH Server</server/ssh-server>` file :file:`/etc/ssh/sshd_config`::

    # Specifies whether to remove an existing Unix-domain socket file for local
    # or remote port forwarding before creating a new one. If the socket file
    # already exists and StreamLocalBindUnlink is not enabled, sshd will be un-
    # able to forward the port to the Unix-domain socket file. This option is
    # only used for port forwarding to a Unix-domain socket file. The argument
    # must be yes or no. The default is no.
    StreamLocalBindUnlink yes


To activate this change, the remote SSH server needs a restart::

    remote$> sudo systemctl restart ssh.service
    remote$> logout
    Connection to remote.example.net closed.


Also on the **remote** system, we need to know, where the gpg-agent socket is
found::

    remote$> gpgconf --list-dir agent-socket
    /run/user/1000/gnupg/S.gpg-agent


Local System Setup
------------------

On the **local system** we need to know the location of the gpg-agent **extra
socket**::

    local$> gpgconf --list-dir agent-extra-socket
    /run/user/1000/gnupg/S.gpg-agent.extra

An additional **extra socket** is needed on the **local system**, so we can
still also use our local gpg-agent as usual.

Since we now know the locations of both the **local extra socket** and the
**remote socket**, we can set up the forward in the **local SSH client**
configuration:

.. code-block:: ini

    Host remote.example.net
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra


Personally I use a slightly different configuration, as I connect to multiple
systems with different user-ids, but have this setup only on a subset of them:

.. code-block:: ini

    # We have GPG agent sockets setup on some hosts.
    Match Host dolores.*,maeve.*,bernard.*,arnold.* User john
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra


Remote GnuPG Setup
------------------

While you now have your private keys available on the remote system, GnuPG is
not yet fully usable remotely without the public keyrings.

This is how we transfer the public keys and trust settings from the local to the
remote system::

    local$> gpg --export-options export-local-sigs --export $GPGKEY | \
                ssh remote.example.net gpg --import
    local$> gpg --export-ownertrust | \
                ssh remote.example.net gpg --import-ownertrust

You also might want to assimilate the GnuPG configuration::

    local$> scp ~/.gnupg/*.conf remote.example.net:/home/user/.gnupg/


Reference
---------

 * `How to use local secrets on a remote machine
   <https://wiki.gnupg.org/AgentForwarding>`_