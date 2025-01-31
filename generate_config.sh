#!/bin/bash

# A helper function that checks that an environment variable is set,
# strips any leading/trailing quotes, and exports the cleaned value back.
check_env_var() {
    local var_name="$1"
    local var_value

    # Read the current value of the variable
    var_value="$(eval echo "\$$var_name")"

    # If the variable is empty, exit with an error
    if [ -z "$var_value" ]; then
        echo "Error: Environment variable '$var_name' is not set. Please supply it via the Docker Compose file or .env file."
        exit 1
    fi

    # Strip any leading/trailing single or double quotes
    # For example:
    #   "value"   -> value
    #   'value'   -> value
    #   ""value"" -> value
    var_value="$(echo "$var_value" | sed -E 's/^["'\''"]+|["'\''"]+$//g')"

    # Export the stripped value so it is available outside this function
    # (optional - if you just want a local variable you can skip the export)
    export "$var_name"="$var_value"
}

# Ensure required variables are supplied (and stripped)
check_env_var "CLIENT_IP"
check_env_var "SERVER_PUBLIC_KEY"
check_env_var "SERVER_ENDPOINT"
check_env_var "ALLOWED_IPS"
check_env_var "DNS_SERVER"

# Check if WireGuard is installed
if ! command -v wg &> /dev/null; then
    echo "WireGuard is not installed. Please install it and try again."
    exit 1
fi

# Generate keys
PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)
PRESHARED_KEY=$(wg genpsk)

# Create the WireGuard configuration file
CONFIG_FILE="/config-output/${CLIENT_IP}_wg0.conf"

cat <<EOF > "$CONFIG_FILE"
[Interface]
PrivateKey = $PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = $DNS_SERVER

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
PresharedKey = $PRESHARED_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 25
EOF

# Output the client configuration file
echo "WireGuard client configuration file created: $CONFIG_FILE"
echo "You can now send this file to your remote developer."
echo

# Display the client configuration
cat "$CONFIG_FILE"
echo

# Display the server configuration snippet for this client
echo "Add the following configuration to your WireGuard server configuration:"
echo
echo "[Peer]"
echo "PublicKey = $PUBLIC_KEY"
echo "PresharedKey = $PRESHARED_KEY"
echo "AllowedIPs = $CLIENT_IP/32"
