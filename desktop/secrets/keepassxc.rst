.. image:: keepassxc-logo.*
    :alt: KeepassXC Logo

KeePassXC
=========

`KeePass Cross-Platform Community Edition <https://keepassxc.org/>`_

*The thing computers can do best is storing information.*

*You shouldn't waste your time trying to remember and type your passwords.
KeePassXC can store your passwords safely and auto-type them into your everyday
websites and applications.*

**KeePassXC** is probably the single most important software program and
personal database.

It is essentially designed as a safe password storage, but can be used for any
piece of information which needs to be kept private. Like ...

 * bank account numbers,
 * credit-card information,
 * PIN codes of your various devices and ATM cards,
 * etc.

Every piece of information that needs to stay private should be kept in the
KeePass database.

.. note::

    If you use KeePassXC for your secrets ...

        * You will never have to remember a password again apart from your KeePass
          database password;

        * Never have to use the same password twice or more for different accounts,
          websites etc. since you don't need to remember them anymore;

        * Automatically create and use very strong passwords which are impossible to
          guess and are very hard to break, even for government agencies;

        * As single encrypted file the database can be stored and synced
          across all your devices and stored on unencrypted drives or third-party
          cloud storage.

        * You might also give a copy to a friend or family member for safekeeping,
          as they can't access it without the pass-phrase.

Besides running on our Ubuntu Desktop, the KeePass database format can be read
by applications running on the following platforms:

 * All Linux and UNIX systems
 * Mac OSX
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
------------

As of November 2017 KeePassXC was not available in the Ubuntu Software Package
repositories. Therefore the following PPA (Personal Package Archive) needs to be
added first::

    sudo add-apt-repository ppa:phoerious/keepassxc
    sudo apt update


After that ...

.. image:: /scbutton-free-200px.*
    :alt: Install keepassxc
    :target: apt:keepassxc
    :align: left

Install **keepassxc** from the Ubuntu Software Center

or with the command-line::

    $ sudo apt install keepassxc
