Server Installation
===================

Suggested Reading:
`Ubuntu Installation Guide <https://help.ubuntu.com/14.04/installation-guide/amd64/index.html>`_

Prepare Installation Media
--------------------------

..  :todo::

    Write section: Prepare USB stick or CD-ROM for Ubuntu Sever installation.


Boot Installation Media
-----------------------

..  :todo::

    Write section: Boot Ubuntu Sever installation media.


OS Installation
---------------

The installation takes about 40 minutes. Depending on your hardware,
installation media (USB stick, CD-ROM) and internet connection.

Step 1 of 24: Select language during installation:

.. image:: server-install_01.*
    :alt: Step 1 of 24: Select language during installation
    :align: center

Step 2 of 24: Select keyboard layout:

.. image:: server-install_02.*
    :alt: Step 2 of 24: Select keyboard layout
    :align: center

Step 3 of 24: Start installation:

.. image:: server-install_03.*
    :alt: Step 3 of 24: Start installation
    :align: center


Step 4 of 24: Select installation language:

.. image:: server-install_04.*
    :alt: Step 4 of 24: Select installation language
    :align: center

Step 5 of 24: Select location:

.. image:: server-install_05.*
    :alt: Step 5 of 24: Select location
    :align: center

Step 6 of 24: Optional Select other location:

.. image:: server-install_06.*
    :alt: Step 6 of 24: Select other location
    :align: center

Step 7 of 24: Give the server a name:

.. image:: server-install_07.*
    :alt: Step 7 of 24: Give the server a name
    :align: center

Step 8 of 24: Enter your full name for the user profile:

.. image:: server-install_08.*
    :alt: Step 8 of 24: Full name for the user profile
    :align: center

Step 9 of 24: User profile name for login on the server:

Use the same username as on your desktop computer.

.. image:: server-install_09.*
    :alt: Step 9 of 24: User profile name for login on the server
    :align: center

Step 10 of 24: Password of user your profile on the server:

Don't use the same password as on your desktop system. Select a different
password on every system.

.. image:: server-install_10.*
    :alt: Step 10 of 24: Password of user your profile on the server
    :align: center

Step 11 of 24: Home directory encryption:

Don't encrypt your homw directory on the server. There will be no gain, but much
pain. Your account on the server, will only be used for server-administratoion
and you will never store any documents or data containing personal information
there.

.. image:: server-install_11.*
    :alt: Step 11 of 24: Home directory encryption
    :align: center

Step 12 of 24: Confirm timezone:

.. image:: server-install_12.*
    :alt: Step 12 of 24: Confirm timezone
    :align: center

Step 13 of 24: Select how to prepare the hard-drives:

.. image:: server-install_13.*
    :alt: Step 13 of 24: Select how to prepare the hard-drives
    :align: center

Step 14 of 24: Select the hard-drive for installation:

.. image:: server-install_14.*
    :alt: Step 14 of 24: Select the hard-drive for installation
    :align: center

Step 15 of 24: Confirm partitioning of disk:

.. image:: server-install_15.*
    :alt: Step 15 of 24: Confirm partitioning of disk
    :align: center

Step 16 of 24: Set disk space used:

.. image:: server-install_16.*
    :alt: Step 16 of 24: Set disk space used
    :align: center

Step 17 of 24: Create filesystem on disk:

.. image:: server-install_17.*
    :alt: Step 17 of 24: Create filesystem on disk
    :align: center

Step 18 of 24: Installation starts ...

This step will take about 5 minutes to complete

.. image:: server-install_18.*
    :alt: Step 18 of 24: Installation progress
    :align: center

Step 19 of 24: Set a proxy for internet access:

.. image:: server-install_19.*
    :alt: Step 19 of 24: Set a proxy for internet access
    :align: center

Step 20 of 24: Security updates installation:

.. image:: server-install_20.*
    :alt: Step 20 of 24: Security updates installation
    :align: center

Step 21 of 24: Select "OpenSSH server" for installation.

Don't select anything else for the moment.

.. image:: server-install_21.*
    :alt: Step 21 of 24: Server task selection
    :align: center

This step will take about 15 minutes, where software packages are downloaded and
installed.

Step 22 of 24: Install boot loader:

.. image:: server-install_22.*
    :alt: Step 22 of 24: Install boot loader
    :align: center

Step 23 of 24: Reboot server:

.. image:: server-install_23.*
    :alt: Step 23 of 24: Reboot server
    :align: center

Step 24 of 24: Ubuntu Server Installation is complete, the server is installed
and ready.

.. image:: server-install_24.*
    :alt: Step 24 of 24: Ready
    :align: center


Connecting to the Server
------------------------

You should now be able to connect from your desktop system to your newly
installed Ubuntu Server.

::

    $ ssh <servername>

.. code-block:: text

    The authenticity of host 'server (192.0.2.235)' can't be established.
    ECDSA key fingerprint is 1e:34:d6:85:78:17:66:17:ad:62:45:05:fa:18:9d:a7.
    No matching host key fingerprint found in DNS.
    Are you sure you want to continue connecting (yes/no)? yes

Replace **<servername>** with the name you gave to your server and type in
**yes** to confirm, that is indeed a new server.

