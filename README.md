# smbmnt

- **Network Discovery**: Automatically scan networks for SMB servers using nmap
- **Share Discovery**: List available shares on discovered servers
- **Interactive & Command-line Modes**: Full menu-driven interface or direct command execution
- **Mount Management**: Mount/unmount individual shares or all at once
- **Desktop Integration**: Automatic GTK bookmarks and home directory symlinks
- **Status Dashboard**: View mounted shares and system status
- **Add entry(s) to fstab**: Create persistent mount configurations
___
### Recent updates
```
    - Auto adds found shares and server IP so you do not need to manually do it
    - Better fitting parameters
    - Changed NMAP_OPTIONS from string to array
    - Changed how bookmarking detects pre-existing mounts/folders/share-names
    - Added nofail to mount parameters for --fstab
    - Fixed function so the script can be in system paths 
    - Other small fixes/additions...
    - Log rotation
    - Dynamic sizing
    - Better dependency checks
```
___
#### Requirements

- **Required**: `smbclient` `nmap` 
- **Permissions**: sudo access for editing ServerIP, share-name(s), and mounting/unmounting
- **Credentials**: SMB credentials file with proper permissions (600)

#### Installation

1. Move script to `mv smbmnt-stable /usr/local/bin/smbmnt`
2. Make executable: `chmod +x /usr/local/bin/smbmnt`
3. Create credentials file: `~/.smbcredentials`

#### Credentials File Format

```
username=your_username
password=your_password
#domain=your_domain
```

**Set secure permissions:** `chmod 600 ~/.smbcredentials`
___
### Usage

#### Network Discovery
```
smbmnt -S|--scan                      # Auto-detect and scan local network
smbmnt -S|--scan 192.168.0.0/24       # Scan specific network
smbmnt -Ss|--scan-shares 10.8.0.1     # List shares on specific server
smbmnt -D|--discovered                # Use previously discovered servers
```

#### Mount Operations
```
smbmnt                    # Interactive mode
smbmnt 1                  # Mount share #1
smbmnt 1,3,5              # Mount shares 1, 3, and 5
smbmnt all                # Mount all shares
smbmnt -u|--unmount 1     # Unmount share #1
smbmnt -u|--unmount all   # Unmount all shares
```

#### System Management
```
smbmnt -st|--status          # Show mount status dashboard
smbmnt -ls|--list            # List available shares
smbmnt --fstab 1,2...        # Generate fstab entries for shares 1,2...
```

#### Advanced Options
```
smbmnt -ip 192.168.0.123        # Use different server
smbmnt -c /path/to/creds        # Use different credentials file
smbmnt --mount-base /media      # Use different mount base directory
```
___
### File Locations

- **Log file**: `~/.cache/smbmnt/smbmnt.log`
- **Cache directory**: `~/.cache/smbmnt/`
- **Discovered servers**: `~/.cache/smbmnt/discovered_servers`
- **Default credentials**: `~/.smbcredentials`
- **Mount points**: `/mnt` or `/smb`
