#!/bin/bash
#handle if variables RemoteShell and ExcludeFiles are unset

if [ "$EUID" -ne 0 ]; then
	printf "Error: This script must be run as root\\n"
	exit -1
fi
Print-Usage(){
	printf "Usage: %s [-p <BackupPath>] [-e <RemoteShell>] [-f <ExcludeFiles>]\\n" "$0"
	exit 0
}
if [ -f "$(which "$0").txt" ]; then
	ExcludeFiles="$(which "$0").txt"
fi
BackupPath="/Data/Backup/Linux/NVMeRoot" #defines default BackupPath

while getopts ":p:e:f:l:" arg; do
  case $arg in
    p)
      BackupPath=${OPTARG}
      ;;
    e)
      RemoteShell="${OPTARG}"
      ;;
    f)
      ExcludeFiles=${OPTARG}
      ;;
	l)
	  lvm="$(df --output=source / | tail -1)"
	  lvcreate -L 5G --snapshot -n "$(basename "$lvm")-$(date +%F-%0H-%0M)" "$lvm" || exit 1
	  ;;
    \?)
      Print-Usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$(df --output=source / | tail -1)" == "$(df --output=source "$BackupPath" | tail -1)" ]; then
	printf "Warning: BackupPath (\"%s\") is on the same Filesystem as the Root Filesystem (\"/\")\\n" "$BackupPath"
fi
printf "BackupPath = \"%s\"\\n" "$BackupPath" >&2
printf "RemoteShell = \"%s\"\\n" "$RemoteShell" >&2
printf "ExcludeFiles = \"%s\"\\n" "$ExcludeFiles" >&2
read -r -n 1 -p "Do you want to continue? [Y/n] " ans || { echo; exit; } && echo
case "$ans" in
    [yY][eE][sS]|[yY]|"")
        ;;
    *)

	exit
        ;;
esac

rsync ${RemoteShell:+-e "$RemoteShell"} -i -ahxHAX --delete ${ExcludeFiles:+"--exclude-from=$ExcludeFiles"} / "$BackupPath"/
if test "$lvm"; then
	lvremove -f "$(basename "$lvm")-$(date +%F-%0H-%0M)"
fi
