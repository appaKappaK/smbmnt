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
| `gawk` | Proccessing Data |

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
chmod 600 ~/.smbcredentials  # Restrict the credentials file to your user only
```

## Installation

### Quick install

```bash
git clone https://github.com/appaKappaK/smbmnt.git  # Clone the repository
cd smbmnt                                           # Enter the project directory
sudo make install                                  # Install the script and man page under /usr/local
```

`make install` installs:

- `smbmnt-stable` as `/usr/local/bin/smbmnt`
- `smbmnt.1` as `/usr/local/share/man/man1/smbmnt.1.gz`
- bash completion if a completion file is bundled in the repository

To install under `/usr` instead:

```bash
sudo make PREFIX=/usr install  # Install under /usr instead of /usr/local
```

### Manual install

```bash
sudo install -m 755 smbmnt-stable /usr/local/bin/smbmnt          # Install the executable
sudo install -d /usr/local/share/man/man1                        # Create the man1 directory if needed
sudo install -m 644 smbmnt.1 /usr/local/share/man/man1/smbmnt.1  # Install the man page
sudo gzip -f /usr/local/share/man/man1/smbmnt.1                  # Compress the man page for the standard manpath layout
```

### Dependency check

```bash
make check  # Verify the expected runtime tools are available
```

## Quick start

```bash
smbmnt -Ss 10.8.0.1  # Scan shares on a server and save the result into config
sudo smbmnt all      # Mount all configured shares
smbmnt -ls           # List shares with mount and existence status
smbmnt -st           # Show the mount dashboard
smbmnt --config      # Inspect the active config
```

## Usage

### Discovery

```bash
smbmnt -S                # Auto-detect a private network and scan it for SMB servers
smbmnt -S 192.168.0.0/24 # Scan a specific network range
smbmnt -Ss 10.8.0.1      # Scan shares on one known server and optionally save them
smbmnt -D                # Pick from previously discovered servers
```

Notes:

- `-S` auto-detects a private RFC1918 network when you do not pass one.
- `-Ss` scans shares on a single server and can save the result into your
  config.
- `-D` lets you pick from previously discovered servers.

### Mounting

```bash
smbmnt                 # Interactive mount mode
smbmnt 1               # Mount share 1
smbmnt 1,3,5           # Mount several shares by index
smbmnt all             # Mount every configured share
smbmnt --dry-run all   # Preview the mount actions without executing them
```

### Unmounting

```bash
smbmnt -u               # Interactive unmount mode
smbmnt -u 1             # Unmount share 1
smbmnt -u all           # Unmount every configured share
smbmnt unmount 2        # Standalone unmount command form
smbmnt --dry-run -u all # Preview the unmount actions without executing them
```

### Status and configuration

```bash
smbmnt -ls                      # List configured shares with live existence and mount status
smbmnt -st                      # Show the mount dashboard
smbmnt --config                 # Show the active configuration
smbmnt --reset-config           # Reset saved config back to built-in defaults
smbmnt -ip 10.8.0.1             # Override the server for the current run
smbmnt -c /path/to/creds        # Use a different credentials file for the current run
smbmnt --mount-base /media/smb  # Change the base mount directory for the current run
smbmnt --smb-version 2.1        # Force an older SMB dialect for compatibility
```

### Fstab generation

```bash
smbmnt --dry-run --fstab all  # Preview fstab entries for all configured shares
smbmnt --fstab all            # Write fstab entries for all configured shares
smbmnt --fstab 1,2            # Write fstab entries for specific share indexes
smbmnt --fstab                # Use the default fstab selection behavior
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
smbmnt --debug all                  # Run a mount operation with debug logging enabled
SMBMNT_DEBUG=true smbmnt -S         # Enable debug logging via environment variable
SMBMNT_NO_SUDO=true smbmnt all      # Disable sudo/doas fallback completely
SMBMNT_PREFER_SUDO=true smbmnt all  # Prefer sudo/doas even if an unprivileged attempt might work
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
