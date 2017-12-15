#!/bin/bash
if [ "$1" == "-h" ]; then
	printf "Usage: %s [BackupPath] [RemoteShell] [ExcludeFiles] [Suffix]\\n" "$0"
	exit 0
elif [ "$EUID" -ne 0 ]; then
	printf "Error: This script must be run as root\\n"
	exit -1
fi

BackupPath="${1:-"root@10.0.1.21:/Data/Backup/Linux/NVMeRoot"}"
RemoteShell="${2:-ssh}"
ExcludeFiles="${3:-"$(which "$0").txt"}"
printf "BackupPath = %s\\n" "$BackupPath"
printf "RemoteShell = %s\\n" "$RemoteShell"
printf "ExcludeFiles = %s\\n" "$ExcludeFiles"
read -r -n 1 -p "Do you want to continue? [Y/n] " ans || { echo; exit; } && echo
case "$ans" in
    [yY][eE][sS]|[yY]|"")
        ;;
    *)

	exit
        ;;
esac

rsync -e "$RemoteShell" -i -ahxHAX --delete --delete-excluded --exclude-from=${ExcludeFiles} / ${BackupPath}/
