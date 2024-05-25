<p align="center">
  <a href="#how-to-build-manually">Manually</a> •
  <a href="#docker-images">Docker</a> •
  <a href="#s6-overlay-based-images">S6-overlay</a> •
  <a href="#how-to-create-a-keypair">Keypair</a> •
  <a href="#deb-packages">Debian</a> •
  <a href="#env-variables">Variables</a><br>
  [<a href="README-DE.md">Deutsch</a>] | [<a href="README-NL.md">Nederlands</a>] | [<a href="README-TW.md">繁體中文</a>] | [<a href="README-ZH.md">简体中文</a>]<br>
</p>

# SctgDesk Server Program

[![build](https://github.com/sctg-development/sctgdesk-server/actions/workflows/multiarch-docker-hub.yml/badge.svg)](https://github.com/sctg-development/sctgdesk-server/actions/workflows/multiarch-docker-hub.yml)

[**Binary Download**](https://github.com/sctg-development/sctgdesk-server/releases)  

[**API Documentation**](https://sctg-development.github.io/sctgdesk-api-server/)  

This is a modified version of RustDesk Server, which is free and open source.  

* The first difference is that this version includes the new *tcp* mode included in the RustDesk Server Pro version.  
* The second difference is that this version includes a preliminary implementation of the Rustdesk Server Pro API server.  
  * Support for personal address book
  * Support for shared address book at group level
    * read-only, read-write, admin (currently rules need to be set manually in the database)
  * Support for shared address book at user level
    * read-only, read-write, admin (currently rules need to be set manually in the database)
* The third difference is that this version includes a preliminary implementation of a simple webconsole.  

The webconsole is accessible at the address `http://<server-ip>:21114/`.  
You can browse the API documentation in the builtins API server at the address `http://<server-ip>:21114/api/doc/`.  

A non interactive API documentation is available at [sctgdesk-api-server repo](https://sctg-development.github.io/sctgdesk-api-server/).

## API Standalone version

The api standalone version is a version of the server that includes the API server and the webconsole but not the rendez-vous server.   
The standalone version is available in its own repository [sctgdesk-api-server](https://github.com/sctg-development/sctgdesk-api-server).
For all api or webconsole related issues, please refer to the [sctgdesk-api-server](https://github.com/sctg-development/sctgdesk-api-server) repository.

## Screenshots

### Webconsole

<img width="1085" alt="Capture d’écran 2024-05-24 à 11 48 13" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/fe72a374-8a98-4606-8632-3d919f9317c9">

<img width="1085" alt="Capture d’écran 2024-05-24 à 11 48 34" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/6ae55861-f65c-4950-a068-f22eef3ad81a">

<img width="1084" alt="Capture d’écran 2024-05-24 à 11 48 44" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/8d225841-43f5-44f4-8d41-5b6ca3324096">

<img width="1087" alt="Capture d’écran 2024-05-24 à 11 48 56" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/d84ce3d3-1d19-4765-883f-001f313a4a1e">

<img width="1089" alt="Capture d’écran 2024-05-24 à 11 49 13" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/db13010b-077a-4e14-943b-9d8de3266f82">

### Api documentation

<img width="1502" alt="apidoc" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/88fe7910-fe62-43e5-a16c-70dc1201e040">

### Use in Rustdesk client

<img width="913" alt="Capture d’écran 2024-05-24 à 12 14 34" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/1b253577-dce2-4163-9a49-ba4b3da37812">

<img width="923" alt="Capture d’écran 2024-05-24 à 12 07 21" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/c49b3aba-b13f-4b15-a69c-d492a90e774a">

<img width="927" alt="Capture d’écran 2024-05-24 à 12 07 32" src="https://github.com/sctg-development/sctgdesk-server/assets/165936401/f447f5fa-bc77-4bc6-858a-c6cadf9b7f6c">

# Security

The embedded API server is not secured nor protected agains DDOS attacks. A good practice is to use a reverse proxy in front of the API server. NGINX is a good choice for this purpose. HAProxy is also a good choice.  
We use HAProxy in front of the API server in our production environment.
This is our configuration file for HAProxy it is provided as an example only. You should adapt it to your own needs.:

```haproxy
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    retries 2
    timeout connect 3000ms
    timeout server 5000ms
    timeout client 5000ms

frontend hbbs_wss
    bind 0.0.0.0:21120 ssl crt /etc/haproxy/hbb.pem
    default_backend hbbs_wss_backend

frontend hbbs_api
    mode http
    option forwardfor
    bind 0.0.0.0:21114 ssl crt /etc/haproxy/api.pem
    http-request set-header X-Forwarded-Proto https
    default_backend hbbs_api_backend

frontend hbbs_api_443
    mode http
    option forwardfor
    bind 0.0.0.0:443 ssl crt /etc/haproxy/api.pem
    http-request set-header X-Forwarded-Proto https
    filter compression
    compression algo gzip
    compression type text/css text/html text/javascript application/javascript text/plain text/xml application/json
    compression offload
    default_backend hbbs_api_backend

frontend hbbr_wss
    bind 0.0.0.0:21121 ssl crt /etc/haproxy/hbb.pem
    default_backend hbbr_wss_backend

backend hbbs_api_backend
    mode http
    server srv_main 127.0.0.1:21113

backend hbbs_wss_backend
    server srv_main 127.0.0.1:21118

backend hbbr_wss_backend
    server srv_main 127.0.0.1:21119
```

The hbbs server is launched with

```service
[Unit]
Description=Rustdesk Signal Server

[Service]
Type=simple
LimitNOFILE=1000000
ExecStart=/usr/bin/hbbs --api-port=21113 -k AucFCOYVWNHRkJnx13FFh7C0tmUZ3nei5wXKmlfK6WPYthz65fRavaA5HO/OIz2kq+bCSlAqBkZgvikwVGqw/Q== --mask=10.10.0.235/24 -r rendez-vous.example.org -R rendez-vous.example.org
#Environment="RUST_LOG=debug"
Environment="ALWAYS_USE_RELAY=Y"
Environment="OAUTH2_CREATE_USER=1"
Environment="S3CONFIG_FILE=s3config.toml"
Environment="OAUTH2_CONFIG_FILE=oauth2.toml"
WorkingDirectory=/var/lib/rustdesk-server/
User=
Group=
Restart=always
StandardOutput=append:/var/log/rustdesk-server/hbbs.log
StandardError=append:/var/log/rustdesk-server/hbbs.error
# Restart service after 10 seconds if node service crashes
RestartSec=10

[Install]
WantedBy=multi-user.target
```

# RustDesk Server Program

[![build](https://github.com/rustdesk/rustdesk-server/actions/workflows/build.yaml/badge.svg)](https://github.com/rustdesk/rustdesk-server/actions/workflows/build.yaml)

[**Download**](https://github.com/rustdesk/rustdesk-server/releases)

[**Manual**](https://rustdesk.com/docs/en/self-host/)

[**FAQ**](https://github.com/rustdesk/rustdesk/wiki/FAQ)

Self-host your own RustDesk server, it is free and open source.

## How to build manually

First you need to have a working Rust development toolchain and a Node ≥ 20 working installation.  

```bash
DATABASE_URL=sqlite://$(pwd)/db_v2.sqlite3 cargo build --release
```

Three executables will be generated in target/release.

- hbbs - RustDesk ID/Rendezvous server with API server
- hbbr - RustDesk relay server
- rustdesk-utils - RustDesk CLI utilities

You can find updated binaries on the [releases](https://github.com/rustdesk/rustdesk-server/releases) page.

If you want extra features [RustDesk Server Pro](https://rustdesk.com/pricing.html) might suit you better.

If you want to develop your own server, [rustdesk-server-demo](https://github.com/rustdesk/rustdesk-server-demo) might be a better and simpler start for you than this repo.

## Docker images

Docker images are automatically generated and published on every github release. We have 2 kind of images.

### Classic image

These images are build against `ubuntu-20.04` with the only addition of the main binaries (`hbbr` and `hbbs`). They're available on [Docker hub](https://hub.docker.com/r/rustdesk/rustdesk-server/) with these tags:

| architecture | image:tag |
| --- | --- |
| amd64 | `rustdesk/rustdesk-server:latest` |
| arm64v8 | `rustdesk/rustdesk-server:latest-arm64v8` |

You can start these images directly with `docker run` with these commands:

```bash
docker run --name hbbs --net=host -v "$PWD/data:/root" -d rustdesk/rustdesk-server:latest hbbs -r <relay-server-ip[:port]> 
docker run --name hbbr --net=host -v "$PWD/data:/root" -d rustdesk/rustdesk-server:latest hbbr 
```

or without `--net=host`, but P2P direct connection can not work.

For systems using SELinux, replacing `/root` by `/root:z` is required for the containers to run correctly. Alternatively, SELinux container separation can be disabled completely adding the option `--security-opt label=disable`.

```bash
docker run --name hbbs -p 21114:21114 -p 21115:21115 -p 21116:21116 -p 21116:21116/udp -p 21118:21118 -v "$PWD/data:/root" -d rustdesk/rustdesk-server:latest hbbs -r <relay-server-ip[:port]> 
docker run --name hbbr -p 21117:21117 -p 21119:21119 -v "$PWD/data:/root" -d rustdesk/rustdesk-server:latest hbbr 
```

The `relay-server-ip` parameter is the IP address (or dns name) of the server running these containers. The **optional** `port` parameter has to be used if you use a port different than **21117** for `hbbr`.

You can also use docker-compose, using this configuration as a template:

```yaml
version: '3'

networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    ports:
      - 21115:21115
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21118:21118
    image: rustdesk/rustdesk-server:latest
    command: hbbs -r rustdesk.example.com:21117
    volumes:
      - ./data:/root
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    ports:
      - 21117:21117
      - 21119:21119
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    networks:
      - rustdesk-net
    restart: unless-stopped
```

Edit line 16 to point to your relay server (the one listening on port 21117). You can also edit the volume lines (line 18 and line 33) if you need.

(docker-compose credit goes to @lukebarone and @QuiGonLeong)


> Note that here, the rustdesk/rustdesk-server:latest in China may be replaced with the latest version number on dockerhub, such as rustdesk-server:1.1.10-3. Otherwise, the old version may be pulled due to image acceleration.

## S6-overlay based images

These images are build against `busybox:stable` with the addition of the binaries (both hbbr and hbbs) and [S6-overlay](https://github.com/just-containers/s6-overlay). They're available on [Docker hub](https://hub.docker.com/r/rustdesk/rustdesk-server-s6/) with these tags:

| architecture | version | image:tag |
| --- | --- | --- |
| multiarch | latest | `rustdesk/rustdesk-server-s6:latest` |
| amd64 | latest | `rustdesk/rustdesk-server-s6:latest-amd64` |
| i386 | latest | `rustdesk/rustdesk-server-s6:latest-i386` |
| arm64v8 | latest | `rustdesk/rustdesk-server-s6:latest-arm64v8` |
| armv7 | latest | `rustdesk/rustdesk-server-s6:latest-armv7` |
| multiarch | 2 | `rustdesk/rustdesk-server-s6:2` |
| amd64 | 2 | `rustdesk/rustdesk-server-s6:2-amd64` |
| i386 | 2 | `rustdesk/rustdesk-server-s6:2-i386` |
| arm64v8 | 2 | `rustdesk/rustdesk-server-s6:2-arm64v8` |
| armv7 | 2 | `rustdesk/rustdesk-server-s6:2-armv7` |
| multiarch | 2.0.0 | `rustdesk/rustdesk-server-s6:2.0.0` |
| amd64 | 2.0.0 | `rustdesk/rustdesk-server-s6:2.0.0-amd64` |
| i386 | 2.0.0 | `rustdesk/rustdesk-server-s6:2.0.0-i386` |
| arm64v8 | 2.0.0 | `rustdesk/rustdesk-server-s6:2.0.0-arm64v8` |
| armv7 | 2.0.0 | `rustdesk/rustdesk-server-s6:2.0.0-armv7` |

You're strongly encouraged to use the `multiarch` image either with the `major version` or `latest` tag.

The S6-overlay acts as a supervisor and keeps both process running, so with this image there's no need to have two separate running containers.

You can start these images directly with `docker run` with this command:

```bash
docker run --name rustdesk-server \ 
  --net=host \
  -e "RELAY=rustdeskrelay.example.com" \
  -e "ENCRYPTED_ONLY=1" \
  -v "$PWD/data:/data" -d rustdesk/rustdesk-server-s6:latest
```

or without `--net=host`, but P2P direct connection cannot work.

```bash
docker run --name rustdesk-server \
  -p 21115:21115 -p 21116:21116 -p 21116:21116/udp \
  -p 21117:21117 -p 21118:21118 -p 21119:21119 \
  -e "RELAY=rustdeskrelay.example.com" \
  -e "ENCRYPTED_ONLY=1" \
  -v "$PWD/data:/data" -d rustdesk/rustdesk-server-s6:latest
```

Or you can use a docker-compose file:

```yaml
version: '3'

services:
  rustdesk-server:
    container_name: rustdesk-server
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21117:21117
      - 21118:21118
      - 21119:21119
    image: rustdesk/rustdesk-server-s6:latest
    environment:
      - "RELAY=rustdesk.example.com:21117"
      - "ENCRYPTED_ONLY=1"
    volumes:
      - ./data:/data
    restart: unless-stopped
```

For this container image, you can use these environment variables, **in addition** to the ones specified in the following **ENV variables** section:

| variable | optional | description |
| --- | --- | --- |
| RELAY | no | the IP address/DNS name of the machine running this container |
| ENCRYPTED_ONLY | yes | if set to **"1"** unencrypted connection will not be accepted |
| KEY_PUB | yes | public part of the key pair |
| KEY_PRIV | yes | private part of the key pair |

### Secret management in S6-overlay based images

You can obviously keep the key pair in a docker volume, but the best practices tells you to not write the keys on the filesystem; so we provide a couple of options.

On container startup, the presence of the keypair is checked (`/data/id_ed25519.pub` and `/data/id_ed25519`) and if one of these keys doesn't exist, it's recreated from ENV variables or docker secrets.
Then the validity of the keypair is checked: if public and private keys doesn't match, the container will stop.
If you provide no keys, `hbbs` will generate one for you, and it'll place it in the default location.

#### Use ENV to store the key pair

You can use docker environment variables to store the keys. Just follow this examples:

```bash
docker run --name rustdesk-server \ 
  --net=host \
  -e "RELAY=rustdeskrelay.example.com" \
  -e "ENCRYPTED_ONLY=1" \
  -e "DB_URL=/db/db_v2.sqlite3" \
  -e "KEY_PRIV=FR2j78IxfwJNR+HjLluQ2Nh7eEryEeIZCwiQDPVe+PaITKyShphHAsPLn7So0OqRs92nGvSRdFJnE2MSyrKTIQ==" \
  -e "KEY_PUB=iEyskoaYRwLDy5+0qNDqkbPdpxr0kXRSZxNjEsqykyE=" \
  -v "$PWD/db:/db" -d rustdesk/rustdesk-server-s6:latest
```

```yaml
version: '3'

services:
  rustdesk-server:
    container_name: rustdesk-server
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21117:21117
      - 21118:21118
      - 21119:21119
    image: rustdesk/rustdesk-server-s6:latest
    environment:
      - "RELAY=rustdesk.example.com:21117"
      - "ENCRYPTED_ONLY=1"
      - "DB_URL=/db/db_v2.sqlite3"
      - "KEY_PRIV=FR2j78IxfwJNR+HjLluQ2Nh7eEryEeIZCwiQDPVe+PaITKyShphHAsPLn7So0OqRs92nGvSRdFJnE2MSyrKTIQ=="
      - "KEY_PUB=iEyskoaYRwLDy5+0qNDqkbPdpxr0kXRSZxNjEsqykyE="
    volumes:
      - ./db:/db
    restart: unless-stopped
```

#### Use Docker secrets to store the key pair

You can alternatively use docker secrets to store the keys.
This is useful if you're using **docker-compose** or **docker swarm**.
Just follow this examples:

```bash
cat secrets/id_ed25519.pub | docker secret create key_pub -
cat secrets/id_ed25519 | docker secret create key_priv -
docker service create --name rustdesk-server \
  --secret key_priv --secret key_pub \
  --net=host \
  -e "RELAY=rustdeskrelay.example.com" \
  -e "ENCRYPTED_ONLY=1" \
  -e "DB_URL=/db/db_v2.sqlite3" \
  --mount "type=bind,source=$PWD/db,destination=/db" \
  rustdesk/rustdesk-server-s6:latest
```

```yaml
version: '3'

services:
  rustdesk-server:
    container_name: rustdesk-server
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21117:21117
      - 21118:21118
      - 21119:21119
    image: rustdesk/rustdesk-server-s6:latest
    environment:
      - "RELAY=rustdesk.example.com:21117"
      - "ENCRYPTED_ONLY=1"
      - "DB_URL=/db/db_v2.sqlite3"
    volumes:
      - ./db:/db
    restart: unless-stopped
    secrets:
      - key_pub
      - key_priv

secrets:
  key_pub:
    file: secrets/id_ed25519.pub
  key_priv:
    file: secrets/id_ed25519      
```

## How to create a keypair

A keypair is needed for encryption; you can provide it, as explained before, but you need a way to create one.

You can use this command to generate a keypair:

```bash
/usr/bin/rustdesk-utils genkeypair
```

If you don't have (or don't want) the `rustdesk-utils` package installed on your system, you can invoke the same command with docker:

```bash
docker run --rm --entrypoint /usr/bin/rustdesk-utils  rustdesk/rustdesk-server-s6:latest genkeypair
```

The output will be something like this:

```text
Public Key:  8BLLhtzUBU/XKAH4mep3p+IX4DSApe7qbAwNH9nv4yA=
Secret Key:  egAVd44u33ZEUIDTtksGcHeVeAwywarEdHmf99KM5ajwEsuG3NQFT9coAfiZ6nen4hfgNICl7upsDA0f2e/jIA==
```

## .deb packages

Separate .deb packages are available for each binary, you can find them in the [releases](https://github.com/rustdesk/rustdesk-server/releases).
These packages are meant for the following distributions:

- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS
- Debian 11 bullseye
- Debian 10 buster

## ENV variables

hbbs and hbbr can be configured using these ENV variables.
You can specify the variables as usual or use an `.env` file.

| variable | binary | description |
| --- | --- | --- |
| ALWAYS_USE_RELAY | hbbs | if set to **"Y"** disallows direct peer connection |
| DB_URL | hbbs | path for database file |
| DOWNGRADE_START_CHECK | hbbr | delay (in seconds) before downgrade check |
| DOWNGRADE_THRESHOLD | hbbr | threshold of downgrade check (bit/ms) |
| KEY | hbbs/hbbr | if set force the use of a specific key, if set to **"_"** force the use of any key |
| LIMIT_SPEED | hbbr | speed limit (in Mb/s) |
| PORT | hbbs/hbbr | listening port (21116 for hbbs - 21117 for hbbr) |
| RELAY | hbbs | IP address/DNS name of the machines running hbbr (separated by comma) |
| RUST_LOG | all | set debug level (error\|warn\|info\|debug\|trace) |
| SINGLE_BANDWIDTH | hbbr | max bandwidth for a single connection (in Mb/s) |
| TOTAL_BANDWIDTH | hbbr | max total bandwidth (in Mb/s) |
