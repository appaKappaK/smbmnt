# SMBmnt - Universal Samba Mount Command

A powerful Bash script for mounting, unmounting, and managing Samba (SMB) shares with network discovery capabilities. This script simplifies connecting to Samba servers, scanning for shares, and managing mounts with a user-friendly interface.

## Features

- **Mount/Unmount Shares**: Mount or unmount Samba shares with a single command.
- **Network Discovery**: Scan local networks for Samba servers using `nmap`.
- **Share Scanning**: List available shares on a specified server.
- **Fstab Generation**: Generate `/etc/fstab` entries for persistent mounts.
- **Dry Run Mode**: Simulate operations without executing them.
- **Status Dashboard**: View the status of mounted shares.
- **Interactive Mode**: User-friendly interface for selecting shares and servers.
- **Secure Configuration**: Validates credentials file permissions and uses modern SMB protocol versions (default: 3.1.1).
- **Logging**: Detailed logs for troubleshooting in `~/.cache/smbmnt/smbmnt.log`.
- **Side Panel Integration**: Adds mounted shares to file manager bookmarks (GTK-based) and creates desktop symlinks.

## Requirements

- Bash shell
- `nmap` (for network discovery)
- `smbclient` (for share scanning)
- `mount` and `umount` (standard on Linux systems)
- Sudo privileges for mounting, unmounting, and editing `/etc/fstab`
- A Samba credentials file with secure permissions (`chmod 600`)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/appaKappaK/smbmnt.git
   cd smbmnt
   ```
2. Make the script executable:
   ```bash
   chmod +x smbmnt
   ```
3. Optionally, move the script to a directory in your PATH:
   ```bash
   sudo mv smbmnt /usr/local/bin/
   ```

## Configuration

Edit the user configuration section at the top of the `smbmnt` script to set:

- `DEFAULT_SERVER`: Your primary Samba server IP or hostname (e.g., `10.8.0.1` for WireGuard setups).
- `DEFAULT_CREDENTIALS`: Path to your Samba credentials file (format: `username=your_username`, `password=your_password`, `domain=your_domain` (optional)).
- `DEFAULT_SHARES`: Array of commonly accessed share names (e.g., `Media-Drive1`, `shared`).
- `MOUNT_BASE`: Directory where shares will be mounted (e.g., `/mnt`).
- `NETWORK_SCAN_PREFERENCE`: Optional network range for scanning (e.g., `192.168.1.0/24`).
- `SMB_VERSION`: Preferred SMB protocol version (default: `3.1.1`).

Ensure your credentials file is secure:
```bash
chmod 600 ~/.smbcredentials
```

## Usage

```bash
smbmnt [OPTIONS] [CHOICE]
```

### Options

- `-s, --server IP`: Specify Samba server IP/hostname.
- `-c, --credentials`: Specify credentials file.
- `-m, --mount-base`: Specify base mount directory.
- `-l, --list`: List available shares.
- `-u, --unmount`: Unmount shares instead of mounting.
- `--scan [NETWORK]`: Discover SMB servers on the network.
- `--scan-shares IP`: List shares on a specific server.
- `--status`: Show mount status dashboard.
- `--discovered`: Use previously discovered servers.
- `--dry-run`: Simulate operations without executing.
- `--fstab`: Generate `/etc/fstab` entries.
- `-h, --help`: Show help.

### Choices

- `1-N`: Mount/unmount a specific share number.
- `1,2,3`: Mount/unmount multiple shares (comma-separated).
- `all`: Mount/unmount all shares.
- `(none)`: Enter interactive mode.

### Examples

- Scan for Samba servers:
  ```bash
  smbmnt --scan
  ```
- List shares on a server:
  ```bash
  smbmnt --scan-shares 10.8.0.1
  ```
- Mount a specific share:
  ```bash
  smbmnt 1
  ```
- Mount multiple shares:
  ```bash
  smbmnt 1,2,3
  ```
- Unmount all shares:
  ```bash
  smbmnt -u all
  ```
- Generate fstab entries:
  ```bash
  smbmnt --fstab 1,2
  ```
- Show status dashboard:
  ```bash
  smbmnt --status
  ```

## Logging

Operations are logged to `~/.cache/smbmnt/smbmnt.log` for troubleshooting.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Notes

- Ensure `nmap` and `smbclient` are installed:
  ```bash
  sudo apt-get install nmap smbclient  # Debian/Ubuntu
  sudo dnf install nmap samba-client  # Fedora/RHEL
  sudo pacman -S nmap smbclient       # Arch Linux
  ```
- The script requires sudo for mounting, unmounting, and editing `/etc/fstab`.
- For WireGuard setups (e.g., `10.8.0.1`), ensure the server is accessible via the VPN interface.
- Keep your credentials file secure to prevent unauthorized access.
