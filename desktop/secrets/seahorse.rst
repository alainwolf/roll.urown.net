

.. image:: seahorse-logo.*
    :alt: Seahorse Logo
    :align: right


Seahorse
========

`Seahorse <https://wiki.gnome.org/Projects/GnomeKeyring>`_ also called the
"Gnome Keyring" or "Passwords and Keys" is the default manager of all your
secrets during the lifetime of your Ubuntu Desktop session.

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

    Seahorse is not available on other platforms and systems and its not even
    easy to transfer or even sync your key-rings to other Ubuntu Desktop systems
    you might use.

    The Mozilla products Firefox and Thunderbird use their own password and
    certificates storage. Therefore login credentials for websites and mail
    servers are not managed by Seahorse.

    Seahorse also manages access to your GnuGP keys, SSH keys and TLS (x.509)
    certificates and keys. Unfortunately these Seahorse *agents* are no longer
    compatible with newer versions of GnuPG and OpenSSH.


To use the current native versions of the agents for GnuPG and OpenSSH we need
to to disable the Seahorse agents.


Disabling the Seahorse SSH-Agent
--------------------------------

 * It doesn't handle newer SSH key formats (ed22519, etc);
 * It loads all keys in ~/.ssh automatically at startup;
 * You cannot remove these keys, even with ``ssh-add -D``, and...
 * The agent does not respect certain important constraints on added keys, such
   as the ``-c`` option, to be sure I have to confirm the use of loaded keys;

Disable the agent in the Gnome/Unity autostart folder
:file:`/etc/xdg/autostart/`::

    $ sudo editor /etc/xdg/autostart/gnome-keyring-ssh.desktop

Change or add the following lines:

 * ``NoDisplay=false``;
 * ``X-GNOME-Autostart-enabled=false``;

.. code-block:: ini
   :linenos:
   :emphasize-lines: 15-16

   [Desktop Entry]
   Type=Application
   Name=SSH Key Agent
   Comment=GNOME Keyring: SSH Agent
   Exec=/usr/bin/gnome-keyring-daemon --start --components=ssh
   OnlyShowIn=GNOME;Unity;MATE;
   X-GNOME-Autostart-Phase=Initialization
   X-GNOME-AutoRestart=false
   X-GNOME-Autostart-Notify=true
   X-GNOME-Bugzilla-Bugzilla=GNOME
   X-GNOME-Bugzilla-Product=gnome-keyring
   X-GNOME-Bugzilla-Component=general
   X-GNOME-Bugzilla-Version=3.10.1
   X-Ubuntu-Gettext-Domain=gnome-keyring
   X-GNOME-Autostart-enabled=false
   NoDisplay=false


Open the Startup Applications manager, by pressing :kbd:`Super` and typing
``session``.

Uncheck the "SSH Agent".

You need to restart your session by logging out and logging in again.


Disabling the Seahorse GnuPG-Agent
----------------------------------

Same goes for Seahorse GnuPG agent. It doesn't work well with GnuPG version 2.x.
Specifically Enigmail needs GnuPG 2.x but creates broken mail signatures, if
Seahorse is the GnuPG agent.

Disable the agent in the Gnome/Unity autostart folder
:file:`/etc/xdg/autostart/`::

    $ sudo editor /etc/xdg/autostart/gnome-keyring-gpg.desktop

Change or add the following lines:

 * ``NoDisplay=false``;
 * ``X-GNOME-Autostart-enabled=false``;

.. code-block:: ini
   :linenos:
   :emphasize-lines: 15-16

   [Desktop Entry]
   Type=Application
   Name=GPG Password Agent
   Comment=GNOME Keyring: GPG Agent
   Exec=/usr/bin/gnome-keyring-daemon --start --components=gpg
   OnlyShowIn=GNOME;Unity;MATE;
   X-GNOME-Autostart-Phase=Initialization
   X-GNOME-AutoRestart=false
   X-GNOME-Autostart-Notify=true
   X-GNOME-Bugzilla-Bugzilla=GNOME
   X-GNOME-Bugzilla-Product=gnome-keyring
   X-GNOME-Bugzilla-Component=general
   X-GNOME-Bugzilla-Version=3.10.1
   X-Ubuntu-Gettext-Domain=gnome-keyring
   X-GNOME-Autostart-enabled=false
   NoDisplay=false

Uncheck the "GnuPG Agent" in "Startup Applications".

Restart your session.


Seahorse Plug ins
-----------------

Additionally we install the "seahorse plugins and utilities for encryption",
which allows you to encrypt and sign and import keys right from the desktop or
file- manager.

.. image:: /scbutton-free-200px.*
    :alt: Install seahorse-nautilus
    :target: apt:seahorse-nautilus
    :align: left

Install **seahorse-nautilus** from the Ubuntu Software Center

or with the command-line::

    $ sudo apt install seahorse-nautilus
