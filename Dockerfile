# Start with a lightweight base image
FROM debian:latest

# Install WireGuard and dependencies
RUN apt-get update && \
    apt-get install -y wireguard-tools iproute2 && \
    rm -rf /var/lib/apt/lists/*

# # Set environment variable placeholder for client IP
# ENV CLIENT_IP="10.0.0.2"

# Set the entrypoint to run your WireGuard configuration script, passing CLIENT_IP as input
ENTRYPOINT ["/bin/bash", "-c", "chmod +x /usr/local/bin/generate_config.sh && /usr/local/bin/generate_config.sh $CLIENT_IP"]
