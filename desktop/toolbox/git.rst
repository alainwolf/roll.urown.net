Version Control
===============

.. contents::


.. image:: git-logo.*
    :height: 92px
    :width: 220px
    :alt: Git Logo
    :align: right

Git
---

`Git <https://git-scm.com/>`_ is a free and open source distributed version
control system designed to handle everything from small to very large projects
with speed and efficiency.

Git is easy to learn and has a tiny footprint with lightning fast performance.
It outclasses SCM tools like Subversion, CVS, Perforce, and ClearCase with
features like cheap local branching, convenient staging areas, and multiple
workflows. 

Installation
^^^^^^^^^^^^

Install from Ubuntu packages repository::

    $> sudo apt install git


Configuration
^^^^^^^^^^^^^

Global configuration settings are stored in the :file:`~/.gitconfig` in your
home directory. One can either edit the file directly or use the following
:file:`git config` commands with the :file:`--global` option.

Global user name, mail address and PGP key::

    $> git config --global user.name John Doe
    $> git config --global user.email john.doe@example.net
    $> git config --global user.signingKey $GPGKEY

Various global PGP related settings::

    $> git config --global commit.gpgSign true
    $> git config --global log.showSignature true
    $> git config --global merge.verifySignatures true
    $> git config --global push.gpgSign if-asked
    $> git config --global tag.gpgSign true

Setup git to use a password cache in memory. This maybe useful for HTTPS
connections to GitHub::

    $> git config --global credential.helper cache

It caches your password for 15 minutes by default. For longer period, like one
hour::

    $> git config --global credential.helper 'cache --timeout=3600'


.. image:: github-logo.*
    :height: 200px
    :width: 200px
    :alt: GitHub Logo
    :align: right


GitHub
------

`GitHub <https://github.com/>`_ provides hosting for software development and
version control using Git. Since 2018 it's owned by Microsoft.

Basic services are free of charge. More advanced professional and enterprise
services are commercial. Free GitHub accounts are commonly used to host
open-source projects. 

As of January 2020, GitHub reports having over 40 million users and more than
190 million repositories (including at least 28 million public repositories),
making it the largest host of source code in the world.


Mail Address
^^^^^^^^^^^^

GitHub uses your *commit email address* to associate commits with your GitHub
account. Make sure the mail address you set in :file:`git config` above also
exists in your GitHub account settings at https://github.com/settings/emails.

for more details, especially on how to preserve your email address privacy, see 
`setting your commit email address in GitHub <https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address>`_.


PGP Public Key
^^^^^^^^^^^^^^

Git allows you to sign your git commits, merges and pushes with your PGP key if
configured with :file:`git config`. GitHub can verify these signatures and will
show them with a green "verified" label on the platform, if your PGP key is tied
to your GitHub account.

Export your PGP key to add it to your GitHub account::

    $>  gpg --export-options export-minimal,export-clean,no-export-attributes \
            --armor --export $GPGKEY 

The above command exports your public key in the smallest possible way, which
makes it easier to copy and paste it to your GitHub account at 
https://github.com/settings/keys.


SSH Public Key
^^^^^^^^^^^^^^

Typically git uses SSH to clone, push and pull code between repositories on
different systems. With GitHub SSH connections are always made with the user
:file:`git` to the host :file:`ssh.github.com` on either the standard TCP port
22 or port 443 (to bypass restricitve firewalls). For identification and
authorization GitHub uses your SSH key. Therefore your SSH key needs to be tied
to our GitHub account as well.

To export your SSH public key, if you are using Yubikey NEO, GnuPG and gpg-agent
for SSH::

    $> gpg --export-ssh-key $GPGKEY

Copy and paste the displayed key into your GitHub profile at 
https://github.com/settings/keys.

You may add the following lines to your SSH configuration file 
:file:`~/.ssh/config`:

.. code-block:: ini

    Host github.com
      Hostname ssh.github.com
      Port 443
      User git

More on 
`Connecting to GitHub with SSH <https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/connecting-to-github-with-ssh>`_.


Personal Access Tokens
^^^^^^^^^^^^^^^^^^^^^^

If you are 
`using HTTPS <https://docs.github.com/en/free-pro-team@latest/github/using-git/which-remote-url-should-i-use>`_ 
on GitHub, instead of SSH, you need to create a  **personal access token**  on 
GitHub to identify yourself on HTTPS connections:

Goto https://github.com/settings/tokens 

When using git on the Linux command-line with GitHub's HTTPS URLs you will be
asked for a user name and password every time a connection to the remote
repository on GitHub is made. You then provide your personal access token as
password. There is currently no secure way to store your credentials on your
local machine with Linux and Gnome, other then keeping it as readable file on
your disk.

But you can set git to cache the password in memory for the next 15 minutes, so
you won't have to type it in every time::

    $> git config credential.https://github.com.useername johndoe
    $> git config --global credential.helper cache


.. image:: meld-logo.*
    :height: 160px
    :width: 160px
    :alt: Git Logo
    :align: right

Meld
====

`Meld <https://meldmerge.org/>`_ is a visual diff and merge tool targeted at
developers. Meld helps you compare files, directories, and version controlled
projects. It provides two- and three-way comparison of both files and
directories, and has support for many popular version control systems.

Installation
------------

Meld is in the Ubuntu software repository::

    $> sudo apt install meld


Using meld with git
-------------------

An `extensive description <https://stackoverflow.com/questions/34119866/>`_  on
how to integrate meld with git is found on 
`stackoverflow <https://stackoverflow.com/>`_.

Meld as `git difftool <https://git-scm.com/docs/git-difftool>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $> git config --global diff.tool meld
    $> git config --global difftool.prompt false

The second option will set git to launch meld immediately, without asking for
confirmation first.


Meld as `git mergetool <https://git-scm.com/docs/git-mergetool>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $> git config --global merge.tool meld
    $> git config --global mergetool.prompt false


References
----------

 * `Git Documentation <https://git-scm.com/doc>`_
 * `Getting started with Git and GitHub <https://docs.github.com/en/free-pro-team@latest/github/using-git/getting-started-with-git-and-github>`_
