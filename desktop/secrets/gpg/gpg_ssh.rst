SSH Authentication with OpenPGP
===============================

SSH authentication can be done using OpenPGP keys instead of SSH keys.

Here are some of the advantages:

    * We only need to manage one set of public/private keys;
    * Remote system administrators can rely on their trust in our OpenPGP key;
    * No need to send public SSH keys around, as OpenPGP public keys are already
      published;
    * OpenPGP private keys can reside on hardware security devices (e.g.
      :doc:`Yubikey </desktop/secrets/yubikey/yubikey_gpg>`).

In the past, the best way to ensure that SSH remote access is given to the right
person, was to ask for SSH the public key of that person, to be sent in a
message or file signed by that persons OpenPGP private key. This widely used
practice implies that the system administrator has found a way to get the users
OpenPGP public key and that he trusts that the owner of the corresponding
private key is indeed the user requesting access.

If you already are using your OpenPGP key for SSH, the remote system
administrator can just export your public ssh key out of your public OpenPGP
key. There is no need to sign and transfer any messages or files anymore.

OpenPGP based SSH keys can also automatically be refreshed and disabled, when
the corresponding OpenPGP key has been revoked or has expired.


Disable the Gnome-Keyring SSH Agent
-----------------------------------

Usually Gnome Desktop runs its own SSH Agent as integral part of
:doc:`/desktop/secrets/gnome-keyring`. For this to work, :program:`ssh` needs to
access SSH keys trough the GnuPG Agent :command:`ssh-agent`. We therefore need
to disable the Gnome-Kerying SSH agent first for this to work.

See :ref:`disable ssh agent`.


Systemd User Environment
------------------------

In Ubuntu 20.04.1 there is a script which tells Systemd services, how to
communicate with the GnuPG SSH Agent. But it somehow lacks the execution bit.
This
`might be a bug <https://bugs.launchpad.net/ubuntu/+source/gnupg2/+bug/1901724>`_,
but for the time being ...

::

    $ sudo chmod +x /lib/systemd/user-environment-generators/90gpg-agent


Bash User Environment
---------------------

The :program:`ssh` program will try contact an SSH agent to access private keys.
The program and the agent exchange data with each other trough a UNIX socket
file. Here is how we tell :program:`ssh`, how to contact the GnuPG SSH agent.

The following lines should be added to your local profile settings file
:file:`~/.profile`::

    # Let the SSH Agent know how to communicate with GPG Agent.
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        export SSH_AUTH_SOCK
    fi


Creating an Authentication Subkey
---------------------------------

TBD.


SSH Public Key
--------------

The :program:`gpg` :command:`--export-ssh-key` command is used to extract an
OpenSSH public key from an OpenPGP public key. The OpenPGP public key needs to
be present in the local keyring.

To allow SSH access to a user on the local system by a system administrator::

    $ gpg --locate-keys john.doe@example.net
    $ gpg --export-ssh-key john.doe@example.net \
        | sudo tee /home/john/.ssh/authorized_keys


To install your own SSH public key on a remote system::

    $ gpg --export-ssh-key $GPGKEY \
        | ssh john@remote.example.net tee ~/.ssh/authorized_keys

