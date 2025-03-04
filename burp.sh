# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Run Burp Suite in foreground and check for errors
echo "Attempting to run Burp Suite in foreground to capture output..."
BURP_START_COMMAND="/opt/BurpSuiteCommunity/BurpSuiteCommunity"

# Try running Burp Suite and capture any output (including errors)
BURP_OUTPUT=$(timeout 60s "${BURP_START_COMMAND}" 2>&1) # Capture both stdout and stderr, timeout after 60s
BURP_START_STATUS=$? # Get the exit status of the Burp Suite command

echo "Burp Suite startup command: ${BURP_START_COMMAND}"
echo "Burp Suite output (stdout and stderr):"
echo "${BURP_OUTPUT}"
echo "Burp Suite startup exit status: ${BURP_START_STATUS}"

if [ $BURP_START_STATUS -eq 0 ]; then
  echo "Burp Suite seems to have started successfully (exit code 0)."
else
  echo "Error: Burp Suite startup FAILED (non-zero exit code: ${BURP_START_STATUS})."
  echo "Please examine the Burp Suite output above for error messages."
  return 1 # Exit the script with an error code
fi


sleep 15 # Wait a bit more after foreground start, just in case.

# Check if port 8080 is listening (after foreground attempt)
if netstat -tulnp | grep ':8080'; then
  echo "Port 8080 is listening (something is using it)."
else
  echo "Error: Port 8080 is NOT listening even after foreground Burp Suite attempt."
  echo "This is unexpected. Burp Suite should be listening on port 8080 by default."
  pkill -f "BurpSuiteCommunity" # Attempt to kill if port is not listening (just in case)
  return 1 # Exit the script with an error code
fi


echo "Downloading Burp Suite CA certificate..."
PROXY_HOST="127.0.0.1:8080"
CERT_FILE="${BURP_CERT_DIR}/cacert.der"
curl --proxy "${PROXY_HOST}" http://burp/cert -o "${CERT_FILE}"
CERT_DOWNLOAD_STATUS=$?

if [ $CERT_DOWNLOAD_STATUS -eq 0 ]; then
  echo "Burp Suite CA certificate downloaded to: ${CERT_FILE}"
else
  echo "Error: Failed to download Burp Suite CA certificate (again)."
  echo "Curl error code: ${CERT_DOWNLOAD_STATUS}"
  echo "Please check Burp Suite configuration and network settings."
fi

# Kill Burp Suite process (again, for cleanup)
pkill -f "BurpSuiteCommunity"
