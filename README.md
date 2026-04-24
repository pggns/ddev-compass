[![tests](https://github.com/pggns/ddev-compass/actions/workflows/tests.yml/badge.svg)](https://github.com/pggns/ddev-compass/actions/workflows/tests.yml)
[![last commit](https://img.shields.io/github/last-commit/pggns/ddev-compass)](https://github.com/pggns/ddev-compass/commits)
[![release](https://img.shields.io/github/v/release/pggns/ddev-compass)](https://github.com/pggns/ddev-compass/releases/latest)

# ddev-compass <!-- omit in toc -->

## Overview

This add-on integrates **MongoDB Compass** into your DDEV project in the same spirit as the built-in `ddev dbeaver` and `ddev heidisql` commands: one command — `ddev compass` — opens Compass on your host, already pointed at this project's MongoDB.

It works on macOS, Linux, native Windows (Git Bash/MSYS) and WSL2. On WSL2 it launches the Windows-installed Compass through `/mnt/c/...`, exactly like `ddev dbeaver` does for DBeaver.

## Requirements

- DDEV **v1.24.0** or newer
- The [`ddev/ddev-mongo`](https://github.com/ddev/ddev-mongo) add-on (installed automatically as a dependency)
- MongoDB Compass installed on the host — download from <https://www.mongodb.com/products/tools/compass>

## Installation

```bash
ddev add-on get pggns/ddev-compass
ddev restart
```

The restart is required because this add-on adds a port mapping (`0:27017`) to the `mongo` service so Compass can reach MongoDB from the host on a random free port.

## Usage

| Command | Description |
|---------|-------------|
| `ddev compass` | Launch MongoDB Compass connected to this project's MongoDB |

## How it works

1. `docker-compose.compass.yaml` exposes the `mongo` container's port `27017` on a random free port on the host (`ports: "0:27017"`). Random-port allocation means you can run several DDEV projects with Compass support simultaneously without conflicts.
2. The `ddev compass` host command reads credentials from `.ddev/.env.mongo` (falling back to the `db/db/db` defaults used by `ddev-mongo`), determines the current random host port via `docker port`, builds a `mongodb://` URI, and launches Compass with that URI as its first argument.
3. Compass is discovered on the host with the following lookup order:

   | Platform | Locations checked (first match wins) |
   |----------|--------------------------------------|
   | macOS | `/Applications/MongoDB Compass.app` |
   | Native Windows | `%LOCALAPPDATA%\MongoDBCompass\MongoDBCompass.exe`, `C:\Program Files\MongoDB Compass\MongoDBCompass.exe` |
   | WSL2 | `\\mnt\c\Users\<WIN_USER>\AppData\Local\MongoDBCompass\MongoDBCompass.exe`, `\\mnt\c\Program Files\MongoDB Compass\MongoDBCompass.exe` (launches the Windows Compass) |
   | Linux | `mongodb-compass` on `$PATH`, `/snap/bin/mongodb-compass`, `/usr/bin/mongodb-compass`, `flatpak run com.mongodb.Compass`, or a `MongoDB*Compass*.AppImage` in `~`, `~/Applications` or `~/Downloads` |

## Credentials

Credentials are sourced from `.ddev/.env.mongo`, which is the file `ddev-mongo` itself uses:

```bash
ddev dotenv set .ddev/.env.mongo \
  --mongo-initdb-root-username=myuser \
  --mongo-initdb-root-password=mypass \
  --mongo-initdb-database=myproject
ddev restart
```

Setting username and password to empty strings in that file disables authentication for the `ddev compass` URI as well — this matches the `ddev-mongo` behaviour.

Special characters in credentials (`@`, `:`, `/`, etc.) are URL-encoded automatically before being placed in the URI.

## Removal

```bash
ddev add-on remove compass
ddev restart
```

Every file installed by this add-on is marked with `#ddev-generated`, so removal is fully automatic.

## Troubleshooting

**`Project is not running`**
Run `ddev start` first.

**`Could not determine the host port for ddev-<project>-mongo:27017`**
The `ddev-mongo` service is either not installed or you haven't restarted since installing `ddev-compass`. Run `ddev restart`.

**`Could not find MongoDB Compass on your host`**
The binary is not in any of the locations scanned above. Install Compass from <https://www.mongodb.com/products/tools/compass>, or (on Linux) symlink your binary into `/usr/bin/mongodb-compass`.

**On WSL2 nothing happens when I run `ddev compass`**
Make sure Compass is installed on the **Windows** side (not inside your WSL2 distro). `ddev compass` on WSL2 launches the Windows Compass via `/mnt/c/...`, identically to how `ddev dbeaver` handles DBeaver.

## Credits

**Contributed and maintained by [@pggns](https://github.com/pggns)**

Follows the conventions established by [`ddev/ddev-mongo`](https://github.com/ddev/ddev-mongo) and the upstream `ddev dbeaver` / `ddev heidisql` host commands.
