# AceStream HTTP Proxy
![Build and push Docker image to DockerHub](https://github.com/martinbjeldbak/acestream-http-proxy/workflows/Build%20and%20push%20Docker%20image%20to%20DockerHub/badge.svg)

This docker image installs and runs the AceStream Engine in Ubuntu and exposes the AceStream [HTTP API](https://wiki.acestream.media/index.php?title=Engine_HTTP_API#API_methods).

This is especially useful for those of us on MacBooks who want to tune in to AceStream channels, but aren't able to run AceStream natively.

## Usage

```sh
$ docker run -t -p 6878:6878 martinbjeldbak/acestream-http-proxy
```

You are then able to access AceSream content by pointing your favorite media player (VLC, IINA, etc.) to the below network URL

```
http://127.0.0.1:6878/ace/getstream?id=dd1e67078381739d14beca697356ab76d49d1a2d
```

Where `dd1e67078381739d14beca697356ab76d49d1a2d` is the ID of the desired AceStream channel.
