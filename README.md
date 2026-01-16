orpheusmorebetter Docker
Docker container for orpheusmorebetter - automatic transcode uploader for Orpheus.
This is a vibe coded docker implementation of the orpheusmorebetter script.
It was built for personal use but feel free to use it at your own risk.
Features

Based on Python 3.13 alpine image
Includes all required dependencies (mktorrent, flac, lame, sox)
Runs as non-root user for security
Configurable PUID/PGID/UMASK for Unraid compatibility
Configurable volume mounts for data, output, and torrents

Quick Start
1. Install Container
2. Edit configuration
Edit ~/orpheus/config/.orpheusmorebetter/config with your Orpheus credentials and paths:
ini[orpheus]
username = YOUR_USERNAME
password = YOUR_PASSWORD
data_dir = /data
output_dir = /output
torrent_dir = /torrents
formats = flac, v0, 320
media = cd, vinyl, web
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
api = https://orpheus.network
mode = both
source = OPS

3. Run the container
bashdocker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v ~/orpheus/config:/config \
  -v /path/to/your/flac/files:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch/folder:/torrents \
  chodeus/orpheusmorebetter:latest

Usage

Scan all snatches and uploads
bashdocker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v ~/orpheus/config:/config \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest

Transcode a specific release
bashdocker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v ~/orpheus/config:/config \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest \
  "https://orpheus.network/torrents.php?id=1000&torrentid=1000000"

Additional options

bash# Use 4 threads for transcoding
docker run --rm ... chodeus/orpheusmorebetter:latest -j 4

# Don't upload (test mode)
docker run --rm ... chodeus/orpheusmorebetter:latest -U

# With 2FA TOTP
docker run --rm ... chodeus/orpheusmorebetter:latest -t 123456
Docker Compose
yamlversion: '3.8'
services:
  orpheusmorebetter:
    image: chodeus/orpheusmorebetter:latest
    container_name: orpheusmorebetter
    environment:
      - PUID=99          # User ID (99 = nobody on Unraid)
      - PGID=100         # Group ID (100 = users on Unraid)
      - UMASK=002        # File permission mask
    volumes:
      - ./config:/config
      - /path/to/your/flac/files:/data:ro
      - /path/to/output:/output
      - /path/to/watch/folder:/torrents
    # Since this is a task runner, not a daemon, you'll typically run it manually
    # Remove the command below to run interactively
    command: --help
    restart: "no"


## Unraid Setup

**Basic Unraid Template:**
```
<?xml version="1.0"?>
<Container version="2">
  <Name>orpheusmorebetter</Name>
  <Repository>chodeus/orpheusmorebetter:latest</Repository>
  <Registry>https://hub.docker.com/r/chodeus/orpheusmorebetter</Registry>
  <Network>bridge</Network>
  <Privileged>false</Privileged>
  <Support>https://github.com/CHODEUS/orpheusmorebetter</Support>
  <Project>https://github.com/CHODEUS/orpheusmorebetter</Project>
  <Overview>CLI-only container to automatically transcode and upload FLACs to orpheus.network. No web UI or listening ports. Configure via files under the /config mount (HOME).</Overview>
  <Category>Other</Category>
  <WebUI/>
  <Icon/>
  <ExtraParams/>
  <PostArgs/>
  <CPUset/>
  <DateInstalled>1762235398</DateInstalled>
  <DonateText/>
  <DonateLink/>
  <Requires>Edit the configuration files under the mapped /config path (default: /mnt/user/appdata/orpheusmorebetter) before running. This container expects directories: /config (HOME), /data, /output and /torrents.</Requires>

  <Config Name="PUID" Target="PUID" Default="99" Mode="" Description="User ID for file ownership (99 = nobody)" Type="Variable" Display="always" Required="true" Mask="false">99</Config>
  <Config Name="PGID" Target="PGID" Default="100" Mode="" Description="Group ID for file ownership (100 = users)" Type="Variable" Display="always" Required="true" Mask="false">100</Config>
  <Config Name="UMASK" Target="UMASK" Default="002" Mode="" Description="File permission mask (002 = rwxrwxr-x for folders, rw-rw-r-- for files)" Type="Variable" Display="always" Required="true" Mask="false">002</Config>
  
  <Config Name="Host Path for /config" Target="/config" Default="/mnt/user/appdata/orpheusmorebetter" Mode="rw" Description="Container HOME and persistent configuration. The app stores ~/.orpheusmorebetter here." Type="Path" Display="always" Required="true" Mask="false"></Config>
  <Config Name="Host Path for /data (input)" Target="/data" Default="" Mode="ro" Description="Input directory for music files to be processed (read-only recommended)." Type="Path" Display="always" Required="true" Mask="false"></Config>
  <Config Name="Host Path for /output" Target="/output" Default="" Mode="rw" Description="Output directory for transcoded files." Type="Path" Display="advanced" Required="false" Mask="false"></Config>
  <Config Name="Host Path for /torrents" Target="/torrents" Default="" Mode="rw" Description="Torrent/watch directory (torrent_dir in config)." Type="Path" Display="always" Required="true" Mask="false"></Config>
  
  <Config Name="TZ" Target="TZ" Default="Etc/UTC" Mode="" Description="Timezone (e.g. America/New_York)" Type="Variable" Display="advanced" Required="false" Mask="false"></Config>
  <Config Name="HOME" Target="HOME" Default="/config" Mode="" Description="Container HOME. The image sets HOME=/config so configuration is under this path." Type="Variable" Display="advanced" Required="false" Mask="false">/config</Config>

  <TailscaleStateDir/>
</Container>
```

**Volume Mappings:**

/config - Configuration files (persistent)
/data - Your FLAC source files (read-only recommended)
/output - Transcode output directory
/torrents - Torrent watch directory

| Container Path | Host Path | Access Mode |
|---------------|-----------|-------------|
| `/config` | `/mnt/user/appdata/orpheusmorebetter` | Read/Write |
| `/data` | `/mnt/user/path/to/flacs` | Read Only (recommended) |
| `/output` | `/mnt/user/path/to/output` | Read/Write |
| `/torrents` | `/mnt/user/path/to/watch` | Read/Write |

**Environment Variables:**

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `99` | User ID (99 = nobody on Unraid) |
| `PGID` | `100` | Group ID (100 = users on Unraid) |
| `UMASK` | `002` | File permission mask |
| `TZ` | `Etc/UTC` | Timezone |

### 2. Running on Unraid

Since this is a task-based container (not a daemon), you'll run it via container start/stop. The container will execute and stop when complete.

**To run manually:**
1. Start the container from Unraid Docker tab
2. Container will process files and stop automatically
3. Check logs for results

**For scheduled runs:**
Use Unraid's User Scripts plugin to start the container on a schedule.

### 3. Config and Container example

It should look something like this:

**Config file (`/mnt/user/appdata/orpheusmorebetter/.orpheusmorebetter/config`):**
```
[orpheus]
username = Myusername
password = Mytorrentsitepassword
data_dir = /data
output_dir = /output
torrent_dir = /torrents
formats = flac, v0, 320
media = cd, vinyl, web
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
mode = both
api = https://orpheus.network/
source = OPS
```

Security Notes

Container starts as root briefly to set permissions, then drops to PUID:PGID
Default runs as UID 99:100 (nobody:users) - non-root user
Credentials are stored in config file - keep this volume secure
Consider using read-only mount for source FLAC directory (/data:ro)
Never set PUID=0 (root) unless you understand the security implications

Credits

Original script: orpheusmorebetter
Based on whatbetter-crawler
Docker implementation: CHODEUS

License
See the original project for license information.
