NAS Backup
==========

We use NAS (Network Attached Storage) devices for two main purposes:

 * as backup storage;
 * for storing larger amounts of non-critical files (download mirrors, media
   files, etc.);

Additionally we use a second device on a remote location for off-site backup.

The remote system is off most of the day. It is scheduled to turn itself on
every night and pull the latest backup data from the local system and
subsequently shut down again after that. It can by turned on remotely anytime
if needed trough WOL (Wake On LAN).


Local Backup Storage
--------------------

Shared Folder for Backups
^^^^^^^^^^^^^^^^^^^^^^^^^

For storing backups of our various devices we create a shared folder on the
local NAS:

 #. Open "Control Panel"
 #. Select "Shared Folder"
 #. Click on the "Create" button
 #. Set a name and description, i. e. like "backup" and "System backups".
 #. Don't activate "Enable Recycle Bin".


File Services for Backup
^^^^^^^^^^^^^^^^^^^^^^^^

For the SFTP (secure file transfer) service:

 #. Open "Control Panel"
 #. Select "File Services"
 #. Click on the "FTP" tab.
 #. Scroll down to the "SFTP" section.
 #. Activate the "Enable SFTP service" option.
 #. Choose a random TCP port number and set it as "Port number".
 #. In the "General" section below click on the "Advanced Settings" button.
 #. Deactivate the "Enable FTP file transfer log" option.
 #. Deactivate the "Change user root directories" option.
 #. Deactivate the "Enable Anonymous FTP" option.
 #. Activate the "Apply default UNIX permisssions" option.
 #. Click the "OK" button to return.
 #. Confirm the settings by hitting the "Apply" button.


For the rsync service:

 #. Open "Control Panel"
 #. Select "File Services"
 #. Select the "rsync" tab
 #. Activate "Enable rsync service"
 #. Choose a random TCP port number and set it as "SSH encryption port".
 #. Don't activate "Enable rsync account".
 #. Click the "Apply" button to store and activate.


Prepare for SSH keys
^^^^^^^^^^^^^^^^^^^^

In DSM

Since we will authenticate SSH users by public keys instead of passwords, users
need home directories to store their public keys.

 #. Open "Control Panel"
 #. Select "User"
 #. Click on the "Advanced" tab.
 #. Scroll down to the "User Home" section at the bottom of the dialog.
 #. Activate the "Enable user home service" option.
 #. Activate the "Enable Recycle Bin" option.
 #. Confirm the settings by hitting the "Apply" button.


Users need access to the homes shared folder. This can be achieved by ...

 #. Open "Control Panel".
 #. Select "Shared Folder".
 #. Select "homes" from the list of shared folders.
 #. Click the "Edit" button.
 #. Select the "Permissions" tab.
 #. Select "Local groups" in the drop-down on the left above the list of users.
 #. Select the "users" group and click on the "Custom" column.
 #. In the "Permission Editor" dialog select "Traverse folder/Execute files".
 #. Click the "OK" button to exit the dialog.
 #. Click the "OK" button to exit the "Edit Shared Folder" dialog.


On the command line:

Open a SSH command-line session as root on the DiskStation.

Change users home folder permissions, so that only the owner itself has access::

  $ cd /volume1/homes
  $ chmod 0700 user1 user2 user3 ...


Change the users SSH configuration directory :file:`.ssh` permissions, so that
only the user himself is allowed::

  $ chmod 0700 /volume1/homes/*/.ssh


Restrict access to the users SSH public keys::

  $ chmod 0600 /volume1/homes/*/.ssh/authorized_keys


.. Note::

  This removes any Windows ACL settings on these folders.



User Group for Backup Clients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create a user group for the backup clients:

 #. Open "Control Panel"
 #. Select "Group"
 #. Click on the "Create" button
 #. Set the groups name as "backup" and a description like "Backup clients"
 #. Click the "Next" button.
 #. Set shared folder permissions by activating the "Read/Write" permission on
    the line of the "backup" share.
 #. Click the "Next" button.
 #. Skip the "Quota Settings" and click the "Next" button again.
 #. Assign application permissions for FTP and rsync only.
 #. Click the "Next" button.
 #. Skip the "Group Speed Limit Settings" and click the "Next" button again.
 #. Confirm the settings by hitting the "Apply" button.


User Profiles for Backup Clients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create a user profile for every device that will store its backup data on local
NAS and also one for the remote backup NAS.

 #. Open "Control Panel"
 #. Select "User"
 #. Click on the "Create" button
 #. Set a name and description of the device which will send its backups here.
 #. Use your own email address to receive notifications.
 #. Create a strong random password.
 #. Deactivate the "Send a notification mail ..." option.
 #. Activate the "Disallow the user to change account password"
 #. Click the "Next" button.
 #. Add the user to the "backup" group in the "Join groups".
 #. Skip the "Assign shared folder permissions" and click the "Next" button again.
 #. Skip the "User quota settings" and click the "Next" button again.
 #. Skip the "Assign application permissions" and click the "Next" button again.
 #. Skip the "User Speed Limit Settings" and click the "Next" button again.
 #. Confirm the settings by hitting the "Apply" button.

The backups are performed by the devices themselves. The local NAS just provides
the storage over SFTP (secure file transfer over SSH) for severs and desktops
and rsync over SSH for routers.


Remote Backup Storage
---------------------

Add the same "backup" group and all of its users, as in the local NAS.

Login to the DSM with your administrator account and create shell script in your home
directory::

    #!/bin/bash

    LOCAL_DIR="/volume1/"
    SSH_USER="mccoy"
    SSH_ID="/root/.ssh/id_ed25519.pub"
    SSH_HOST="scott.example.net"
    SSH_PORT="17251"
    REMOTE_DIR="/volume1/backup"
    LOGFILE="/volume1/homes/admin/rsync.log"

    RSYNC_RSH="ssh -p ${SSH_PORT}"
    source="${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}"
    target="$LOCAL_DIR"

    /bin/rsync --archive --delete --super --rsh "${RSYNC_RSH}" \
                --log-file ${LOGFILE} \
                --human-readable --stats \
                "${source}" "${target}"


Notes
-----

Why not use Synology Hyper-Backup?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Synology Hyper Backup uses a proprietary storage format. The backed up data is
only accessible with Synology software.


Why not use Synology Hyper-Backup in "single-version"?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While "legacy-mode" or "single-version" backed up files are just stored in its
native form in folders and remain accessible without Synology software,
 * deletions are not propagated to the backup folders. It will add files but never
   delete any;
 * Backups are push only. A remote system can not pull the backup data.


Why not use Synology Backup Vault on the remote NAS?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 * Only works with backup-data created by Hyper-Backup in its proprietary format;
 * Backups are push only. The remote NAS is not can not pull the backup data
   from the local one by itself.


Why not use Synology Shared-Folder-Sync?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 * Again this is a one-way push only solution which must be initiated by the
   local NAS.


Why not use Synology Cloud Station ShareSync?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 * Has a more overhead as it does a lot we don't need, i.e. file versioning.
   The backup solutions on the clients already take care of that.


Why not use Synology Cloud Station Backup?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 * Cloud Station Backup is a solution geared towards desktop systems.
   We are mostly talking about backing up servers and routers.

 * Ubuntu Desktop has a well integrated backup solution (DejaDup) which
   transfers its backup data via SFTP.
