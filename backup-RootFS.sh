#!/bin/bash

SearchDir="$1"
archive="$2"
wildcard="$3"
size="${4:-1024}"

[ -d "$SearchDir" ] && { [ ! -f "$archive" ] || [ "$archive" == "-" ]; } && [ "" != "$wildcard" ] || { \
	printf "Usage: %s SearchDir archive [wildcard]\\n" "$0" >&2
	exit -1
}
printf %s\\n "Searching Items..." >&2
readarray items < <(find / -xdev -mindepth 2 -path /home\* -prune -o -path /Data\* -prune -o -path /var/cache\* -prune -o -type f -print)
printf %s\\n "Archiving Items..." >&2
tar -cf "$archive" -C "$SearchDir" -T <(printf %s\\n "${items[@]}")
