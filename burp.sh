# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Run Burp Suite in background and download certificate
echo "Running Burp Suite in background to download certificate..."
nohup /opt/BurpSuiteCommunity/BurpSuiteCommunity --disable-extensions > /dev/null 2>&1 &

sleep 30 # Wait for Burp Suite to start (increased from 15 to 30 seconds)

echo "Downloading Burp Suite CA certificate..."
PROXY_HOST="127.0.0.1:8080" # Proxy settings to use for curl, matching your script's proxy settings
CERT_FILE="${BURP_CERT_DIR}/cacert.der"
curl --proxy "${PROXY_HOST}" http://burp/cert -o "${CERT_FILE}"
CERT_DOWNLOAD_STATUS=$? # Capture the exit status of the curl command

if [ $CERT_DOWNLOAD_STATUS -eq 0 ]; then
  echo "Burp Suite CA certificate downloaded to: ${CERT_FILE}"
else
  echo "Error: Failed to download Burp Suite CA certificate."
  echo "Curl error code: ${CERT_DOWNLOAD_STATUS}"
  echo "Please check if Burp Suite started correctly and is listening on port 8080."
fi


# Kill Burp Suite process
pkill -f "BurpSuiteCommunity" # Corrected process name to kill
