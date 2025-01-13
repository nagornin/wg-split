#!/bin/sh

set -e

ns_name='vpn'
sudo="$(command -v pkexec || command -v doas || command -v sudo)"

if [ $(id -u) -ne 0 ]; then
    exec "$sudo" env WGS_USER_ENV="$(env | tr -d ' ')" \
        "$(realpath "$0")" "$@"
fi

if ! ip netns exec "$ns_name" true 2>/dev/null; then
    cd "$(dirname "$(realpath "$0")")"
    ./wgs-setup.sh
fi

ip netns exec "$ns_name" \
    runuser -l mike -c "env -S '$WGS_USER_ENV' $*"
