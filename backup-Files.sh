#!/bin/bash
elif [ "$1" == "-h" ]; then
	printf "Usage: %s FILE...\\n" "$0"
	exit 0
fi
BackupPath="${1:-"root@10.0.1.21:/Data/Backup/daily"}"
RemoteShell="${2:-ssh}"
Suffix="${4:-"$(date --iso-8601=second)"}"
printf "BackupPath = %s\\n" "$BackupPath"
printf "RemoteShell = %s\\n" "$RemoteShell"
printf "ExcludeFiles = %s\\n" "$ExcludeFiles"
printf "Suffix = %s\\n" "$Suffix"

for file in "$@"; do
	rsync -e "$RemoteShell" -i -ahxHAX --delete "$file" ${BackupPath}/
done | tee -a ~/new/log/rsync.files-\>backup."$Suffix".log
