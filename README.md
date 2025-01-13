# wg-split

This is a series of scripts that allows you to:

- Run a specific application/command through a WireGuard tunnel
- Exclude an application from a WireGuard tunnel

## Warning

The code is pretty hacky and probably has bugs, but it _works on my machine_. Notably, you have to set the `DNS` field in your WireGuard config for it to work properly. There's certainly a better way to do split tunneling on Linux.

## Usage

Edit `wgs-setup.sh` and specify a path to your WireGuard config file. After that, you can run `wgs-route.sh` with your command to route it through the tunnel. Alternatively, run `wgs-exclude.sh` to exclude a program from the tunnel.

Do NOT run these scripts as root, they will prompt you for a password automatically.

## How it works

- `wgs-setup.sh` creates a new network namespace that only has the WireGuard interface in it.
- `wgs-route.sh` executes a command in the network namespace that was set up by `wg-setup.sh`.
- `wgs-exclude.sh` simply uses firejail to add all interfaces to a sandbox _except_ the WireGuard interface. This seems to work well enough.
