#!/bin/bash
SearchDir="$1"
archive="$2"
type="$3"
[ -d "$SearchDir" ] || [ ! -f "$archive" ] || [ "" != "$type" ] || { \
	printf "Usage: %s SearchDir archive type\\n" "$0"
	exit -1
}

cd "$SearchDir"
printf %s\\n "searching files..."
files=(); while read -rd '' file && read -rn1 && read -r type; do if [[ $type = ?(;*) ]]; then files+=("$file"); fi; done < <(find . -type f -exec file -0i {} +); declare -p files
tar -cJf "$archive" -T <(printf %s\\n "${files[@]}")
