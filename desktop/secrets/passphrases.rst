Passphrases
===========

.. contents::
    :depth: 1
    :local:
    :backlinks: top


About Passwords and Passphrases
-------------------------------

.. image:: xkcd-password-strenght.*
    :alt: XKCD on Password Strength
    :target: https://www.xkcd.com/936/

Throughout this document we use the term *Passphrase* because a single word will
never make a good passhprase.

The following passphrases need to be stored in your brain:

 1. Password database (KeePassX)
 2. Desktop user login
 3. Storage encryption

All others can be accessed from a database on one your devices, they can be
very long and complicated, as you will never need to use them from memory.


Strong but Easy to Remember
^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are tools like `APG
<http://manpages.ubuntu.com/manpages/trusty/en/man1/apg.1.html>`_ or `pwgen
<http://manpages.ubuntu.com/manpages/trusty/man1/pwgen.1.html>`_ available, but
the created passwords will be difficult to remember.

Best solution as of today is to use `Diceware
<http://world.std.com/~reinhold/diceware.html>`_ which creates very strong
passphrases but that are still easy to remember.

The generated passhrase will look similar to something like the example below:

.. code-block:: text

    timid bingle heath js duck


Write those down and keep the note with you. Every time you use it, try to write
it from memory first, before taking a peek. After some days you will no longer
need the look at the note.

If you trust your computers :doc:`random number generation capabilities
</server/entropy>` you can use 
`software <https://github.com/akheron/diceware.py>`_::

    $ cd Downloads
    $ git clone https://github.com/akheron/diceware.py.git
    $ cd diceware.py/
    $ sudo ./setup.py install
    $ diceware.py


If you trust this server you might also use `this <https://diceware.urown.net/>`_.


Strong but Easy to Type
^^^^^^^^^^^^^^^^^^^^^^^

Even if you don't have to remember any other passphrases, I still suggest to
create some of them with the Diceware method instead of the built-in generator
of KeePassX. Not because they are easy to remember, but because they are easy to
type.

Password generators, like the one in KeePassX, might generate secure passwords,
but they usually looks like this:

.. code-block:: text

    qvkUj]jw?Ud_E&3 Y4/'H;-RYD)vb ?R

That is OK, as long as you never have to type it in yourself. You can use the
Auto-Type feature of KeePassX or copy & paste on your device. Browser, mail-
client, or key-ring applications like Seahorse will provide passphrases on your
behalf most of the time.

But if you are not working on your own computer? You still can use your password
database, as you have if with you on your smartphone, but you will have to read
the credentials from the screen of one device and type it in on another device.

Another scenario is if something is broken, stolen or lost. You might need
to access data (e.g. backups) without having access to your usual comfortable
work environment.

The above examples ``timid bingle heath js duck`` and  ``qvkUj]jw?Ud_E&3
Y4/'H;-RYD)vb ?R`` are both exactly 208 bit strong. But while the first is easy
to quickly check webmail or download something from your cloud while your at a
friends house, the second is close to impossible to even read it right:

 * Is this a ``l`` or a ``1``?
 * Is this a ``0`` or a ``O``?
 * How many spaces or ``_`` are these?

Some passphrases who might fall into this category:

 * Personal mail account (webmail);
 * Cloud storage account (quick downloads or uploads);
 * NAS user account (access to backups);
 * Frequently used social networks;
 * 3rd-party identity providers (i.e. Mozilla Persona, Google Account);
 * Server administrator login (root user);
 * Database management (MySQL server root user);

Additionally consider using Diceware for passwords, which you are likely to
communicate to others (i.e. access passphrase to your homes wireless
network).


How many words?
^^^^^^^^^^^^^^^

Each additional word used in a Diceware passphrase adds more security.

The following table is based on estimates of computing power available to large
government organizations. Keep in mind that we don't know for sure and that new
technology can change the game anytime.

===== ========== ================== ==========
Words Entropy    Time to Crack      Safe until
===== ========== ================== ==========
4      51.6 bits less than a day    Not safe
5      64.6 bits less then 6 months 2013
6      77.5 bits 3,505 years        2020
7      90.4 bits 27 million years   2030
8     103.0 bits Unknown            2050
===== ========== ================== ==========

Based on this assumptions the following is recommended to balance comfort, ease
of use and security.

======================== ============== =====
Use for                  Security Level Words
======================== ============== =====
Password Safe (KeePassX) Highest        7
GPG Private Key          Highest        7
Administrator Login      Highest        7
CA Root Key              Highest        7
CA Intermediate Key      High           6
Storage Encryption       High           6
SSH Private Key          High           6
TLS Client Certificates  High           6
User Login               Medium         5
Mail & IM Accounts       Medium         5
Cloud Storage            Medium         5
Wireless Network         Moderate       4
======================== ============== =====

Of course higher is always better and you are welcome to use more words. But
this document is more geared towards personal use and less for a terrorist
organizations, activists, big corporation or government agencies.

We consider clients, servers and networks as insecure in the first place
(especially wireless networks). Mail flows in and out from insecure 3rd-party
services like Gmail or Hotmail. If you have to deal with really sensitive data,
encrypt it either with GPG or store it on a encrypted drive.

More on this from Micah Lee of the Intercept: 
`Passphrases That You Can Memorize — But That Even the NSA Can’t Guess 
<https://firstlook.org/theintercept/2015/03/26/passphrases-can-memorize-attackers-cant-guess/>`_ 


Passphrase Management Tools
---------------------------

Seahorse 
^^^^^^^^

.. image:: seahorse-logo.*
    :alt: Seahorse Logo
    :align: right


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

.. note::

    The Mozilla products Firefox and Thunderbird use their own password and
    certificates storage. Therefore login credentials for websites and
    mail servers are not managed by Seahorse.


This means that all passwords, pass-phrases, used by any application or network
connection during a desktop session is managed and remembered in the keyring.

Additionally Seahorse also manages access to your GnuGP keys, SSH keys and TLS
(x.509) certificates and keys.

Problem there is, that the Seahorse agents are no longer compatible with newer
versions of GnuPG and OpenSSH.

Therefore we will use the respective native agents of GPG and OpenSSH and have
to disable the Seahorse agents of those.


Disabling the Seahorse SSH-Agent
''''''''''''''''''''''''''''''''

 * It doesn't handle newer SSH key formats (ed22519, etc);
 * It loads all keys in ~/.ssh automatically at startup;
 * You cannot remove these keys, even with ssh-add -D, and...
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

You need to restart your session by logging out and login again.


Disabling the Seahorse GnuPG-Agent
''''''''''''''''''''''''''''''''''

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


Seahorse Plugins
''''''''''''''''

Additionally we install the "seahorse plugins and utilities for encryption",
which allows you to encrypt and sign and import keys right from the desktop or
file- manager.

.. raw:: html

        <p>
            <a class="reference external" href="apt:seahorse-nautilus" 
            title="Seahorse Plugins and Utilities for Encryption">
            <img alt="software-center" src="../_images/scbutton-free-200px.png" />
            </a>
        </p>


Keychain
^^^^^^^^

`keychain <http://www.funtoo.org/Keychain>`_ is a manager for ``ssh-agent`` and 
``gpg-agent``.

It allows your shells and cron jobs to share a single ssh-agent process. By
default, the ssh-agent started by keychain is long-running and will continue to
run, even after you have logged out from the system.

Installation
''''''''''''

keychain can be installed from the Ubuntu Software Center:

.. raw:: html

  <p>
      <a class="reference external" href="apt:keychain" 
      title="Key Management for OpenSSH and GnuPG">
      <img alt="software-center" src="../_images/scbutton-free-200px.png" />
      </a>
  </p>

Copy the example X11 startup script  provided in examples to the system X11
configuration directory::

  $ sudo cp /usr/share/doc/keychain/examples/keychain.xsession /etc/X11/Xsession.d/

Setup
'''''

After installation edit your shell login profile and add the following lines::

    $ editor ~/.bash_profile


Add the following lines:

.. code-block:: bash

    # Start keychain and point it to the private keys that we'd like it to cache
    /usr/bin/keychain ~/.ssh/id_ed25519 ~/.ssh/id_rsa 0xABDCEF0123456789
    source ~/.keychain/Mirage-sh
    source ~/.keychain/Mirage-sh-gpg

Where ``ABDCEF0123456789`` is your OpenPGG key ID.

This will load the Agents and Keys on your first console or remote login after 
reboot.

Also edit your (non-login) shell profile and add the following lines::

  $ editor ~/.bashrc


Add the following lines:

.. code-block:: bash

  # Load private keys into agents if not already done
  keychain --quiet ~/.ssh/id_ed25519 ~/.ssh/id_rsa

Only the first terminal window you open will ask you for your passphrase of you SSH
keys. Other terminal windows will only ask if needed.


KeePassX
^^^^^^^^

.. image:: keepassx-logo.*
    :alt: KeepassX Logo
    :align: right

While having a integrated solution on your desktop to manage your secrets is
convenient, it remains a local solution confined to your Ubuntu desktop system.

Seahorse is not available on other platforms and systems and its not even easy
to transfer or even sync your key-rings to other Ubuntu Desktop systems you
might use.

Which is why we also need `KeePassX program <https://www.keepassx.org/>`_
installed.

The `KeePassX program <https://www.keepassx.org/>`_ is probably the single most
important software program and personal database.

It is essentially designed as a safe password storage, but can be used for any
piece of information which needs to be kept private. Like bank account numbers,
credit-card information, PIN codes of your various devices and ATM cards, etc.

Every piece of information that needs to stay private should be kept in the 
KeePass database.

If you use KeePassX for your secrets ...

 * You will never have to remember a password again apart from your KeePassX 
   database password;
 * Never have to use the same password twice or more for different accounts, 
   websites etc. since you don't need to remember them anymore;
 * Automatically create and use very strong passwords which are impossible to 
   guess and are very hard to break, even for government agencies;

The database is a single encrypted file and therefore can be stored and synced
across all your devices and safely backed up even on unencrypted storage
devices. You might also give a copy to a friend or family member for
safekeeping, as they can't access it without the pass-phrase.

Besides running on our Ubuntu Desktop, the KeePass database format can be read
by applications running on the following platforms:

 * All Linux and UNIX systems
 * Mac OS X
 * Windows
 * `Android <https://play.google.com/store/apps/details?id=com.android.keepass>`_
 * `Windows Phones <https://7pass.wordpress.com/>`_
 * Windows Mobile
 * Blackberry
 * Mobile Phones (running Java Mobile Edition, e.g, Symbian)
 * iPhone and iPad
 * Chrome OS 
 * Palm OS


Installation
''''''''''''

KeePassX can be installed from the Ubuntu Software-Center:

.. raw:: html

        <div class="admonition warning">
        <p class="first admonition-title">Ubuntu Software Package</p>
        <p class="last">
            <img alt="software-center" 
            src="../_images/software-center-icon-48.png" 
            width="48px" height="48px"
            class="align-left"/>
            Install KeePassX<br/>
            <a class="reference external" href="apt:keepassx">
            Ubuntu Software Center
            </a>
        </p>
        <p class="last">
            or with command-line: 
            <code>$ sudo apt-get install keepassx</code>
        </p>
        </div>


Keyboard Issue
''''''''''''''

If you are using a non-english keyboard layout like german (DE) or swiss (CH) 
the auto-type function of KeePassX will type wrong special-characters in 
usernames and passwords. To work around this problem, one can set the used 
keyboard layout to the X-Windows system::

    $ setxkbmap <keymap>

Where *<keymap>* is the keymap you use (ch, fr, en-us, de, ..., etc.).

.. note::
   The following procedure has to be done again every time KeePassX is updated 
   or reinstalled.


To do this automatically every time you start KeePassX, edit the file 
:file:`/usr/share/keepassx.desktop` and modify the command on the line which 
says **Exec** from :code:`Exec=keepassx %f` to 
:code:`Exec=sh -c 'setxkbmap <keymap> && keepassx %f'`. Where <keymap> is the keymap 
you use (ch, fr, en-us, de, ..., etc.).

::

        $ sudo editor /usr/share/applications/keepassx.desktop


.. code-block:: ini
   :linenos:
   :emphasize-lines: 7

        [Desktop Entry]
        Name=KeePassX
        GenericName=Cross Platform Password Manager
        GenericName[de]=Passwortverwaltung
        GenericName[es]=Gestor de contraseñas multiplataforma
        GenericName[fr]=Gestionnaire de mot de passe
        Exec=Exec=sh -c 'setxkbmap ch && keepassx %f'
        Icon=keepassx
        Comment=Cross Platform Password Manager
        Comment[de]=Passwortverwaltung
        Comment[es]=Gestor de contraseñas multiplataforma
        Comment[fr]=Gestionnaire de mot de passe
        Terminal=false
        Type=Application
        Categories=Qt;Utility;Security;
        MimeType=application/x-keepass;
        X-SuSE-translate=true


Reference:

`Ask Ubuntu - KeePassX Auto-Type is no longer operational
<http://askubuntu.com/questions/330617/keepassx-auto-type-in-no-longer-operational/380722#380722>`_


