#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	printf "Error: This script must be run as root\\n"
	exit -1
fi
Print-Usage(){
	printf "Usage: %s [BackupPath] [RemoteShell] [ExcludeFiles] [Suffix]\\n" "$0"
	exit 0
}

BackupPath="root@10.0.1.21:/Data/Backup/Linux/NVMeRoot"
RemoteShell="ssh"
ExcludeFiles="$(which "$0").txt"
while getopts ":hvp:e:f:" arg; do
  case $arg in
    h)
      Print-Usage
      ;;
    p)
      BackupPath=${OPTARG}
      ;;
    e)
      RemoteShell=${OPTARG}
      ;;
    f)
      ExcludeFiles=${OPTARG}
      ;;
    \?)
      Print-Usage
      ;;
  esac
done
shift $((OPTIND-1))

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
