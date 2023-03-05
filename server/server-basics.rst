Basic Configuration
===================

Hostname and Domain
-------------------

Hostname
^^^^^^^^

The Linux/UNIX system hostname is set in the file :file:`/etc/hostname`::

    $ sudo echo "charlotte" |sudo tee /etc/hostname

See the :manpage:`hostname(5)` manpage describing the file.

The file is only read at boot time. To update the current hostname until the
next reboot takes place::

    $ sudo hostname --file /etc/hostname

See the :manpage:`hostname(1)` command manpage.


Domain
^^^^^^

The fully qualified domain name (aka. FQDN) contains the hostname and the
domain. That can not be set by commands. It is resolved by the system, when
needed. To make this less dependent on DNS resolvers and servers, we should
set it in the :file:`/etc/hosts` file. DNS servers may not be available,
especially during system startup, or might not have any records of this
system.

Edit :file:`/etc/hosts` and add your hostname and domain (FQDN) as
follows at the very beginning of the file::

    127.0.0.1               charlotte.example.net charlotte localhost
    ::1                     charlotte.example.net charlotte localhost
    172.27.88.10            charlotte.example.net charlotte
    2001:db8:3414:6b1d::10  charlotte.example.net charlotte


See the :manpage:`hosts(5)` manpage.


Resolver
^^^^^^^^

Another place we should place the domain name is in the
:file:`/etc/resolvconf/resolv.conf.d/head`. It is used to create the
:file:`/etc/resolv.conf` by the :manpage:`resolvconf(8)` service (usually at
boot time and after network interface events). Add it after any lines already
present::

    $ echo "domain example.net" |sudo tee -a /etc/resolvconf/resolv.conf.d/head

Update the :file:`/etc/resolv.conf` file::

    $ sudo resolvconf -u

Systems without resolvconf or a similar service (e.g. dnssec-trigger) can just
add the line to the :file:`/etc/resolv.conf` file directly::

    $ echo "domain example.net" |sudo tee -a /etc/resolv.conf


Cloud-Init
^^^^^^^^^^

`Cloud-init <https://cloudinit.readthedocs.io/en/latest/>`_ for cloud instance
initialization.

In some cases Cloud-Init might interfere with your host and domain
configuration at boot time. If that is the case edit the file
:file:`/etc/cloud/cloud.cfg` and change the following line as follows:

.. code-block:: ini

    # This will cause the set+update hostname module to not operate (if true)
    preserve_hostname: true


Timezone
--------

Use :manpage:`timedatectl(1)` to show the current timezone configuration::

    $ timedatectl status


Change it with the :command:`timedatectl set-timezone` command::

    $ sudo timedatectl set-timezone


You can use command-completion with the :kbd:`TAB` key to select your closest
city::

    $ sudo timedatectl set-timezone Europe/



Locales
-------

Locales are a framework to switch between multiple languages and allow users
to use their language, country, characters, collation order, etc.

We can have fine-grained control on how your system talks to you.

For example, I prefer reading untranslated english system messages, but I
prefer time and date strings in log-files or directory listings formatted as I
am used to it in my country (DD.MM.YYYY and 24-hour time).


Locales Installation
^^^^^^^^^^^^^^^^^^^^

To get a list of currently installed locales you can use the
:command:`locale` command::

    $ locale -a


See the :manpage:`locale(1)` manpage.

To see the list of all (500+) locales your system supports::

    $ less /usr/share/i18n/SUPPORTED


Usually the UTF-8 variants are sufficient::

    $ grep -E '^[a-z]{2,3}_[A-Z]{2}.UTF-8' /usr/share/i18n/SUPPORTED


If you are interested in a particular language only (e.g. German)::

    $ grep '^de' /usr/share/i18n/SUPPORTED


Usually the UTF-8 variants are sufficient::

    $ grep -E '^de_[A-Z]{2}.UTF-8' /usr/share/i18n/SUPPORTED


Just show the available locales for you country (i.e. Switzerland)::

    $ grep -E '_CH.UTF-8' /usr/share/i18n/SUPPORTED


Once you have decided on your selection you can install them as follows using
the :manpage:`locale-gen(8)` command::

    $ sudo locale-gen \
        en_GB.UTF-8 en_US.UTF-8 \
        de_CH.UTF-8 fr_CH.UTF-8 it_CH.UTF-8 \
        de_DE.UTF-8 de_AT.UTF-8


In this example we installed British- and US-English, Swiss german, french and
italian, and the german variants of Germany and Austria.


Locale Configuration
^^^^^^^^^^^^^^^^^^^^

To see the locales settings of your current session::

    $ locale
    LANG=en_US.UTF-8
    LANGUAGE=
    LC_CTYPE="en_US.UTF-8"
    LC_NUMERIC="en_US.UTF-8"
    LC_TIME="en_US.UTF-8"
    LC_COLLATE="en_US.UTF-8"
    LC_MONETARY="en_US.UTF-8"
    LC_MESSAGES=POSIX
    LC_PAPER="en_US.UTF-8"
    LC_NAME="en_US.UTF-8"
    LC_ADDRESS="en_US.UTF-8"
    LC_TELEPHONE="en_US.UTF-8"
    LC_MEASUREMENT="en_US.UTF-8"
    LC_IDENTIFICATION="en_US.UTF-8"
    LC_ALL=


The system default settings are stored in the :file:`/etc/default/locale`
file. The format is described in :manpage:`locale(5)`.

::

    $ cat /etc/default/locale

In the following example, we retain US-English as the system language for
messages and string operations like sorting, but change some of them to our
familiar national formats.


Set Defaults for All Users
''''''''''''''''''''''''''

To change these defaults for all users edit the :file:`/etc/default/locale`
file directly or use the :manpage:`update-locale(8)` command::

    # Set US-English as default language
    LANG=en_US.UTF-8

    # What language should be used for system messages.
    LC_MESSAGES=POSIX

    # What name and symbol of your currency
    LC_MONETARY=de_CH.UTF-8

    # Date and time representations (e.g. 24-hour or AM/PM)
    LC_TIME=de_CH.UTF-8

    # Paper sizes and formats, for printing (Letter or A4)
    LC_PAPER=de_CH.UTF-8

    # How names and addresses are formatted
    LC_IDENTIFICATION=de_CH.UTF-8
    LC_NAME=de_CH.UTF-8
    LC_ADDRESS=de_CH.UTF-8
    LC_TELEPHONE=de_CH.UTF-8

    # Metric or imperial units (Pounds or kilos)
    LC_MEASUREMENT=de_CH.UTF-8


Set for Your Own User Profile
'''''''''''''''''''''''''''''

Set them in your :file:`~/.pam_environment` file.


References
''''''''''

    * https://help.ubuntu.com/community/Locale#List_current_settings


