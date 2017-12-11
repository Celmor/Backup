#!/bin/bash
#

Print-Usage(){
	printf %s\\n "Backup each input folde ror file, overwriting if existing \
 to BackupPath/ using rsync with --delete."
	printf "Usage: %s [-v] [-c] [-p <BackupPath>] [-e RemoteShell] PATH...\\n" "$0" >&2
	exit 0
}

BackupPath="root@10.0.1.21:/Data/Backup/daily"
RemoteShell="ssh"
while getopts ":hvcp:e:" arg; do
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
    v)
      VERBOSE=1
      ;;
    c)
      CONTINUE=1
      ;;
    \?)
      Print-Usage
      ;;
  esac
done
shift $((OPTIND-1))

Write-Verbose(){
	[ "$VERBOSE" -eq 1 ] && echo "$@"
}
Write-Verbose "INFO: BackupPath = $BackupPath"
Write-Verbose "INFO: RemoteShell = $RemoteShell"

RETURN=0
for file in "$@"; do
	rsync -e "$RemoteShell" -i -ahxHAX --delete "$file" "$BackupPath"/"$file"
	RETURN=$?
	[ "$RETURN" -ne 0 ] && [ "$FORCE" -ne 1 ] && exit "$RETURN"
done
exit "$RETURN"
