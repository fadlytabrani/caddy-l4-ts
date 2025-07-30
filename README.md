# Caddy Docker Image with L4 and Tailscale Modules

**A custom Caddy web server Docker image with support for Layer 4 proxying and Tailscale networking.**

This project provides a Dockerfile to build a Caddy web server image enhanced with the L4 (Layer 4 proxy) and Tailscale modules. It supports both JSON and Caddyfile configuration formats, offering flexibility for various use cases. The L4 module enables advanced TCP/UDP proxying, while the Tailscale module integrates secure, zero-config VPN connectivity for peer-to-peer networking. Ideal for developers and DevOps engineers looking to deploy a lightweight, secure, and highly configurable web server or reverse proxy in a Dockerized environment.

## Features

- **Custom Caddy Build**: Includes the L4 module for Layer 4 (TCP/UDP) proxying and the Tailscale module for secure networking.
- **Flexible Configuration**: Supports both JSON and Caddyfile formats for easy configuration.
- **Dockerized**: Lightweight and portable, built with a multi-stage Docker build for efficiency.
- **Persistent Data**: Uses volumes to persist certificates and configuration data.
- **Flexible Port Mapping**: No ports are exposed by default; users must specify ports at runtime based on their needs.

## Getting Started

### Prerequisites

- Docker installed on your system.
- Basic knowledge of Caddy configuration (JSON or Caddyfile).

### Building the Image

1. Clone the repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```
2. Build the Docker image:
   ```
   docker build -t custom-caddy:l4-tailscale .
   ```

### Running the Container

Run with a JSON config, specifying ports as needed (e.g., 80 for TCP, 53/udp for UDP, 10000/udp for Tailscale):

```
docker run -d \
  --name custom-caddy \
  -p 80:80 \
  -p 53:53/udp \
  -p 10000:10000/udp \
  -v $(pwd)/config.json:/etc/caddy/config.json \
  -v caddy_data:/data \
  custom-caddy:l4-tailscale
```

Run with a Caddyfile:

```
docker run -d \
  --name custom-caddy \
  -p 80:80 \
  -p 53:53/udp \
  -p 10000:10000/udp \
  -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
  -v caddy_data:/data \
  custom-caddy:l4-tailscale run --config /etc/caddy/Caddyfile --adapter caddyfile
```

- Mount your configuration file to `/etc/caddy/config.json` for JSON or `/etc/caddy/Caddyfile` for Caddyfile.
- Use `--adapter caddyfile` when using a Caddyfile.
- Use a volume for `/data` to persist certificates and other data.
- Specify ports with `-p` based on your configuration (e.g., 80 for TCP proxy, 53/udp for UDP proxy, 10000/udp for Tailscale).

### Configuring Tailscale

#### JSON Config

Configure in `config.json` under "apps":

```
"apps": {
  "tailscale": {
    "auth_key": "tskey-yourkeyhere"
  }
}
```

Listen on Tailscale interfaces, e.g.:

```
"listen": ["tailscale/myhost:80"]
```

#### Caddyfile Config

Configure in `Caddyfile`:

```
{
  tailscale {
    authkey tskey-yourkeyhere
  }
}
```

Refer to the [Tailscale Caddy module documentation](https://github.com/tailscale/caddy-tailscale) for more details.

### Configuring L4 with Tailscale for TCP/UDP Reverse Proxy

The examples below demonstrate setting up TCP and UDP reverse proxies to backend nodes in a Tailscale network. The Tailscale module enables resolution and connection to Tailscale hostnames (e.g., "backend-node").

#### JSON Config

Configure Layer 4 proxying in `config.json` for TCP (e.g., port 80 to backend:80) and UDP (e.g., port 53 to backend:53):

```
"layer4": {
  "servers": {
    "tcp-proxy": {
      "listen": [":80"],
      "routes": [
        {
          "handle": [
            {
              "handler": "proxy",
              "upstreams": [
                {"dial": ["backend-node:80"]}
              ]
            }
          ]
        }
      ]
    },
    "udp-proxy": {
      "listen": ["udp/:53"],
      "routes": [
        {
          "handle": [
            {
              "handler": "proxy",
              "upstreams": [
                {"dial": ["backend-node:53"]}
              ]
            }
          ]
        }
      ]
    }
  }
}
```

#### Caddyfile Config

Configure in `Caddyfile`:

```
{
  layer4 {
    :80 {
      route {
        proxy {
          upstream backend-node:80
        }
      }
    }
    udp/:53 {
      route {
        proxy {
          upstream backend-node:53
        }
      }
    }
  }
}
```

See the [Caddy L4 documentation](https://github.com/mholt/caddy-l4) for more usage details.

## Volumes

- `/data`: For persisting Caddy's data (certs, etc.).
- `/config`: Optional for additional configs.

## Contributing

Feel free to open issues or pull requests for improvements.

## License

MIT License. See LICENSE file.
