#!/bin/bash
# Searches files matching "wildcard" (should at least be "*") in "SearchDir" of size below 1MiB
#  or whatever "size" is set to (value in KiB units) and tars and compresses them
# "archive" should not already exist, this script can't add files to a pre-existing archive
# if archive name is "-" it will be written out to stdout, e.g. for compression
# EXAMPLE:
# ./Backup/backup-Small.sh ./Backup - "*" | xz > testb.tar.xz
# tar -xJf Backup.tar.xz
# xz -cdk Backup.tar.xz | tar -tf -

SearchDir="$1"
archive="$2"
wildcard="$3"
size="${4:-1024}"

[ -d "$SearchDir" ] && { [ ! -f "$archive" ] || [ "$archive" == "-" ]; } && [ "" != "$wildcard" ] || { \
	printf "Usage: %s SearchDir archive [wildcard]\\n" "$0" >&2
	exit -1
}
printf %s\\n "Searching Items..." >&2
items=()
while read -rd '' item; do
	if [ "$(du -cx "$SearchDir"/"$item" | awk 'END { print $1 }')" -lt "$size" ]; then # less than 1MiB or $size
		items+=("$item")
	fi
done < <(cd "$SearchDir" && find ./* -iname "$wildcard" ! -name "$archive" -print0 2>/dev/null)
printf %s\\n "Archiving Items..." >&2
tar -cf "$archive" -C "$SearchDir" -T <(printf %s\\n "${items[@]}")
