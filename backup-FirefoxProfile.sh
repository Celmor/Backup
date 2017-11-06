#!/bin/bash
[[ "$1" == *-h* ]] && prinf 'Usage: %s [PROFILE] [BACKUPPATH] [SUFFIX]\n' "$0"
Profile=("${HOME}"/.mozilla/firefox/${1:-*.default})
BackupPath="${2:-./backup/ff}"
Suffix="${3:-"$(date --iso-8601=second)"}"
gzip < $Profile/places.sqlite > "$BackupPath"/"$(basename $Profile)".places.sqlite."$Suffix".gz
