#!/bin/bash
if [ "$1" == "-h" ]; then
	printf "Usage: %s BACKUPPATH REMOTESHELL FILE...\\n" "$0"
	exit 0
fi
[ "$1" = "" ] && BackupPath="root@10.0.1.21:/Data/Backup/daily" || BackupPath="$1"
[ "$2" = "" ] && RemoteShell="ssh" || BackupPath="$2"

shift 2
printf "BackupPath = %s\\n" "$BackupPath"
printf "RemoteShell = %s\\n" "$RemoteShell"

for file in "$@"; do
	rsync -e "$RemoteShell" -i -ahxHAX --delete "$file" "$BackupPath"/"$file"
done
