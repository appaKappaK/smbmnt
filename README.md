# smbmnt 
## Features

- **Network Discovery**: Automatically scan networks for SMB servers using nmap
- **Share Discovery**: List available shares on discovered servers
- **Interactive & Command-line Modes**: Full menu-driven interface or direct command execution
- **Mount Management**: Mount/unmount individual shares or all at once
- **Desktop Integration**: Automatic GTK bookmarks and home directory symlinks
- **Status Dashboard**: View mounted shares and system status
- **fstab Add Entry**: Create persistent mount configurations
- **Logging**: Comprehensive logging with timestamps

## Requirements

- **Required**: `smbclient`, `nmap` (auto-installed if missing)
- **Permissions**: sudo access for mounting/unmounting
- **Credentials**: SMB credentials file with proper permissions (600)

## Installation

1. Copy script to `/usr/local/bin/smbmnt`
2. Make executable: `chmod +x /usr/local/bin/smbmnt`
3. Create credentials file: `~/.smbcredentials`

### Credentials File Format

```
username=your_username
password=your_password
domain=your_domain
```

Set secure permissions: `chmod 600 ~/.smbcredentials`

## Configuration

Edit the script variables at the top:

```bash
DEFAULT_SERVER="10.8.0.1"                    # Default SMB server
DEFAULT_SHARES=("Media-Drive1" "shared")      # Available shares
MOUNT_BASE="/mnt"                             # Mount directory base
```

## Usage

### Network Discovery
```bash
smbmnt --scan                     # Auto-detect and scan local network
smbmnt --scan 192.168.1.0/24     # Scan specific network
smbmnt --scan-shares 10.8.0.1    # List shares on specific server
smbmnt --discovered               # Use previously discovered servers
```

### Mount Operations
```bash
smbmnt                    # Interactive mode
smbmnt 1                  # Mount share #1
smbmnt 1,3,5             # Mount shares 1, 3, and 5
smbmnt all               # Mount all shares
smbmnt --unmount 1       # Unmount share #1
smbmnt --unmount all     # Unmount all shares
```

### System Management
```bash
smbmnt --status          # Show mount status dashboard
smbmnt --list            # List available shares
smbmnt --fstab 1,2       # Generate fstab entries for shares 1,2
```

### Advanced Options
```bash
smbmnt -s 192.168.1.100  # Use different server
smbmnt -c /path/to/creds # Use different credentials file
smbmnt -m /media         # Use different mount base directory
```

## File Locations

- **Log file**: `~/.cache/smbmnt/smbmnt.log`
- **Cache directory**: `~/.cache/smbmnt/`
- **Discovered servers**: `~/.cache/smbmnt/discovered_servers`
- **Default credentials**: `~/.smbcredentials`
- **Mount points**: `/mnt/samba-sharename` (configurable)

## Desktop Integration

The script automatically:
- Adds mounted shares to GTK file manager bookmarks
- Creates symlinks in home directory (`~/Samba-ShareName`)
- Removes bookmarks and symlinks when unmounting

## Troubleshooting

- **Permission denied**: Ensure credentials file has 600 permissions
- **Mount failures**: Check logs at `~/.cache/smbmnt/smbmnt.log`
- **Network discovery issues**: Verify nmap is installed and network is accessible
- **Share access**: Test with `smbclient -L //server-ip -A ~/.smbcredentials`
