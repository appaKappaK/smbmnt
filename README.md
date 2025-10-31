# **smbmnt**

- **Network Discovery**: Automatically scan networks for SMB servers using nmap
- **Share Discovery**: List available shares on discovered servers
- **Interactive & Command-line Modes**: Full menu-driven interface or direct command execution
- **Mount Management**: Mount/unmount individual shares or all at once
- **Desktop Integration**: Automatic GTK bookmarks and home directory symlinks
- **Status Dashboard**: View mounted shares and system status
- **Configuration Management**: Save, view, and reset server/share configurations
- **Dry-run Mode**: Preview actions (mount/unmount) without executing
- **Fstab Generation**: Create persistent mount configurations

---
#### Update History
```
    - Auto adds found shares and server IP so you do not need to manually do it # VER 2
    - Better fitting parameters # VER 2
    - Changed NMAP_OPTIONS from string to array # VER 2
    - Changed how bookmarking detects pre-existing mounts/folders/share-names # VER 2
    - Log Rotation # VER 2
    - Added nofail to mount parameters for --fstab # VER 2
    - Fixed function so the script can be in system paths # VER 2
    - Other small fixes/additions... # VER 2
```
#### Recent Updates
```
    - Implemented versioning
    - Better configuration setup
    - Added dry-run 
    - Better parsing
    - Improved CLI experience
    - Visible config/cache paths
    - Reworked the fstab entry generation
    - No longer need escalation to set serverIP/shares
```
___

#### Requirements 
- **Required**: `smbclient` `nmap` `mountpoint`
- **Permissions**: sudo access for mounting/unmounting/fstab entries/mount directories
- **Credentials**: SMB credentials file with proper permissions (600)
___
#### Installation
1. `git clone https://github.com/appaKappaK/smbmnt.git`
2. Move script to `mv smbmnt-stable /usr/local/bin/smbmnt`
3. Make executable: `chmod +x /usr/local/bin/smbmnt`
4. Create credentials file: `~/.smbcredentials`

#### Credentials File Format

```
username=your_username
password=your_password
#domain=your_domain
```

**Important to set permissions:** `chmod 600 ~/.smbcredentials`
___
#### Simple Start
1. `smbmnt -Ss YOUR_SERVER_IP`  # Discover and save shares
2. `sudo smbmnt all`            # Mount all shares
3. `smbmnt --config`            # Verify configuration
___

### Usage

#### Network Discovery
```
smbmnt -S|--scan # Auto-detect and scan local network
smbmnt -S|--scan 192.168.0.0/24 # Scan specific network
smbmnt -Ss|--scan-shares 10.8.0.1 # List shares on specific server
smbmnt -D|--discovered # Use previously discovered server(s)
```

#### Mount Operations
```
smbmnt # Interactive mount mode
smbmnt 1 # Mount share #1
smbmnt 1,3,5 # Mount shares 1, 3, and 5
smbmnt all # Mount all shares
smbmnt --dry-run all # Preview mount without executing
```

#### Unmount Operations
```
smbmnt -u|--unmount # Interactive unmount mode
smbmnt -u 1 # Unmount share #1
smbmnt -u all # Unmount all shares
smbmnt unmount 2 # Unmount share 2 (standalone command)
smbmnt --dry-run -u all # Preview unmount without executing
```

#### Config Management
```
smbmnt --config # Show current configuration
smbmnt --reset-config # Reset to default configuration
```

#### System Management
```
smbmnt -st|--status # Show mount status dashboard
smbmnt -ls|--list # List available shares
smbmnt --fstab # Interactive fstab generation
smbmnt --fstab all # Generate fstab entries for all shares
smbmnt --fstab 1,2 # Generate fstab entries for shares 1,2
```

#### Advanced Options
```
smbmnt -ip 192.168.0.123 # Use different server
smbmnt -c /path/to/creds # Use different credentials file
smbmnt --mount-base /media # Use different mount base directory
smbmnt --dry-run # Preview actions without executing
```
___
### File Locations

- **Log file**: `~/.cache/smbmnt/smbmnt.log`
- **Cache directory**: `~/.cache/smbmnt/`
- **Discovered servers**: `~/.cache/smbmnt/discovered_servers`
- **Configuration file**: `~/.config/smbmnt/config`
- **Default credentials**: `~/.smbcredentials`
- **Mount points**: `/mnt/samba-*`
