#!/bin/bash
export BORG_REPO='ssh://borg-backup@nas.example.net/volume1/BorgBackup/${USER}'
export BORG_PASSPHRASE='********'
export BORG_RSH='ssh -i ~/.config/borg/ssh/id_ed25519'
export BORG_BASE_DIR="${HOME}"
export BORG_CONFIG_DIR="${HOME}/.config/borg"
export BORG_CACHE_DIR="${HOME}/.cache/borg"
export BORG_SECURITY_DIR="${HOME}/.config/borg/security"
export BORG_KEYS_DIR="${HOME}/.config/borg/keys"
export BORG_KEY_FILE="${HOME}/.config/borg/keys/${USER}.key"
