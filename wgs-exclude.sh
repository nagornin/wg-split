#!/bin/sh

set -e

args="$(ip route | grep -v '^default ' | cut -d ' ' -f 3 | sed 's/^/--net=/')"

firejail --noprofile $args "$@"
