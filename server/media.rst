External Drives
===============

Most people store their media files collection on external hard-drives attached
by USB, FireWire or eSATA. 

`autofs <http://www.kernel.org/pub/linux/daemons/autofs/v5/>`_, the kernel-based
automounter for Linux can be used to mount external hard-drives::

	$ sudo apt-get install autofs5

The installation creates and starts the system service *autofs* and creates the
following configuration files:

	*	:file:`/etc/auto.master`
	*	:file:`/etc/auto.net`
	*	:file:`/etc/auto.misc`
	*	:file:`/etc/auto.smb`
	*	:file:`/etc/default/autofs`

Create the directory, where external USB hard-drives will be mounted into::

	$ sudo mkdir -p /etc/media/usb

Edit the file :file:`/etc/auto.master` and add the following line:

.. code-block:: ini

	/media/usb /etc/auto.usb --timeout=900 --ghost

To identify the exact properties of the external hard-drive to be mounted later,
make sure the cable is conneccted and it is powered on. The issue the following
command::

	$ sudo blkid -o list -w /dev/null

This will display a list of all attached file-systems and their various properties:

.. code-block:: text

	device		fs_type		label		mount point		UUID
	----------------------------------------------------------------------------------------
	...
	/dev/sdb1	ext3		MyDrive		(not mounted)	00b0bc8a-57f7-497c-92c9-d1ad42d94432
	...


With the properties now known to us, we are able to create the autofs configuration file :file:`/etc/auto.usb` referenced earlier in the master configuration file.

.. code-block:: text

	MyDrive -fstype=ext3,noatime,nodiratime,sync,users,rw,nodev,noexec,nosuid,context=system_u:object_r:removable_t :/dev/disk/by-uuid/00b0bc8a-57f7-497c-92c9-d1ad42d94432

It should be all on one line.

Finally restart the *autofs* service::

	$ sudo restart autofs

The external hard-drive will be mounted as soon as we access the directory
:file:`/media/usb/MyDrive` and un-mounted again after 15 minutes of no activity.



Media Server
============

`MiniDLNA (aka ReadyDLNA) <http://sourceforge.net/projects/minidlna/>`_ is
server software with the aim of being fully compliant with DLNA/UPnP-AV clients.

Installation
------------
Installation from the Ubuntu software package repository::

	$ sudo apt-get install minidlna


Configuration
-------------

Open the configuration file :file:`/etc/minidlna.conf`.

.. code-block:: text

	media_dir=A,/media/usb/MyDrive/Music
	media_dir=V,/media/usb/MyDrive/Videos/Movies
	media_dir=V,/media/usb/MyDrive/Videos/Series
	media_dir=P,/media/usb/MyDrive/Pictures
	media_dir=/var/lib/transmission-daemon/downloads


Web Monitor
-----------

MiniDLNA provides a webpage, where the current status of it can be examined.

Add the following block to your internal nginx server configuration:

.. code-block:: nginx

    # MiniDLNA / ReadyMedia
    location /minidlna {
        proxy_pass http://localhost:8200/;
    }

Troubleshooting
---------------

Inotify watches
^^^^^^^^^^^^^^^

Inotify is a method how the media server gets notfied, if any changes in the
media file directories happen. If the media collection is large, you might get
the following error in the logs:

.. code-block:: text


	WARNING: Inotify max_user_watches [8192] is low or close to the number of
	used watches [1253] and I do not have permission to increase this limit.
	Please do so manually by writing a higher value into
	/proc/sys/fs/inotify/max_user_watches.

To increase the value from 8192 to a vlue eight times as high::

	$ sudo -s 
	$ echo 65536 > /proc/sys/fs/inotify/max_user_watches
	$ exit
