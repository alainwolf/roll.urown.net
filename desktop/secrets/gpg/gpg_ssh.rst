SSH Authentication with an OpenPGP Key
======================================

Disable the Gnome SSH Agent
---------------------------

Disable autostart of the Gnome SSH agent::

    $ mkdir -p ~/.config/autostart
    $ cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
    $ echo 'X-GNOME-Autostart-enabled=false' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop
    $ echo 'Hidden=true' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop


Restart any Gnome keyring daemon which might already be running::

    $ /usr/bin/gnome-keyring-daemon --replace --components keyring,pkcs11


Systemd User Environment
^^^^^^^^^^^^^^^^^^^^^^^^

In Ubuntu 20.04.1 there is a script which tells SystemD services, how to
communicate with the GnuPG SSH Agent. But it somehow lacks the execution bit.
This
`might be a bug <https://bugs.launchpad.net/ubuntu/+source/gnupg2/+bug/1901724>`_,
but for the time being ...

::

    $ sudo chmod +x /lib/systemd/user-environment-generators/90gpg-agent


Bash User Environment
---------------------

The following lines should be added to your local profile settings file
:file:`~/.profile`::


    # Let the SSH Agent know how to communicate with GPG Agent.
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        export SSH_AUTH_SOCK
    fi
