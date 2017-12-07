#!/bin/bash
if [ "$1" == "-h" ]; then
	printf "Usage: %s FILE...\\n" "$0"
	exit 0
fi
BackupPath="${1:-"root@10.0.1.21:/Data/Backup/daily"}"
printf "BackupPath = %s\\n" "$BackupPath"
printf "RemoteShell = %s\\n" "$RemoteShell"

for file in "$@"; do
	rsync -e "$RemoteShell" -i -ahxHAX --delete "$file" ${BackupPath}/
done
