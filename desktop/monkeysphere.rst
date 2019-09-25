:orphan:

.. image:: monkeysphere-logo.*
    :alt: Monkeysphere Logo
    :align: right


Monkeysphere
============

The `Monkeysphere <http://web.monkeysphere.info/>`_ tools allow to verify secure
connections, servers and clients, without the need to trust any (often
commercial) third party.

Instead the proven Web-of-Trust from PGP is used to certify secure connections.

Currently this can be used to verify TLS/SSL servers and SSH servers and clients.


Pre-Installation
----------------

Monkeysphere is in the Ubuntu Software repository, but those packages are often
out of date. Installation from the projects own repositories is recommended.

Software Package Signing Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Software packages published by the Monkeysphere project are signed with their
own release key.

Your Ubuntu system needs to trust the "Monkeysphere Archive Signing Key" to be
able to verity and install software packages from the Monkeysphere project::

    $ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x18e667f1eb8af314


Software Package Repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo add-apt-repository 'deb http://archive.monkeysphere.info/debian experimental monkeysphere'


Using Monkeysphere with SSH Servers
-----------------------------------


Verifying SSH Servers
^^^^^^^^^^^^^^^^^^^^^

When connecting to a SSH server the first time, the server typically asks you to
trust its public key, without giving much of a clue about why it should be
trusted except an cryptic SSH public key.

This usually looks like this::

    $ ssh somehost.example.net


.. code-block:: text

    The authenticity of host 'somehost.example.net (192.0.2.10)' can't be established.
    ECDSA key fingerprint is SHA256:8R786sT/hgXWWM72le8eczh8SRyEBuoQdWkdEF/m69o.
    Are you sure you want to continue connecting (yes/no)?


You are supposed to verify the displayed fingerprint
:code:`8R786sT/hgXWWM72le8eczh8SRyEBuoQdWkdEF/m69o` with the operator of the
server. And of course again if anything changes.

Instead with Monkeysphere the server operator can sign the SSH severs host key
using PGP. And if trusted relationship between you and the servers operator can
be established by PGP, his SSH server will by automatically validated and
trusted by your SSH client.

Additionally the operator of the SSH server can change the servers host key
anytime or even revoke this trust anytime, if the sever gets in the wrong hands.


Let SSH Servers Verify You
^^^^^^^^^^^^^^^^^^^^^^^^^^

The other way round, SSH servers using Monkeysphere can verify you as authorized
client, if your public SSH client key is found in the PGP Web-Of-Trust.

You no longer have to send your public SSH client key to every SSH server
operator (and repeat if somehow your key changes).


Installation for SSH Clients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To install SSH server verification on your Ubuntu Desktop::

    $ sudo apt-get install monkeysphere


Verifying SSH Servers
^^^^^^^^^^^^^^^^^^^^^

To enable Monkeysphere for your SSH client the SSH ProxyCommand is used.

To enable this for all your SSH connections add the following line to your
:file:`~/.ssh/config` file:

.. code-block:: text

    Host *
    ProxyCommand monkeysphere ssh-proxycommand %h %p


Its important the your PGP keyring and your SSH :file:`known_hosts` file stay up
to date. If you followed our :doc:`gpg` page, your keyring is kept up-to-date by
parcimonie.

To update your SSH hosts file regularly use the following command::

    $ monkeysphere update-known_hosts


To do this regularly add it as a anacron job to be executed every hour, add the
following line to your crontab::

    0 * * * * monkeysphere update-known_hosts

You can edit your crontab with the following command::

   $ crontab -e


Let SSH Servers Verify You
^^^^^^^^^^^^^^^^^^^^^^^^^^

The monkeysphere command contains a subcommand that will allow you to easily
generate an authentication subkey. On your client, type::

    $ monkeysphere gen-subkey


If you have multiple private keys in your keyring, specify the one you want to use.

If you followd our GnuPG configuration your default key ID should be available
in the shell environment::

    $ monkeysphere gen-subkey $GPGKEY


Otherwise you need to specify it::

    $ monkeysphere gen-subkey 0123456789ABCDEF


A new authentication subkey will be added to your PGP key.

I like to have an expiration date on my keys. The monkeysphere tool does not do that, therefore I add one myself::

    $ gpg --edit key $GPGKEY
    Secret key is available.

    pub  2048R/0123456789ABCDEF  created: 2016-01-15  expires: 2018-01-15  usage: SCA
                                   trust: ultimate      validity: ultimate
    sub  2048R/0x8F79DCC460299A0C  created: 2016-01-15  expires: 2018-01-15  usage: E
    sub  2048R/0x6E0D7F947CCBEF48  created: 2016-07-02  expires: never       usage: A
    [ultimate] (1). John Doe <john.doe@example.net>
    [ultimate] (2)  John Doe  <john.doe@example.com>
    [ultimate] (3)  [jpeg image of size 23712]


The display above lists two sub keys, one for encryption (usage: E) and the on
for authentication, which was just added by monkeysphere.
Select the second subkey using the `key` command::

    gpg>key 2

    pub  2048R/0123456789ABCDEF  created: 2016-01-15  expires: 2018-01-15  usage: SCA
                                   trust: ultimate      validity: ultimate
    sub  2048R/0x8F79DCC460299A0C  created: 2016-01-15  expires: 2018-01-15  usage: E
    sub* 2048R/0x6E0D7F947CCBEF48  created: 2016-07-02  expires: never       usage: A
    [ultimate] (1). John Doe <john.doe@example.net>
    [ultimate] (2)  John Doe  <john.doe@example.com>
    [ultimate] (3)  [jpeg image of size 23712]

The main key and its subkey is listed again, but now the relevant subkey has a
asterisk, which means the following edit commands are applied to that selected
subkey only.

Now lets add an expiry date::

    gpg> expire
    Changing expiration time for a subkey.
    Please specify how long the key should be valid.
             0 = key does not expire
          <n>  = key expires in n days
          <n>w = key expires in n weeks
          <n>m = key expires in n months
          <n>y = key expires in n years
    Key is valid for? (0) 2y
    Key expires at Mon 16 June 2020 17:14:05 CET
    Is this correct? (y/N) y

    You need a passphrase to unlock the secret key for
    user: "John Doe <john.doe@example.net>"
    2048-bit RSA key, ID 0xF08D9BDD13086113, created 2016-01-15

    pub  2048R/0123456789ABCDEF  created: 2016-01-15  expires: 2018-01-15  usage: SCA
                                   trust: ultimate      validity: ultimate
    sub  2048R/0x8F79DCC460299A0C  created: 2016-01-15  expires: 2018-01-15  usage: E
    sub* 2048R/0x6E0D7F947CCBEF48  created: 2016-07-02  expires: 2020-07-02  usage: A
    [ultimate] (1). John Doe <john.doe@example.net>
    [ultimate] (2)  John Doe  <john.doe@example.com>
    [ultimate] (3)  [jpeg image of size 23712]

Save and close the key editing::

    gpg> save


Add the new authentication subkey to the running SSH-agent::

    $ monkeysphere subkey-to-ssh-agent

