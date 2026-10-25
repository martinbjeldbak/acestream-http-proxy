# AceStream HTTP Proxy

[![Build and push Docker image to DockerHub](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml/badge.svg)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/build-and-push-docker.yml)
[![Lint](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint.yaml/badge.svg)](https://github.com/martinbjeldbak/acestream-http-proxy/actions/workflows/lint.yaml)

This Docker image runs the AceStream Engine and exposes its [HTTP
API](https://docs.acestream.net/en/developers/connect-to-engine/).

As a result, you will be able to watch AceStreams over HLS or MPEG-TS, without
needing to install the AceStream player or any other dependencies locally.

This is especially useful for Desktop and NAS usage for anyone who wants to
tune in to AceStream channels, and who don't want to go through the trouble of
installing AceStream and its dependencies natively.

Note: ARM-based CPUs are not currently supported, see issues [#5] and [#13].

## Usage

Ensure you have [Docker](https://www.docker.com) installed and running. You can then pull down and run the container as shown below.

```console
docker run -t -p 6878:6878 ghcr.io/martinbjeldbak/acestream-http-proxy
```

You are then able to access AceStreams by pointing your favorite media player
(VLC, IINA, etc.) to either of the below URLs, depending on the desired
streaming protocol.

For HLS:

```console
http://127.0.0.1:6878/ace/manifest.m3u8?id=dd1e67078381739d14beca697356ab76d49d1a2
```

For MPEG-TS:

```console
http://127.0.0.1:6878/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2
```

where `dd1e67078381739d14beca697356ab76d49d1a2d` is the ID of the AceStream channel.

This image can also be deployed to a server, where it can proxy AceStream
content over HTTP. To accept connections from other hosts on your network (LAN
or VPN), set `ALLOW_REMOTE_ACCESS=yes`; see [Remote access](#remote-access).

You can also run it using Compose with

```yaml
---
services:
  acestream-http-proxy:
    image: ghcr.io/martinbjeldbak/acestream-http-proxy
    container_name: acestream-http-proxy
    ports:
      - 6878:6878
    environment:
      - ALLOW_REMOTE_ACCESS=no # change to "yes" to accept connections from other hosts
    volumes:
      - acestream-data:/home/appuser/.ACEStream # engine database and cache

volumes:
  acestream-data:
```

for an example, see the [compose.yaml](./compose.yaml) file in this repository.

## Configuration

### Remote access

`ALLOW_REMOTE_ACCESS` must be exactly `yes` or `no` (lowercase); any other
value, including `true` or `YES`, is treated as `no`.

The AceStream engine has no authentication. Enabling remote access lets any host
that can reach port 6878 start streams through your connection, so only enable
it on a trusted network, restrict the published port to your LAN or VPN
interface, and never expose it directly to the internet. It is not required for
[reverse proxy](#reverse-proxy) setups.

### Custom engine flags

Any [engine command line option][engine-options] can be passed as a
space-separated `EXTRA_FLAGS` value:

```yaml
environment:
  - EXTRA_FLAGS=--use-internal-buffering 1 --cache-limit 4
```

Do not add quotes inside the value (`EXTRA_FLAGS='--cache-limit 4'` passes a
literal `'` to the engine and the container exits with `No such option`).
Invalid flags or values make the container exit immediately rather than being
silently ignored.

Flags are appended after the image defaults (`--cache-dir … --cache-limit 1
--client-console`), so they override the same option set by default, and after
`--bind-all`. If you change `--http-port`, publish that port instead of 6878.
The authoritative list of options is the one the bundled engine prints:

```console
docker run --rm --entrypoint /app/start-engine \
  ghcr.io/martinbjeldbak/acestream-http-proxy --client-console --help
```

### Persistence

The engine writes its database, cache and logs to `/home/appuser/.ACEStream`
(owned by UID/GID 1000), which is the only writable path apart from `/.cache`.
Mount a volume there to keep the engine state across container restarts;
`compose.yaml` uses a `tmpfs` for it by default.

## Ports

| Port        | Protocol | Purpose                                                     |
| ----------- | -------- | ----------------------------------------------------------- |
| `6878`      | TCP      | HTTP API: HLS, MPEG-TS and `/webui/api/service`             |
| `62062`     | TCP      | Engine API, fixed                                           |
| `8621`      | TCP, UDP | Peer-to-peer service, fixed                                 |
| random high | UDP      | BitTorrent peer sockets, re-picked on every container start |

Only `6878` is required to watch streams, as the engine connects out to trackers
and peers by itself. Publishing `62062` and `8621` can help other peers connect
in to you, but the random UDP ports cannot be published reliably. The
`acestream.upnp|Failed to init port forward` log line is expected in a container
and harmless.

## Reverse proxy

The engine answers with **absolute** URLs built from the request's `Host`
header: `GET /ace/manifest.m3u8?id=…` returns a `302` to
`http://<Host header>/ace/m/<hash>/<token>.m3u8`, and the playlist and segment
URLs use the same base. It takes that base from the `Host` header, port
included, so the proxy only has to forward `Host` unchanged.

Two consequences:

- If the forwarded `Host` has no port, the engine appends its own (6878), e.g.
  `http://example.com:6878/…`. nginx's `$host` strips the port, so use
  `$http_host` instead.
- The scheme is always `http://`; `X-Forwarded-Proto` is ignored. Terminate TLS
  at the proxy and let the player follow the `http://` URLs on the same
  hostname.

Serve the engine on its own subdomain: the URLs are rooted at `/ace/` and
`/content/`, so a subpath such as `/acestream/` would require rewriting the
playlist body.

### nginx

```nginx
location / {
    proxy_pass http://acestream-http-proxy:6878; # container name, not 127.0.0.1
    proxy_set_header Host $http_host;            # not $host: the port is required
    proxy_http_version 1.1;
    proxy_buffering off;                         # live HLS / MPEG-TS
    proxy_read_timeout 1h;
}
```

### Caddy

Caddy forwards `Host` unchanged, so no header overrides are needed:

```caddyfile
ace.example.com {
    reverse_proxy acestream-http-proxy:6878
}
```

Do not set `header_up Host {upstream_hostport}`, as the engine would then
redirect to the container's internal hostname.

### Authentication middleware

Media players (VLC, IINA, mpv, Infuse, Jellyfin) do not send browser session
cookies, so site-wide authentication such as `forward_auth` (Authelia, SWAG)
redirects every playlist and segment request to a login page. Either protect
only the entry point and bypass authentication on the tokenised paths, or keep
the engine reachable from your LAN/VPN only:

| Path                                         | Note                        |
| -------------------------------------------- | --------------------------- |
| `/ace/manifest.m3u8`, `/ace/getstream`       | contains the content ID     |
| `/ace/m/<hash>/<token>.m3u8`                 | playlist, per-session token |
| `/ace/r/<hash>/<token>`, `/content/<hash>/…` | MPEG-TS redirect and stream |
| `/ace/c/<hash>/<n>.ts`                       | HLS segments                |

## Buffering and caching

The engine has no "buffer a number of seconds" setting: it emits HLS from a
sliding window of roughly 5–7 second segments (`#EXT-X-TARGETDURATION:7`), and
the playback API exposes no latency parameter. What can be tuned is the
engine's cache, which tolerates slow peers without changing latency, and the
player's read-ahead, which absorbs jitter:

```console
mpv --cache=yes --demuxer-max-bytes=256M --demuxer-readahead-secs=60 \
  'http://127.0.0.1:6878/ace/manifest.m3u8?id=<content-id>'
vlc --network-caching=15000 \
  'http://127.0.0.1:6878/ace/manifest.m3u8?id=<content-id>'
```

Engine-side options include `--cache-limit` (disk cache ceiling in GB, `1` by
default), `--cache-max-bytes`, `--cache-auto` and `--use-internal-buffering`.

To find out whether a stalled stream is the engine or the player, request the
JSON form to get a `stat_url`, then poll it while the player is stuck:

```console
curl 'http://127.0.0.1:6878/ace/manifest.m3u8?id=<content-id>&format=json'
curl 'http://127.0.0.1:6878/ace/stat/<infohash>/<token>'
```

If `downloaded` keeps climbing while playback is frozen, the player stopped
reading; if the session disappears or stays in `prebuf`, the source or peers are
the problem.

## Running through a VPN

An HTTP proxy is not sufficient for routing all AceStream traffic: the engine
honours `HTTP_PROXY`/`HTTPS_PROXY` for its HTTP control traffic only, and there
is no SOCKS support. Peer traffic goes out directly, so a proxy does not hide
your IP from the swarm. To route everything through a VPN, share the VPN
container's network namespace instead:

```yaml
services:
  gluetun:
    image: qmcgaw/gluetun
    cap_add:
      - NET_ADMIN
    ports:
      - 6878:6878 # published on the VPN container, not on acestream
    environment:
      - FIREWALL_INPUT_PORTS=6878
      # VPN_SERVICE_PROVIDER=...

  acestream-http-proxy:
    image: ghcr.io/martinbjeldbak/acestream-http-proxy
    network_mode: service:gluetun
    depends_on:
      - gluetun
    environment:
      - ALLOW_REMOTE_ACCESS=yes
    volumes:
      - acestream-data:/home/appuser/.ACEStream

volumes:
  acestream-data:
```

Ports must be published on the VPN container: with `network_mode:
service:gluetun`, a `ports:` block on `acestream-http-proxy` has no effect.

## Troubleshooting

The engine is chatty at startup, and most of what it prints is harmless. These
lines appear on a healthy container:

- `ls: cannot access '/dev/disk/by-id/'` — the engine probes disk serials for a
  machine fingerprint; containers have no `/dev/disk`.
- `acestream.upnp|Failed to init port forward` — no UPnP/NAT-PMP in a bridged
  container; see [Ports](#ports).
- `TrafficStatsSender`, `UpdateNotificationsTask` and `PluginsContainer` errors
  — anonymous usage statistics, the notification feed and plugin updates are
  unreachable from inside the container.

If streams never start, the container most likely has no outbound network. Check
that the engine itself is up:

```console
curl -i 'http://127.0.0.1:6878/webui/api/service?method=get_version'
```

and that a container can reach the internet:

```console
docker run --rm alpine sh -c 'ping -c3 1.1.1.1 && wget -qO- https://ifconfig.me'
```

If that fails, look at DNS (a container `resolv.conf` pointing at the host's
`127.0.0.53` stub cannot work), a host firewall dropping forwarded traffic, and
rootless container networking.

## Contributing

First of all, thanks!

Ensure you have a container runtime with Compose support (e.g. Docker with the
Compose plugin, or Podman with `podman-compose`), as outlined
above. This image is simply a simplified wrapper around the
[AceStream][acestream] HTTP API in order to make it more user friendly to get
running. All options supported by the AceStream Engine are supported in this
project. Any contributions to support more configuration is greatly
appreciated!

Dockerfile steps are roughly guided by <https://wiki.acestream.media/Install_Ubuntu>.

<!-- textlint-disable terminology -->

For a list of AceStream versions, see here: <https://docs.acestream.net/products/#linux>

<!-- textlint-enable terminology -->

For convenience of easy image rebuilding, this repository contains a
[`compose.yaml`](./compose.yaml) file. You can then build & run the
image locally by running the following command:

```console
docker compose up --build
```

(or `podman-compose up --build` if you're using Podman)

The image will now be running with port 6878 published; see [Ports](#ports) for
details. See the [AceStream developer documentation][acestream] for command line
arguments and debugging.

[acestream]: https://docs.acestream.net/en/developers/
[engine-options]: https://docs.acestream.net/developers/engine-command-line-options/
[#5]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/5
[#13]: https://github.com/martinbjeldbak/acestream-http-proxy/issues/13
