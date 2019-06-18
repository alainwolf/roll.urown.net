#!/bin/bash
export BORG_REPO='ssh://borg-backup@nas.example.net/volume1/BorgBackup/client.example.net'
export BORG_PASSPHRASE='********'
export BORG_RSH='ssh -i /etc/borg/ssh/id_ed25519 -o BatchMode=yes -o VerifyHostKeyDNS=yes'
export BORG_BASE_DIR="/var/lib/borg"
export BORG_CONFIG_DIR="/etc/borg"
export BORG_CACHE_DIR="/var/lib/borg/cache"
export BORG_SECURITY_DIR="/var/lib/borg/security"
export BORG_KEYS_DIR="/etc/borg/keys"
export BORG_KEY_FILE="/etc/borg/keys/client.example.net.key"
