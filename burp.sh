# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Run Burp Suite in background and download certificate
echo "Running Burp Suite in background to download certificate..."
# Corrected path here:
nohup /opt/BurpSuiteCommunity/BurpSuiteCommunity --disable-extensions > /dev/null 2>&1 &

sleep 15 # Wait for Burp Suite to start (adjust if needed)

echo "Downloading Burp Suite CA certificate..."
PROXY_HOST="127.0.0.1:8080" # Proxy settings to use for curl, matching your script's proxy settings
CERT_FILE="${BURP_CERT_DIR}/cacert.der"
curl --proxy "${PROXY_HOST}" http://burp/cert -o "${CERT_FILE}"

echo "Burp Suite CA certificate downloaded to: ${CERT_FILE}"

# Kill Burp Suite process
pkill -f "BurpSuiteCommunity" # Corrected process name to kill
