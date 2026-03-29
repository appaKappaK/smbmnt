# Changelog

All notable changes to `smbmnt` will be documented in this file.

The format is based on a simple chronological release history with an
`Unreleased` section for work that has landed in the repository but has not
yet been tagged as a release.

## Unreleased

### Fixed
- Fixed `--fstab` validation on Fedora and similar systems where unprivileged
  CIFS fake mounts fail early. The script now creates missing mount directories
  before validation and validates temp `fstab` candidates through an already
  privileged path when available.
- Fixed `--fstab` error reporting so underlying validation failures are shown to
  the user instead of being swallowed behind a generic failure message.
- Fixed SMB share parsing for share names containing spaces so discovery and
  existence checks preserve names such as `My Documents` correctly.
- Fixed mixed numeric choice handling so inputs like `1,99` return a non-zero
  exit status instead of silently succeeding after logging an invalid choice.
- Fixed interactive cancellation so `Ctrl+C` exits cleanly with standard signal
  exit codes instead of only running cleanup.

### Changed
- Mount-point generation now avoids collisions between distinct share names that
  normalize to the same legacy path, while preserving existing simple paths
  where no collision exists.
- Shares that normalize to an empty mount component now receive a deterministic
  encoded fallback mount path instead of collapsing to a dangling directory
  name.
- Refreshed the README, CLI help text, and man page so the published
  documentation matches current `--fstab`, interrupt, and mount-path behavior.

## v3.2.1 - 2026-02-26

### Fixed
- Fixed `list_shares` silently treating every share as unknown when
  `smbclient` is not installed. The function now checks for `smbclient`
  upfront, emits a clear warning if it is missing, skips the query block
  entirely, and marks all existence indicators as `⚫` (unknown) rather than
  `🔴` (not found), which would incorrectly imply a check was performed.

## v3.2.0 - 2026-02-26

### Added
- Added `run_maybe_sudo()` as a unified privilege escalation helper that tries
  without sudo first, then falls back to passwordless sudo, interactive sudo,
  and doas in sequence; avoids redundant escalation when already root.
- Added `SMBMNT_NO_SUDO=true` to disable all privilege escalation globally.
- Added `SMBMNT_PREFER_SUDO=true` to always escalate via sudo/doas even when
  unprivileged execution would suffice.
- Added `--mount-base` to override the base mount directory (`/mnt`) for the
  current session.

### Changed
- Enhanced `list_shares` (`-ls`) with live server existence checking. Configured
  shares are now verified against the server's actual share list and displayed
  with green (confirmed), red (not found), or black (server unreachable)
  indicators alongside mount status.
- `show_status` (`-st`) and `mount_share` / `unmount_share` now use
  `run_maybe_sudo` consistently, replacing ad-hoc sudo patterns throughout.

## v3.1.1 - 2026-02-24

### Fixed
- Fixed `temp_file: unbound variable` crashes under `set -euo pipefail`.
  `local` declaration and `mktemp` assignment are now combined on one line, and
  the trap uses `${temp_file:-}` to satisfy `-u` without disabling strict mode.
- Fixed network scan producing no results on Fedora and other systems where
  `nmap` requires root for raw socket access through WireGuard and similar
  interfaces. `discover_servers()` now calls `sudo nmap`.
- Fixed nmap grepable output parsing by correcting the grep pattern from
  `445/tcp.*open` to `445/open/tcp` to match actual nmap 7.92 field order
  (`port/state/protocol`).
- Added `|| true` to the nmap pipeline so `set -e` does not kill the script
  when no hosts are found (`grep` exit code 1 on no match).

## v3.1.0 - 2025-02-24

### Changed
- Included all hardening from the 3.0.2.x series.
- Declared the CLI interface and man page stable.

## v3.0.2.x

### Changed
- Enabled `set -euo pipefail` strict error handling throughout.
- Replaced silent input mutation with strict rejection via `validate_input`.
- Switched to lazy dependency enforcement so `nmap` and `smbclient` are only
  required at point of use.
- Gated credentials checks by operation so scan/status/config work without
  credentials.
- Hardened config parsing by replacing `source` with safe `grep`/`sed` parsing.
- Removed GTK bookmark and symlink desktop integration as out of scope for a
  CLI tool.
- Removed `dmesg` from the unmount path and replaced it with `lsof` busy checks.
- Removed `grep -P` (PCRE) usage in favor of portable `sed`.
- Replaced `echo -e` with `printf "%b"` throughout.
- Replaced `mount | grep` with `/proc/mounts` for deterministic mount
  detection.
- Replaced `trap RETURN` with `trap EXIT` for reliable temp-file cleanup.
- Hardened IPv4 validation to reject leading zeros such as `010` that cause
  octal ambiguity.
- Included server IPs in mount paths to prevent collisions across multiple
  servers.
- Validated credentials for ownership as well as permissions.
- Added `--smb-version` for dialect override (default: `3.1.1`).
- Gated debug output behind `--debug` / `SMBMNT_DEBUG=true` so production runs
  stay quiet.
- Stripped ANSI codes from log file output.

## v2.x

### Changed
- Auto-saved discovered server IPs and shares so no manual configuration is
  needed.
- Improved CLI parameters and ergonomics.
- Converted `NMAP_OPTIONS` from a string to an array.
- Added `nofail` to generated `fstab` mount parameters.
- Fixed script path resolution for system-wide installation (`/usr/local/bin`).
- Added log rotation.
- Landed various fixes and improvements.
