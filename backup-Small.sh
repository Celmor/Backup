#!/bin/bash
SearchDir="$1"
archive="$2"
wildcard="$3"
#size="$4"
[ -d "$SearchDir" ] || [ ! -f "$archive" ] || [ "" != "$wildcard" ] || { \
	printf "Usage: %s SearchDir archive [wildcard]\\n" "$0"
	exit -1
}

cd "$SearchDir"
printf %s\\n "searching Items..."
items=()
while read -rd '' item; do
	if [ "$(du -cx ~/sh/Backup/.git | awk 'END { print $1 }')" -lt 5120 ]; then # less than 5MiB
		items+=("$item")
	fi
done < <(find . -iname "$wildcard" -print0)
tar -cJf "$archive" -T <(printf %s\\n "${files[@]}")
