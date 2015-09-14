Keys
====

Keys are essentially very big :doc:`passphrases` created by very sophisticated
mathematical methods. Printed out Such passphrases are impossible to memorize or
type by a human. Printed on paper they could easily fill multiple pages of
gibberish.

Therefore keys are kept stored in files. But since a file can be stolen, the
key-files again encrypted and protected with a password. This way only the
intended user who knows the password can use the key. 


SSH Client Keys
---------------

ed25519 
^^^^^^^ 

`ed25519 <http://ed25519.cr.yp.to/>`_ is a very fast and higly secure public-key
signature system. It uses small keys (32 bit) and small signatures (64 bit).

ed25519 currently offers the best choice of speed, key-size and security for SSH
public key authentication, but since it is fairly new (available since OpenSSH
6.5 published January, 2014) RSA keys are still needed for older systems and
devices.

::

    $ ssh-keygen -t ed25519 -o -a 100
    Generating public/private ed25519 key pair.
    Enter file in which to save the key (/home/user/.ssh/id_ed25519):                             
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /home/user/.ssh/id_ed25519.
    Your public key has been saved in /home/user/.ssh/id_ed25519.pub.
    The key fingerprint is:
    7b:e1:23:2c:66:4c:6a:7c:41:bb:3e:13:fe:5b:86:4b user@Host


.. note::

    ed25519 keys are not yet recognized by many tools and agents. They don't
    work with *ssh-copy-id* an the ssh-agents of Seahorse and GnuPG.


RSA
^^^

Defaults would generate a 2048 bits RSA key, while at least 3072 bits are
recommended.

::

    $ ssh-keygen -t rsa -b 4096 -o -a 100


Reference
^^^^^^^^^

 * `ssh-keygen <http://manpages.ubuntu.com/manpages/trusty/en/man1/ssh-keygen.1.html>`_
