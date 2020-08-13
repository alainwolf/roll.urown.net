#!/bin/ash
#
# OpenWRT router backup script
#

# Abort on any error
set -e

# List of directories and files to backup
BACKUP_LIST='/etc /root'

# Create a temporary directory to store backup archives
LOCAL_DIR=$(mktemp -d)
BACKUP_FILE="${HOSTNAME}-$(date +'%F_%H-%M-%S')"

# OpenPGP key ID to encrypt backup files to.
PGP_ID='0x0123456789ABCDEF'

# Remote system to store backups
SSH_HOST='nas.lan'
SSH_PORT='17251'
SSH_USER='router'
SSH_ID='/root/.ssh/id_rsa'
REMOTE_DIR='/volume1/backup/router'

LOGFILE='/var/log/backup.log'
RSYNC_RSH="ssh -p ${SSH_PORT} -i ${SSH_ID}"
source="$LOCAL_DIR/${BACKUP_FILE}.tar.gz.gpg"
target="${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/"

# List of all installed packages
/bin/opkg list-installed > /root/opkg-installed.txt

# List of 'user installed' packages
awk '/^Package:/{PKG= $2} /^Status: .*user installed/{print PKG}' /usr/lib/opkg/status \
    > /root/opkg-user-installed.txt

# List of user changed configuration files
/bin/opkg list-changed-conffiles > /root/opkg-conffiles.txt

# Backup and compress
/bin/tar --create --exclude-backups --auto-compress \
    --file "${LOCAL_DIR}/${BACKUP_FILE}.tar.gz" \
    "${BACKUP_LIST}"

# Encrypt
/usr/bin/gpg --batch --no-default-recipient --recipient "${PGP_ID}" \
    --encrypt "${LOCAL_DIR}/${BACKUP_FILE}.tar.gz"

# Transfer
/usr/bin/rsync --archive --delete --rsh "${RSYNC_RSH}" \
            --log-file "${LOGFILE}" \
            --human-readable --stats --verbose \
            "${source}" "${target}"

#/usr/bin/scp -i ${SSH_ID} -p 6883 ${source} ${target}

# Remove the temporary directory
rm -rf "$LOCAL_DIR"
