#!/bin/sh

set -e

ns_name='vpn'
iface_name='wg0'
config='/home/user/wg0.conf' # Change this to your WireGuard config file

get_cfg_field() {
    grep "^$1" "${config:?}" | cut -d '=' -f 2 | tr -d '[:space:]'
}

sudo="$(command -v pkexec || command -v doas || command -v sudo)"

if [ $(id -u) -ne 0 ]; then
    exec "$sudo" "$0"
fi

addr="$(get_cfg_field 'Address')"
dns="$(get_cfg_field 'DNS')"

ip netns del "$ns_name" 2>/dev/null || true
rm -r "/etc/netns/${ns_name:?}/" 2>/dev/null || true
mkdir -p "/etc/netns/$ns_name/"

echo "$dns" \
    | tr ',' '\n' \
    | sed 's/^/nameserver /' \
    > "/etc/netns/$ns_name/resolv.conf"

ip netns add "$ns_name"
ip link add "$iface_name" type wireguard
ip link set "$iface_name" netns "$ns_name"
ip -n "$ns_name" addr add "$addr" dev "$iface_name"
tmp_conf="$(mktemp)"
trap "rm '$tmp_conf'" EXIT
grep -v -e '^Address' -e '^DNS' "${config:?}" > "$tmp_conf"
ip netns exec "$ns_name" wg setconf "$iface_name" "$tmp_conf"
ip -n "$ns_name" link set "$iface_name" up
ip -n "$ns_name" route add default dev "$iface_name"
