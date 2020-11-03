SSH User Authentication with Yubikey
====================================

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right

A YubiKey with OpenPGP can be used for logging in to remote SSH servers. In this
setup, the Authentication sub-key of an OpenPGP key is used as an SSH key to
authenticate against the server.


Prerequisites
-------------

* :doc:`index`

* :doc:`yubikey_gpg`


Disable GNOME's GnuPG and SSH Agents
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Disable autostart::

    $> mkdir -p ~/.config/autostart
    $> echo 'X-GNOME-Autostart-enabled=false' \
          | cat /etc/xdg/autostart/gnome-keyring-gpg.desktop - \
              >> ~/.config/autostart/gnome-keyring-gpg.desktop
    $> echo 'X-GNOME-Autostart-enabled=false' \
          | cat /etc/xdg/autostart/gnome-keyring-ssh.desktop - \
              >> ~/.config/autostart/gnome-keyring-ssh.desktop

Kill and restart any running keyring-daemon::

    $> pkill /usr/bin/gnome-keyring-daemon
    $> /usr/bin/gnome-keyring-daemon --components keyring,pkcs11


GPG Agent Configuration
-----------------------

Enable the agents SSH support::

    $> echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf


Restart any running GPG agent::

    $> gpg-connect-agent killagent /bye
    $> gpg-connect-agent /bye


Add the location of the SSH authentication socket to your :file:`~/.bashrc` 
file::

    $> echo "export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh" >> ~/.bashrc


SSH Public Key
--------------

To distribute your SSH public key derived from your OpenPGP authentication key::

  $> gpg --export-ssh-key $GPGKEY | ssh user@remote.example.net tee ~/.ssh/authorized_keys
