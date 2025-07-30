# Stage 1: Build Caddy with L4 and Tailscale modules
FROM caddy:2.8-builder AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-l4 \
    --with github.com/tailscale/caddy-tailscale

# Stage 2: Create final image
FROM caddy:2.8

# Copy the custom-built Caddy binary from the builder stage
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Set the entrypoint to Caddy
ENTRYPOINT ["/usr/bin/caddy"]
# Default to JSON config, but allow override to Caddyfile via volume mount
CMD ["run", "--config", "/etc/caddy/config.json", "--adapter", "json"]