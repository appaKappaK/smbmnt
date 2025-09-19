# smbmnt 
## Features

- **Network Discovery**: Automatically scan networks for SMB servers using nmap
- **Share Discovery**: List available shares on discovered servers
- **Interactive & Command-line Modes**: Full menu-driven interface or direct command execution
- **Mount Management**: Mount/unmount individual shares or all at once
- **Desktop Integration**: Automatic GTK bookmarks and home directory symlinks
- **Status Dashboard**: View mounted shares and system status
- **Add entry(s) to fstab**: Create persistent mount configurations


## Requirements

- **Required**: `smbclient` `nmap` `cifs-utils`
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
#domain=your_domain
```

Set secure permissions: `chmod 600 ~/.smbcredentials`

## Configuration

Edit the script variables at the top:

```bash
DEFAULT_SERVER="SAMBAIP"                   # Default SMB server
DEFAULT_SHARES=("SHARES")                  # Available shares
MOUNT_BASE="/mnt"                          # Mount directory base
```

## Usage

### Network Discovery
```bash
smbmnt -S|--scan                      # Auto-detect and scan local network
smbmnt -S|--scan 192.168.0.0/24       # Scan specific network
smbmnt -Ss|--scan-shares 10.8.0.1     # List shares on specific server
smbmnt -D|--discovered                # Use previously discovered servers
```

### Mount Operations
```bash
smbmnt                   # Interactive mode
smbmnt 1                 # Mount share #1
smbmnt 1,3,5             # Mount shares 1, 3, and 5
smbmnt all               # Mount all shares
smbmnt -u|--unmount 1       # Unmount share #1
smbmnt -u|--unmount all     # Unmount all shares
```

### System Management
```bash
smbmnt -st|--status          # Show mount status dashboard
smbmnt -ls|--list            # List available shares
smbmnt --fstab 1,2...        # Generate fstab entries for shares 1,2...
```

### Advanced Options
```bash
smbmnt -ip 192.168.0.123        # Use different server
smbmnt -c /path/to/creds        # Use different credentials file
smbmnt --mount-base /media      # Use different mount base directory
```

## File Locations

- **Log file**: `~/.cache/smbmnt/smbmnt.log`
- **Cache directory**: `~/.cache/smbmnt/`
- **Discovered servers**: `~/.cache/smbmnt/discovered_servers`
- **Default credentials**: `~/.smbcredentials`
- **Mount points**: `/mnt` or `/smb`

## Desktop Integration

The script automatically:
- Searches for server IP(s), grabs the share name(s); without manually editing <-NEW
- Adds mounted shares to GTK file manager bookmarks
- Creates symlinks in home directory (`~/Samba-ShareName`)
- Removes bookmarks and symlinks when unmounting
