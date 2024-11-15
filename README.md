# WireGuard Configuration Generator

## Overview

This project provides a Docker-based solution for generating WireGuard client configuration files. It automates the process of creating keys, generating configuration files, and displaying server-side configuration snippets for adding new clients.

The setup includes:
- A `Dockerfile` to install WireGuard and handle dependencies.
- A `docker-compose.yml` file to manage environment variables and volume mounting.
- A `generate_config.sh` script that generates client configuration files and server snippets.

---

## Prerequisites

- Docker installed on your machine.
- Docker Compose installed.
- A WireGuard server with the public key and endpoint details.

---

## Setup

1. **Clone the Repository**  
    Clone this repository or copy the files (`Dockerfile`, `docker-compose.yml`, `generate_config.sh`) into a directory.
 
    ```bash
    git clone <repository_url>
    cd <repository_directory>

2. **Create Required Directories and Files**
    Ensure the following structure exists in your project folder:
    ```bash
    .
    ├── Dockerfile
    ├── docker-compose.yml
    ├── generate_config.sh
    ├── output/      # Directory for storing generated configuration files
    └── .env         # File for storing sensitive environment variables (optional)
    ```

3. **Set Permissions**
    Make the generate_config.sh script executable:
    ```bash
    chmod +x generate_config.sh
    ```

4. **Edit the `.env File` (Optional)**
    Add environment variables to the .env file for server configuration. Example:
    ```bash
    SERVER_PUBLIC_KEY=<server_public_key>
    SERVER_ENDPOINT=<server_endpoint>
    ALLOWED_IPS=0.0.0.0/0
    DNS_SERVER=10.205.0.1,1.1.1.1
    ```

## Usage

1. **Build the Docker Image**
    Build the Docker image using the docker-compose.yml file:
    ```bash
    docker-compose build
    ```

2. **Run the Container**
    Start the container with the required configuration:
    ```bash
    docker-compose up
    ```
    The CLIENT_IP variable can be modified directly in the docker-compose.yml or supplied dynamically:
    ```bash
    CLIENT_IP=10.205.0.50 docker-compose up
    ```

3. **Access the Generated Configuration**

    The client configuration files are saved in the output/ directory on your host machine.
    Example file path: `output/10.205.0.23_wg0.conf`

4. **Add Server-Side Configuration**
    The script outputs a snippet for the server configuration. Add this to your WireGuard server's configuration file (`/etc/wireguard/wg0.conf`), and reload the server.

## Environment Variables

The following environment variables are required for the script to execute successfully:

| Variable           | Description                                             | Example                  |
|---------------------|---------------------------------------------------------|--------------------------|
| `CLIENT_IP`        | IP address assigned to the client (required).            | `10.205.0.23`           |
| `SERVER_PUBLIC_KEY`| Public key of the WireGuard server (required).           | `abc123...`             |
| `SERVER_ENDPOINT`  | Endpoint of the WireGuard server (required).             | `vpn.example.com:51820` |
| `ALLOWED_IPS`      | Subnets accessible via the VPN.                          | `0.0.0.0/0`             |
| `DNS_SERVER`       | DNS server(s) used by the client (comma-separated).      | `10.205.0.1,1.1.1.1`    |

---

## Project Structure

- **Dockerfile**  
  Installs WireGuard tools and sets up the container environment.

- **docker-compose.yml**  
  Configures the service, handles environment variables, and mounts volumes for the script and output.

- **generate_config.sh**  
  Bash script that:
  - Checks for WireGuard installation.
  - Validates required environment variables.
  - Generates client keys and configuration.
  - Outputs server-side configuration snippets.

- **output/**  
  Directory to store generated WireGuard client configuration files.

- **.env**  
  (Optional) File to securely store environment variables.

---

## Troubleshooting

- **Missing Environment Variables**  
  The script validates required variables and exits with a clear error message if any are missing. Example:

  ```plaintext
  Error: Environment variable 'SERVER_PUBLIC_KEY' is not set. Please supply it via the Docker Compose file or .env file.
  ```
- **Permission Denied for generate_config.sh**
  Ensure the script has the correct permissions:

  ```bash
  chmod +x generate_config.sh
  ```
- **Configuration File Not Generated**
  Check for errors in the container logs:

  ```bash
  docker logs wireguard_config_generator
  ```

---

## Example Output

After running the container, the script generates:

1. **Client Configuration File**

    Saved in `output/<CLIENT_IP>_wg0.conf`:
    ```ini
    [Interface]
    PrivateKey = <client_private_key>
    Address = 10.205.0.23/24
    DNS = 10.205.0.1,1.1.1.1
    
    [Peer]
    PublicKey = <server_public_key>
    PresharedKey = <preshared_key>
    Endpoint = vpn.example.com:51820
    AllowedIPs = 0.0.0.0/0
    PersistentKeepalive = 25
    ```
2. **Server Configuration Snippet**

    Append to `/etc/wireguard/wg0.conf`:
    ```ini
    [Peer]
    PublicKey = <client_public_key>
    PresharedKey = <preshared_key>
    AllowedIPs = 10.205.0.23/32
    ```


  