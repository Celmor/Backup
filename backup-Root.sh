#!/bin/bash
#handle if variables RemoteShell and ExcludeFiles are unset

if test "$EUID" -ne 0; then
    printf "Error: This script must be run as root\\n" >&2
    exit -1
fi
################### FUNCTION ###################
Print-Usage(){
    printf "Usage: %s [-l] [-p <BackupPath>] [-e <RemoteShell>] [-f <ExcludeFiles>] [-r <RsyncArgs>] [-w WorkindDir] <source> ...\\n" "$0" >&2
    exit 0
}
function lvm_exit {
    printf \\n
    if test "$lvm"; then
      if mountpoint -q "$source"; then
        umount "$source" || exit 1
      fi
      if test -b "$lvm_VG-${lvm_snap//-/--}"; then
        lvremove -f "$(basename "$lvm_VG")/$lvm_snap" || exit 1
      fi
      if test -d "$source"; then
        rm -d "$source"
      fi
      exit $1
    fi
}

##################### VARS #####################
if [ -f "$(which "$0").txt" ]; then
    ExcludeFiles="$(which "$0").txt"
fi
BackupPath="/Data/Backup/Linux/NVMeRoot"    #defines default BackupPath
source=/                                    #defines backup source

while getopts ":p:e:f:ls:" arg; do
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
    w)
      workdir=${OPTARG}
      ;;
    l)
      lvm="lvm"
      ;;
    r)
      RsyncArgs=${OPTARG}
      ;;
    \?)
      Print-Usage
      ;;
  esac
done
shift $((OPTIND-1))
[ "$1" != "" ] && source=( "$@" )
if test "$lvm"; then
    source="$(mktemp -d /media/temp.XXX)" && \
    for s in "{source[@]}"; then
    lvm="$(df --output=source "$s" | tail -1)"    #e.g. /dev/mapper/ssd-root
    if [ "/dev/mapper" != "$(dirname "$lvm")" ]; then
        printf "Source isn't a filesystem on a logical volume: %s\\n" "$s" >&2 && \
        exit 2
    fi
    lvm_snap="$(basename "$lvm")"                    #-> ssd-root
    lvm_VG="${lvm%%-*}"                                #-> /dev/mapper/ssd
    lvm_snap="${lvm#*-}-snap-$(date +%F-%0H-%0M)"    #-> root-snap-2018-03-16-13-31 && \
    test "$lvm_snap" && test "$lvm_VG" || lvm_exit 1
    trap lvm_exit INT
fi

###################### UI ######################
if [ "$(df --output=source / | tail -1)" == "$(df --output=source "$BackupPath" | tail -1)" ]; then
    printf "Warning: BackupPath (\"%s\") is on the same Filesystem as the Root Filesystem (\"/\")\\n" "$BackupPath" >&2
fi
printf "${lvm:+lvm mapping: \t$lvm\\n}\
${lvm_snap:+lv snap: \t$(basename "$lvm_VG")/$lvm_snap\\n}\
source: \t%s
BackupPath: \t%s
${RemoteShell:+RemoteShell: \t$RemoteShell\\n}\
ExcludeFiles: \t%s\\n" \
"$source" "$BackupPath" "$ExcludeFiles" >&2
read -r -n 1 -p "Do you want to continue? [Y/n] " ans || { echo; exit; } && echo
case "$ans" in
    [yY][eE][sS]|[yY]|"")
      ;;
    *)
      lvm_exit
      ;;
esac

##################### EXEC #####################
if test "$lvm"; then
    lvcreate -L 5G --snapshot -n "$lvm_snap" "$lvm" && \
    mount "$lvm_VG-${lvm_snap//-/--}" "$source" || lvm_exit 1
fi
rsync ${RemoteShell:+-e "$RemoteShell"} -i --stats -ahHAX --delete ${ExcludeFiles:+"--exclude-from=$ExcludeFiles"} "$(printf '%s/ ' "${source[@]}")" "$BackupPath"/
lvm_exit

