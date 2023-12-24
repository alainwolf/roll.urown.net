:orphan:

Media Center
============

Software Updates
----------------

::

    $> sudo apt update
    $> sudo apt full-upgrade
    $> sudo apt autoremove
    $> sudo apt autoclean


Security Settings
-----------------


Change Password
^^^^^^^^^^^^^^^

::

    desktop$ ssh osmc@media-center.example.net
    osmc@media-center.example.nets password:
    osmc
    media-center$ passwd


SSH Key Login
^^^^^^^^^^^^^

::

    desktop$> ssh-copy-id osmc@media-center.example.net


Disable Password Authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Edit :file:`/etc/ssh/sshd_config` and change the following lines as follows::


    # Enable public key authentication
    PubkeyAuthentication yes

    # Disable password authentication
    PasswordAuthentication no


Restart the SSH service::

    media-center$> sudo systemctl restart ssh.service


SSH Host Key Fingerprints
^^^^^^^^^^^^^^^^^^^^^^^^^

ED 25519 Key::

    media-center$> ssh-keygen -r media-center.example.net -f /etc/ssh/ssh_host_ed25519_key.pub


RSA Key::

    media-center$> ssh-keygen -r media-center.example.net -f /etc/ssh/ssh_host_rsa_key.pub


Hardware Video Decoder
----------------------

Hardware decoding of additional codecs on the Raspberry Pi 3 and earlier
models can be enabled by
`purchasing a license <https://codecs.raspberrypi.com/license-keys/>`_ that is
locked to the CPU serial number of your Raspberry Pi.

.. Note::

    On the **Raspberry Pi 4**, the hardware codecs for MPEG2 or VC1 are
    permanently disabled and cannot be enabled even with a license key; on the
    Raspberry Pi 4, thanks to its increased processing power compared to
    earlier models, MPEG2 and VC1 can be decoded in software via applications
    such as VLC. Therefore, a hardware codec license key is not needed if
    you’re using a Raspberry Pi 4.

MPEG-2 and VC-1 license keys are available for £3.00 GBP from the
`<https://codecs.raspberrypi.com/license-keys/>`_.

Make note of your Raspberry Pi CPU serial::

    media-center$> cat /proc/cpuinfo

    Hardware	: BCM2835
    Revision	: a02082
    Serial      : 0000000012345678

Use the serial to order the license keys on the
`<https://codecs.raspberrypi.com/license-keys/>`_.

You will receive the license keys a few days later by email along with instructions::

    media-center$> echo "decode_MPG2=0x12345678" | sudo tee -a /boot/config.txt
    media-center$> echo "decode_WVC1=0x12345678" | sudo tee -a /boot/config.txt
    media-center$> reboot


Enable IPv6 Support
-------------------

::

    media-center$> sudo modprobe ipv6
    media-center$> sudo connmanctl
    connmanctl> services
    *AO Wired                ethernet_b827eb5e2aed_cable
    connmanctl> config ethernet_b827eb5e2aed_cable --ipv6 auto
    connmanctl> quit


SSH Client
----------

Custom TCP port
^^^^^^^^^^^^^^^

If you media-server is using a custom TCP port for SFTP connections::

    media-center$> nano ~/.ssh/config

Add lines similar to the followings::

    Host media-server.example.net
        Port 12345


Replace with your hostname or address and custom SSH port of your own server.


Passwordless Logins
^^^^^^^^^^^^^^^^^^^

It is particularly cumbersome to enter passwords using a TV remote and an
on-screen keyboard. By creating SSH keys we can use passwordless SFTP logins
on our media server::

    media-center$> ssh-keygen -t ed2259
    media-center$> ssh-keygen -t rsa

In case of your media server being a Synology NAS, the usual
:command:`ssh-copy-id` command can not be used, as DSM doesn't allow SSH
terminal loging by non-admin users.

So we download a copy of the :file:`authorized_keys` file from the
media-server, add our public keys and upload it again to the media-server::

    media-center$> TMP_FILE=$(mktemp)
    media-center$> sftp media-server.example.net:/home/.ssh/authorized_keys $TMP_FILE
    media-center$> cat ~/.ssh/*.pub >> "$TMP_FILE"
    media-center$> sftp "$TMP_FILE" media-server.example.net:/home/.ssh/authorized_keys
    media-center$> rm $"$TMP_FILE"


AutoFS
------

Kodi and OSMC both recommend to use the Linux operating system to mount
network shares, instead of the built-in Kodi functions.

Install the required packages::

    media-center$> sudo apt update
    media-center$> sudo apt install autofs sshfs


While most examples on the web explain the process with NFS or SMB shares, I
prefer SSHFS and WebDAVs.

NFS and SMB are usually unencrypted and only work inside a local network.
Nowadays the concept of **zero-trust** is recommend, meaning local networks is
no longer a thing. I should not matter anymore, from where you are connecting
and with what device. SSH and WebDAV (HTTPS) work worldwide and can be
considered safe using well established public key cryptography.


For SSHFS
^^^^^^^^^

Since the SSH connection will be established by the operating system, instead
of a user, the system needs to be configured to be able to seamlessly connect
to the server. We therefore need to provide the servers custom SSH
port-number, the servers public SSH key, the connecting user-id and
private SSH key.

Make the servers public key available system wide::

    media-center$> cat ~/.ssh/known_hosts | sudo tee -a /etc/ssh/known_hosts > /dev/null


Create a system-wide SSH client configuration file for this server::

    media-center$> sudo nano /etc/ssh/ssh_config.d/media-server


The file contains something along the lines of ... ::

    Host media-server.example.net
        Port 12345
        User osmc
        IdentityFile=/home/osmc/.ssh/id_ed25519


Create the directory to mount the file system to::

    media-center$> sudo mkdir -p /mnt/sshfs

Add an SSHFS shares configuration ... ::

    media-center$> sudo nano /etc/auto.master


... and add to the end of the file :file:`/etc/auto.master`::

    /mnt/sshfs /etc/auto.sshfs uid=1000,gid=1000,--timeout=30,--ghost


Then create the file :file:`/etc/auto.sshfs.shares` with content similar to
the following::

    media-server -fstype=fuse,ro,nodev,noatime,allow_other,max_read=65536 :sshfs\#media-server.example.net\:


CEC
---

CEC (Consumer Electronics Control) allows for control of devices over the HDMI port.

Kodi on the Raspberry Pi has built-in support for CEC. If your TV-Set supports
it, you should be able to control Kodi by your TV remote and TV should be able
to switch on and off automatically when playback starts and stops.


References
----------

 * `Frequently Asked Questions for the Raspberry Pi <https://osmc.tv/wiki/raspberry-pi/frequently-asked-questions/>`_ on the OSMC Wiki
 * `Raspberry Pi <https://kodi.wiki/view/Raspberry_Pi>`_ page on the Kodi Wiki
 * `Mounting network shares with autofs <https://osmc.tv/wiki/general/mounting-network-shares-with-autofs-alternative-to-fstab/>`_ from the OSMC Wiki
 * `Autofs and sshfs – the perfect couple <https://www.tjansson.dk/2008/01/autofs-and-sshfs-the-perfect-couple/>`_ by Thomas Jansson
