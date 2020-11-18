.. image:: seahorse-logo.*
    :alt: Seahorse Logo
    :align: right


Gnome Keyring
=============

`The Gnome Keyring <https://wiki.gnome.org/Projects/GnomeKeyring>`_ sometimes
also called "Passwords and Keys" is the default manager of all your secrets
during the lifetime of your Ubuntu Desktop session.

It is an integral part of the Ubuntu Desktop system and therefore installed by
default.

The keyring is a database storage belonging to your user-profile. It is
encrypted with your login pass-phrase and tied to your session. Once you log
out, the keyring and everything in it is closed.

The next time you log on, the keyring is decrypted and every login credential is
available again, while you only need to remember your Ubuntu Desktop password.

This means that all passwords, pass-phrases, used by any application or network
connection during a desktop session is managed and remembered in the keyring.

.. note::

    While having a integrated solution on your desktop to manage your secrets is
    convenient, it remains a local solution confined to your Ubuntu desktop
    system.

    Gnome Keyring is not available on other platforms and systems and its not
    even easy to transfer or even sync your key-rings to other Ubuntu Desktop
    systems you might use.

    The Mozilla products Firefox and Thunderbird use their own password and
    certificates storage. Therefore login credentials for websites and mail
    servers are not managed by the Gnome Keyring.

    Gnome Keyring also manages access to your SSH keys and TLS (x.509)
    certificates and keys. Unfortunately these Gnome Keyring *agents* are no
    longer compatible with newer versions of OpenSSH.


To use the current native versions of the agent for OpenSSH we need to to
disable the Gnome Keyring agent.


Disabling the Gnome Keyring SSH Agent
-------------------------------------

 * It doesn't handle newer SSH key formats (ed22519, etc);
 * It loads all keys in ~/.ssh automatically at startup;
 * You cannot remove these keys, even with ``ssh-add -D``, and...
 * The agent does not respect certain important constraints on added keys, such
   as the ``-c`` option, to be sure I have to confirm the use of loaded keys;

The agent is started automatically on every login by the desktop-file
:file:`gnome-keyring-ssh.desktop` in the system configuration folder
:file:`/etc/xdg/autostart/`. You can disable it by copying the desktop file to
your user configuration folder :file:`~/.config/autostart` and then adding
configuration directives to disable autostart. Since user specific configuration
takes precedence over system-wide settings, only your personal desktop-file will
be used.

Copy the desktop file::

    $ mkdir -p ~/.config/autostart
    $ cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/


Add the lines to disable autostart::

    $ echo 'X-GNOME-Autostart-enabled=false' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop

    $ echo 'Hidden=true' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop

    $ echo 'NoDisplay=false' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop


This will be active on your next login. For your current session, restart (aka
"replace") the already running Gnome Keyring Daemon, without the agent part::

    $ /usr/bin/gnome-keyring-daemon --replace --components keyring,pkcs11


Another way might be available, depending on your Ubuntu Desktop version:

 1. Open the Startup Applications manager, by pressing :kbd:`Super` and typing
    ``session``.

 2. Uncheck the "SSH Agent" entry.

 3. Restart your session by logging out and logging in again.

