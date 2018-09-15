Passphrases
===========

.. contents::
    :depth: 1
    :local:
    :backlinks: top


.. image:: xkcd-password-strenght.*
    :alt: XKCD on Password Strength
    :target: https://www.xkcd.com/936/

Throughout this document we use the term *Passphrase* because a single word will
never make a good passhprase.

Only the following 3 passphrases need to be stored in your brain:

 1. Your password database (e.g. KeePass)
 2. Your user login on your desktop computer
 3. Access to your encrypted storage media (USB sticks, disks, etc.)

All others can be accessed from a database on one your devices, they can be
very long and complicated, as you will never need to use them from memory.


Strong but Easy to Remember
---------------------------

There are tools like `APG
<http://manpages.ubuntu.com/manpages/xenial/en/man1/apg.1.html>`_ or `pwgen
<http://manpages.ubuntu.com/manpages/xenial/man1/pwgen.1.html>`_ available, but
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
`xkcdpass <https://github.com/redacted/XKCD-password-generator>`_.

.. image:: /scbutton-free-200px.*
    :alt: Install xkcdpass
    :target: apt:xkcdpass
    :align: left

Install **xkcdpass** from the Ubuntu Software Center

or with the command-line::

    $ sudo apt install xkcdpass

If you trust this documentation you might also use
`our diceware website <https://diceware.urown.net/>`_.


Strong but Easy to Type
-----------------------

Even if you don't have to remember any other passphrases, I still suggest to
create some of them with the Diceware method instead of the built-in generator
of KeePassXC. Not because they are easy to remember, but because they are easy to
type.

Password generators, like the one in KeePassXC, might generate secure passwords,
but they usually looks like this:

.. code-block:: text

    qvkUj]jw?Ud_E&3 Y4/'H;-RYD)vb ?R

That is OK, as long as you never have to type it in yourself. You can use the
Auto-Type feature of KeePassXC or copy & paste on your device. Browser, mail-
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
Password Safe (KeePass)  Highest        7
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



