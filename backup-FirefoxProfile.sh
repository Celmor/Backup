#!/bin/bash
profile=("${HOME}"/.mozilla/firefox/*.default)
gzip < "$profile"/places.sqlite > "${HOME}"/backup/ff/"${profile##*/}".places.sqlite."$date".gz
