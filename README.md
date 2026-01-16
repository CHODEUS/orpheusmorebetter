# orpheusmorebetter Docker

Docker container for **orpheusmorebetter**, an automatic transcode and upload helper for **Orpheus**.

This repository provides a Dockerised wrapper around the upstream
[`orpheusmorebetter`](https://github.com/walkrflocka/orpheusmorebetter) script.
Its purpose is to make running the tool easier and more reproducible, especially
on systems like **Unraid**, by bundling all dependencies and handling permissions
cleanly.

This container is intended for CLI / task-based usage only.  
There is **no web UI**, and the container will exit once processing is complete.

---

## Features

- Based on **Python 3.13 (Alpine)**
- Includes all required runtime dependencies:
  - `mktorrent`
  - `flac`
  - `lame`
  - `sox`
- Runs as a **non-root user** after initial setup
- Supports configurable **PUID / PGID / UMASK**
- Designed to work cleanly with:
  - Unraid
  - Seedboxes
  - Headless Linux hosts
- Simple volume-based configuration:
  - `/config` – persistent config and HOME
  - `/data` – source FLACs
  - `/output` – transcoded output
  - `/torrents` – torrent watch directory

---

## Quick Start

### 1. Pull the Image

```bash
docker pull chodeus/orpheusmorebetter:latest
```

---

### 2. Configure orpheusmorebetter

The upstream application stores its configuration relative to `$HOME`.
In this container, `HOME` is set to `/config`.

Create and edit:

```text
/config/.orpheusmorebetter/config
```

Example configuration:

```ini
[orpheus]
username = YOUR_USERNAME
password = YOUR_PASSWORD
data_dir = /data
output_dir = /output
torrent_dir = /torrents
formats = flac, v0, 320
media = cd, vinyl, web
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
api = https://orpheus.network/
mode = both
source = OPS
```

Refer to the upstream project for full configuration details and behaviour.

---

### 3. Run the Container

```bash
docker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v /path/to/config:/config \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest
```

The container will run the tool once and then exit.

---

## Usage

### Process All Eligible Snatches / Uploads

```bash
docker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v /path/to/config:/config \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest
```

---

### Process a Specific Release

```bash
docker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v /path/to/config:/config \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest \
  "https://orpheus.network/torrents.php?id=1000&torrentid=1000000"
```

---

## Additional CLI Options

All upstream CLI flags are supported.

```bash
# Use 4 parallel jobs
docker run --rm ... chodeus/orpheusmorebetter:latest -j 4

# Dry-run / do not upload
docker run --rm ... chodeus/orpheusmorebetter:latest -U

# Provide TOTP for 2FA
docker run --rm ... chodeus/orpheusmorebetter:latest -t 123456
```

---

## Docker Compose Example

```yaml
version: "3.8"

services:
  orpheusmorebetter:
    image: chodeus/orpheusmorebetter:latest
    container_name: orpheusmorebetter
    environment:
      - PUID=99
      - PGID=100
      - UMASK=002
    volumes:
      - ./config:/config
      - /path/to/flacs:/data:ro
      - /path/to/output:/output
      - /path/to/watch:/torrents
    command: --help
    restart: "no"
```

This is provided mainly for reference; the container is not intended to be
left running continuously.

---

## Unraid Setup

### Overview

This container is well-suited to Unraid because it:
- Respects `PUID` / `PGID`
- Stores all state under `/config`
- Runs as a one-shot task

You typically start it manually or via **User Scripts**, then let it exit.

---

### Unraid Template (XML)

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>orpheusmorebetter</Name>
  <Repository>chodeus/orpheusmorebetter:latest</Repository>
  <Registry>https://hub.docker.com/r/chodeus/orpheusmorebetter</Registry>
  <Network>bridge</Network>
  <Privileged>false</Privileged>

  <Support>https://github.com/CHODEUS/orpheusmorebetter</Support>
  <Project>https://github.com/CHODEUS/orpheusmorebetter</Project>

  <Overview>
CLI-only container to automatically transcode and upload FLACs to orpheus.network.
No web UI or listening ports. Configuration is done via files under /config.
  </Overview>

  <Category>Other</Category>

  <Config Name="PUID" Target="PUID" Default="99" Type="Variable" Display="always" />
  <Config Name="PGID" Target="PGID" Default="100" Type="Variable" Display="always" />
  <Config Name="UMASK" Target="UMASK" Default="002" Type="Variable" Display="always" />

  <Config Name="Config Path" Target="/config" Default="/mnt/user/appdata/orpheusmorebetter" Type="Path" Display="always" />
  <Config Name="FLAC Source" Target="/data" Type="Path" Display="always" />
  <Config Name="Output Path" Target="/output" Type="Path" Display="advanced" />
  <Config Name="Torrent Watch" Target="/torrents" Type="Path" Display="always" />
</Container>
```

---

### Recommended Volume Mapping

| Container Path | Purpose | Notes |
|---------------|---------|-------|
| `/config` | Configuration + HOME | Persistent |
| `/data` | Source FLACs | Read-only recommended |
| `/output` | Transcodes | Optional |
| `/torrents` | Watch directory | Required |

---

### Running on Unraid

- Start the container from the Docker tab
- Wait for it to complete
- Review logs
- Container will stop automatically

For automation, schedule runs using the **User Scripts** plugin.

---

## Security Notes

- Container briefly runs as root to fix ownership, then drops privileges
- Defaults to `99:100` (`nobody:users`)
- Credentials are stored in plaintext config files — protect `/config`
- Avoid setting `PUID=0` unless you understand the implications

---

## Credits

- Original project: **orpheusmorebetter**
- Based on: **whatbetter-crawler**
- Docker packaging: **CHODEUS**

---

## License

See the upstream project for license information.