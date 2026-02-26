# smbmnt

A secure, interactive SMB mount manager with network discovery support for LAN and WireGuard environments.

---

## Why smbmnt?

Linux SMB mounting lives in an awkward triangle: `mount -t cifs` (powerful but verbose), `/etc/fstab` (static and brittle), and file managers (GUI-only and inconsistent). smbmnt fills the missing middle — a secure, interactive CLI that remembers servers, discovers shares, and manages mounts without requiring you to memorise options or edit config files by hand.

---

## Features

- **Network Discovery** — Scan networks for SMB servers using nmap
- **Share Discovery** — List available shares on any discovered server
- **Interactive & CLI Modes** — Full menu-driven interface or direct command execution
- **Mount Management** — Mount/unmount individual shares or all at once
- **Status Dashboard** — View mounted shares, server info, and system state
- **Configuration Management** — Save, view, and reset server/share configurations
- **Dry-run Mode** — Preview any action before executing it
- **Fstab Generation** — Create persistent mount entries in `/etc/fstab`
- **Debug Mode** — Gated debug output via `--debug` or `SMBMNT_DEBUG=true`; also written to log file when active

---

## Requirements

| Tool | When Required |
|------|--------------|
| `mountpoint` | Always (part of `util-linux`) |
| `mount.cifs` | Mount/unmount operations (part of `cifs-utils`) |
| `smbclient` | Only for share scanning (`-Ss`) |
| `nmap` | Only for network scanning (`-S`) |

- **Permissions**: sudo access for mount/unmount/fstab/mount directory creation
- **Credentials**: SMB credentials file at `~/.smbcredentials` with permissions `600`

> **Note for Fedora / systems with Docker or WireGuard interfaces:** `nmap` requires
> root for raw socket scans. The script uses `sudo nmap` automatically. If auto-detection
> picks up a Docker bridge instead of your WireGuard interface, pass the network
> explicitly: `smbmnt -S 10.8.0.0/24`.

---

## Installation

### Quick install

```bash
git clone https://github.com/appaKappaK/smbmnt.git
cd smbmnt
sudo make install
```

`make install` copies the script to `/usr/local/bin/smbmnt`, installs the man
page to `/usr/local/share/man/man1/`, and installs bash completion if present.
Override the prefix with `PREFIX=/usr sudo make install`.

### Manual install

```bash
sudo cp smbmnt-stable /usr/local/bin/smbmnt
sudo chmod 755 /usr/local/bin/smbmnt
sudo cp smbmnt.1 /usr/local/share/man/man1/
sudo gzip /usr/local/share/man/man1/smbmnt.1
```

### Credentials file

Create `~/.smbcredentials`:

```
username=your_username
password=your_password
domain=your_domain  # optional
```

Lock down permissions:

```bash
chmod 600 ~/.smbcredentials
```

---

## Quick Start

```bash
smbmnt -Ss YOUR_SERVER_IP   # Discover and save shares
sudo smbmnt all             # Mount all shares
smbmnt --config             # Verify configuration
smbmnt -st                  # View mount status
```

---

## Usage

#### Network Discovery
```bash
smbmnt -S                       # Auto-detect and scan local network
smbmnt -S 192.168.0.0/24        # Scan specific network
smbmnt -Ss 10.8.0.1             # List shares on specific server
smbmnt -D                       # Use previously discovered server(s)
```

#### Mount Operations
```bash
smbmnt                          # Interactive mount mode
smbmnt 1                        # Mount share #1
smbmnt 1,3,5                    # Mount shares 1, 3, and 5
smbmnt all                      # Mount all shares
smbmnt --dry-run all            # Preview mount without executing
```

#### Unmount Operations
```bash
smbmnt -u                       # Interactive unmount mode
smbmnt -u 1                     # Unmount share #1
smbmnt -u all                   # Unmount all shares
smbmnt unmount 2                # Unmount share 2 (standalone)
smbmnt --dry-run -u all         # Preview unmount without executing
```

#### Configuration
```bash
smbmnt --config                 # Show current configuration
smbmnt --reset-config           # Reset to defaults
smbmnt -ip 192.168.0.123        # Override server for this session
smbmnt -c /path/to/creds        # Use different credentials file
smbmnt --mount-base /media/smb  # Override base mount directory for this session
smbmnt --smb-version 2.1        # Override SMB dialect (default: 3.1.1)
```

#### System & Status
```bash
smbmnt -st                      # Mount status dashboard
smbmnt -ls                      # List configured shares
smbmnt --fstab                  # Interactive fstab generation
smbmnt --fstab all              # Generate fstab entries for all shares
smbmnt --fstab 1,2              # Generate fstab entries for shares 1 and 2
smbmnt --dry-run --fstab all    # Preview fstab generation
```

#### Debug & Diagnostics
```bash
smbmnt --debug all              # Mount with debug output enabled
SMBMNT_DEBUG=true smbmnt -S    # Debug via environment variable
SMBMNT_NO_SUDO=true smbmnt all # Run without any privilege escalation
SMBMNT_PREFER_SUDO=true smbmnt all  # Always escalate via sudo/doas
smbmnt --version                # Show version
```

---

## File Locations

| Path | Purpose |
|------|---------|
| `~/.smbcredentials` | Default credentials file |
| `~/.config/smbmnt/config` | Saved server/share configuration |
| `~/.cache/smbmnt/smbmnt.log` | Log file |
| `~/.cache/smbmnt/discovered_servers` | Cached scan results |
| `/mnt/samba-<server>-<share>` | Mount points |

---

## Security Notes

- Credentials file is validated for existence, `600` permissions, and correct ownership before any mount operation
- Config file is parsed with `grep`/`sed` — never sourced — preventing code injection
- User input is rejected on invalid characters, never silently mutated
- `nmap` and `smbclient` are only required when their specific operations are invoked
- Scan and status operations do not require credentials to be present

---

## Update History

#### v3.2.0 — Feature Release (2026-02-26)
- Added `run_maybe_sudo()` — unified privilege escalation helper that tries without sudo first, then falls back to passwordless sudo, interactive sudo, and doas in sequence; avoids redundant escalation when already root
- Added `SMBMNT_NO_SUDO=true` environment variable to disable all privilege escalation globally
- Added `SMBMNT_PREFER_SUDO=true` environment variable to always escalate via sudo/doas even when unprivileged execution would suffice
- Added `--mount-base` CLI flag to override the base mount directory (`/mnt`) for this session
- Enhanced `list_shares` (`-ls`) with live server existence checking — configured shares are now verified against the server's actual share list and displayed with green (confirmed), red (not found), or black (server unreachable) indicators alongside mount status
- `show_status` (`-st`) and `mount_share` / `unmount_share` now use `run_maybe_sudo` consistently, replacing ad-hoc sudo patterns throughout

#### v3.1.1 — Bug Fix Release (2026-02-24)
- Fixed `temp_file: unbound variable` crash under `set -euo pipefail` — `local`
  declaration and `mktemp` assignment are now combined on one line; `trap` uses
  `${temp_file:-}` to satisfy `-u` without disabling strict mode
- Fixed network scan producing no results on Fedora and other systems where nmap
  requires root for raw socket access through WireGuard and similar interfaces —
  `discover_servers()` now calls `sudo nmap`
- Fixed nmap grepable output parsing — corrected grep pattern from `445/tcp.*open`
  to `445/open/tcp` to match actual nmap 7.92 field order (`port/state/protocol`)
- Added `|| true` to nmap pipeline so `set -e` does not kill the script when no
  hosts are found (grep exit code 1 on no match)

#### v3.1.0 — Stable Release (2025-02-24)
- All hardening from the 3.0.2.x series included
- Stable CLI interface and man page

#### v3.0.2.x — Hardening Series (3.0.2.1 → 3.0.2.7)
- `set -euo pipefail` — strict error handling throughout
- Replaced silent input mutation with strict rejection (`validate_input`)
- Lazy dependency enforcement — nmap/smbclient only required at point of use
- Credentials check gated by operation — scan/status/config work without credentials
- Config parsing hardened — `source` replaced with safe `grep`/`sed` parsing
- Removed GTK bookmark and symlink desktop integration (out of scope for CLI tool)
- `dmesg` removed from unmount path — replaced with `lsof` busy check
- `grep -P` (PCRE) removed — replaced with portable `sed`
- `echo -e` replaced with `printf "%b"` throughout
- `mount | grep` replaced with `/proc/mounts` for deterministic mount detection
- `trap RETURN` → `trap EXIT` for reliable temp file cleanup
- IPv4 validation hardened — rejects leading zeros (e.g. `010`) that cause octal ambiguity
- Mount paths include server IP — prevents collisions across multiple servers
- Credentials validated for ownership as well as permissions
- `--smb-version` CLI flag for dialect override (default: 3.1.1)
- Debug output gated behind `--debug` / `SMBMNT_DEBUG=true` — silent in production
- ANSI codes stripped from log file output

#### v2.x
- Auto-saves discovered server IP and shares — no manual configuration needed
- Improved CLI parameters and ergonomics
- `NMAP_OPTIONS` converted from string to array
- `nofail` added to fstab mount parameters
- Fixed script path resolution for system-wide installation (`/usr/local/bin`)
- Log rotation
- Various fixes and improvements

---

## Support & Contributions

- **Issues**: https://github.com/appaKappaK/smbmnt/issues
- **Pull requests** welcome with a clear description of the change
- I maintain this actively and respond to issues within a reasonable timeframe

---

## License

GNU GPL v2.0 — see [LICENSE](LICENSE)