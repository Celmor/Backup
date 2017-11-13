#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	printf "Error: This script must be run as root"
	exit -1
elif [ "$1" == "-h" ]; then
	printf "Usage: %s [BackupPath] [RemoteShell] [ExcludeFiles] [Suffix]\\n" "$0"
	exit 0
fi
BackupPath="${1:-"root@10.0.1.21:/Data/Backup/Linux/NVMeRoot"}"
RemoteShell="${2:-ssh -i /home/celmor/.ssh/id_rsa}"
ExcludeFiles="${3:-"$(which "$0").txt"}"
Suffix="${4:-"$(date --iso-8601=second)"}"
printf "BackupPath = %s\\n" "$BackupPath"
printf "RemoteShell = %s\\n" "$RemoteShell"
printf "ExcludeFiles = %s\\n" "$ExcludeFiles"
printf "Suffix = %s\\n" "$Suffix"

rsync -e "$RemoteShell" -i -ahxHAX --delete --delete-excluded --exclude-from=${ExcludeFiles} / ${BackupPath}/ | tee ~/new/log/rsync.root-\>backup."$Suffix".log
