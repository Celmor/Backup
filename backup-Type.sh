#!/bin/bash
cd "$1"
printf %s\\n "searching files..."
files=(); while read -rd '' file && read -rn1 && read -r type; do if [[ $type = ?(;*) ]]; then files+=("$file"); fi; done < <(find . -type f -exec file -0i {} +); declare -p files
tar -cJf "$3" -T <(printf %s\\n "${files[@]}")
