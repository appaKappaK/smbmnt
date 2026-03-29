# smbmnt

`smbmnt` is a secure, interactive SMB/CIFS mount manager for Linux.

It sits between raw `mount -t cifs`, static `/etc/fstab` entries, and GUI file
managers: fast enough for one-off use, structured enough to save and reuse a
server/share config, and careful enough to avoid a lot of the usual shell and
mounting footguns.

## Highlights

- Interactive or direct CLI workflows for mount, unmount, scan, status, and
  `fstab` generation
- Network discovery with `nmap` and share discovery with `smbclient`
- Saved server/share configuration under `~/.config/smbmnt/config`
- Dry-run support for mount, unmount, and `fstab` operations
- Unified privilege escalation with `sudo` / `doas` fallback behavior
- Share names with spaces supported
- Collision-safe mount-point generation when multiple shares would otherwise map
  to the same local path
- Clean `Ctrl+C` cancellation from interactive prompts

## Requirements

### Runtime

| Tool | When Required |
|------|---------------|
| `bash 4+` | Always |
| `mountpoint` | Always (`util-linux`) |
| `mount.cifs` | Mount / unmount operations (`cifs-utils`) |
| `smbclient` | Share scanning and live existence checks |
| `nmap` | Network scanning |

### Permissions

- Mounting, unmounting, `fstab` generation, and mount-directory creation may
  require root privileges.
- `smbmnt` will try the command unprivileged first when appropriate, then fall
  back to `sudo` or `doas` unless disabled.

### Credentials

Create `~/.smbcredentials`:

```ini
username=your_username
password=your_password
domain=your_domain
```

Then lock it down:

```bash
# Restrict the credentials file to your user only
chmod 600 ~/.smbcredentials
```

## Installation

### Quick install

```bash
# Clone the repository
git clone https://github.com/appaKappaK/smbmnt.git
# Enter the project directory
cd smbmnt
# Install the script and man page under /usr/local
sudo make install
```

`make install` installs:

- `smbmnt-stable` as `/usr/local/bin/smbmnt`
- `smbmnt.1` as `/usr/local/share/man/man1/smbmnt.1.gz`
- bash completion if a completion file is bundled in the repository

To install under `/usr` instead:

```bash
# Install under /usr instead of /usr/local
sudo make PREFIX=/usr install
```

### Manual install

```bash
# Install the executable
sudo install -m 755 smbmnt-stable /usr/local/bin/smbmnt
# Create the man1 directory if needed
sudo install -d /usr/local/share/man/man1
# Install the man page
sudo install -m 644 smbmnt.1 /usr/local/share/man/man1/smbmnt.1
# Compress the man page for the standard manpath layout
sudo gzip -f /usr/local/share/man/man1/smbmnt.1
```

### Dependency check

```bash
# Verify the expected runtime tools are available
make check
```

## Quick start

```bash
# Scan shares on a server and save the result into config
smbmnt -Ss 10.8.0.1
# Mount all configured shares
sudo smbmnt all
# List shares with mount and existence status
smbmnt -ls
# Show the mount dashboard
smbmnt -st
# Inspect the active config
smbmnt --config
```

## Usage

### Discovery

```bash
# Auto-detect a private network and scan it for SMB servers
smbmnt -S
# Scan a specific network range
smbmnt -S 192.168.0.0/24
# Scan shares on one known server and optionally save them
smbmnt -Ss 10.8.0.1
# Pick from previously discovered servers
smbmnt -D
```

Notes:

- `-S` auto-detects a private RFC1918 network when you do not pass one.
- `-Ss` scans shares on a single server and can save the result into your
  config.
- `-D` lets you pick from previously discovered servers.

### Mounting

```bash
# Interactive mount mode
smbmnt
# Mount share 1
smbmnt 1
# Mount several shares by index
smbmnt 1,3,5
# Mount every configured share
smbmnt all
# Preview the mount actions without executing them
smbmnt --dry-run all
```

### Unmounting

```bash
# Interactive unmount mode
smbmnt -u
# Unmount share 1
smbmnt -u 1
# Unmount every configured share
smbmnt -u all
# Standalone unmount command form
smbmnt unmount 2
# Preview the unmount actions without executing them
smbmnt --dry-run -u all
```

### Status and configuration

```bash
# List configured shares with live existence and mount status
smbmnt -ls
# Show the mount dashboard
smbmnt -st
# Show the active configuration
smbmnt --config
# Reset saved config back to built-in defaults
smbmnt --reset-config
# Override the server for the current run
smbmnt -ip 10.8.0.1
# Use a different credentials file for the current run
smbmnt -c /path/to/creds
# Change the base mount directory for the current run
smbmnt --mount-base /media/smb
# Force an older SMB dialect for compatibility
smbmnt --smb-version 2.1
```

### Fstab generation

```bash
# Preview fstab entries for all configured shares
smbmnt --dry-run --fstab all
# Write fstab entries for all configured shares
smbmnt --fstab all
# Write fstab entries for specific share indexes
smbmnt --fstab 1,2
# Use the default fstab selection behavior
smbmnt --fstab
```

Notes:

- `--fstab` without a choice defaults to all configured shares.
- The script validates a temporary `fstab` candidate before replacing
  `/etc/fstab`.
- On Fedora and similar systems, validation is performed through a privileged
  path when needed so CIFS fake-mount checks do not fail early as an
  unprivileged user.

### Debug and environment flags

```bash
# Run a mount operation with debug logging enabled
smbmnt --debug all
# Enable debug logging via environment variable
SMBMNT_DEBUG=true smbmnt -S
# Disable sudo/doas fallback completely
SMBMNT_NO_SUDO=true smbmnt all
# Prefer sudo/doas even if an unprivileged attempt might work
SMBMNT_PREFER_SUDO=true smbmnt all
```

## Behavior notes

### Mount-point naming

Mount points live under `/mnt` by default and always include the server:

```text
/mnt/samba-<server>-<share>
```

Most shares keep a clean legacy-style name such as:

```text
/mnt/samba-10-8-0-1-cloud
```

If two configured shares would normalize to the same local path, `smbmnt`
keeps them distinct with a deterministic suffix. For example:

```text
Foo Bar  -> /mnt/samba-10-8-0-1-foo_bar--Foo%20Bar
foo_bar  -> /mnt/samba-10-8-0-1-foo_bar
```

Shares that normalize to an empty component also get a deterministic fallback.

### Cancellation

Interactive prompts can be cancelled with `Ctrl+C`. The script cleans up any
temporary files and exits with the standard interrupt status.

### Security model

- Credentials are checked before mount operations.
- Config files are parsed with `grep` / `sed`, never sourced.
- Input containing shell-significant characters is rejected rather than
  silently rewritten.
- Optional tools are only required at the point where their feature is used.

## File locations

| Path | Purpose |
|------|---------|
| `~/.smbcredentials` | Default credentials file |
| `~/.config/smbmnt/config` | Saved server/share configuration |
| `~/.cache/smbmnt/smbmnt.log` | Operational log |
| `~/.cache/smbmnt/discovered_servers` | Cached discovery results |
| `/mnt/samba-*` | Generated mount directories |

## Documentation

- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Man page: [smbmnt.1](smbmnt.1)

## Support

- Issues: https://github.com/appaKappaK/smbmnt/issues
- Pull requests are welcome with a clear description of the change

## License

GNU GPL v2.0 or later. See [LICENSE](LICENSE).
