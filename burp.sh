# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Install xvfb if not already installed (just to be sure)
echo "Ensuring xvfb is installed..."
sudo apt install -yqq xvfb
echo "xvfb installation complete."

# Run Burp Suite in background with xvfb and download certificate
echo "Running Burp Suite in background with xvfb to download certificate..."
BURP_START_COMMAND="xvfb-run /opt/BurpSuiteCommunity/BurpSuiteCommunity --disable-extensions"

nohup ${BURP_START_COMMAND} > /dev/null 2>&1 &

sleep 60 # Wait for Burp Suite to start (increased to 60 seconds - again, be patient)

# Check if Burp Suite process is running (using pgrep -f)
if pgrep -f "BurpSuiteCommunity"; then
  echo "Burp Suite process is running (via xvfb)."
else
  echo "Error: Burp Suite process is NOT running after waiting (even with xvfb)."
  echo "Please check for any errors during Burp Suite startup. (No detailed logs for Community Edition)"
  pkill -f "BurpSuiteCommunity" # Attempt to kill any zombie processes
  return 1 # Exit with error
fi

# Check if port 8080 is listening
if netstat -tulnp | grep ':8080'; then
  echo "Port 8080 is listening (something is using it)."
else
  echo "Error: Port 8080 is NOT listening after Burp Suite startup (with xvfb)."
  echo "This is unexpected. Burp Suite should be listening on port 8080 by default."
  pkill -f "BurpSuiteCommunity" # Attempt to kill if port is not listening
  return 1 # Exit with error
fi


echo "Downloading Burp Suite CA certificate..."
PROXY_HOST="127.0.0.1:8080"
CERT_FILE="${BURP_CERT_DIR}/cacert.der"
curl --proxy "${PROXY_HOST}" http://burp/cert -o "${CERT_FILE}"
CERT_DOWNLOAD_STATUS=$?

if [ $CERT_DOWNLOAD_STATUS -eq 0 ]; then
  echo "Burp Suite CA certificate downloaded to: ${CERT_FILE}"
else
  echo "Error: Failed to download Burp Suite CA certificate (again, even with xvfb)."
  echo "Curl error code: ${CERT_DOWNLOAD_STATUS}"
  echo "Please check Burp Suite configuration, network settings, and xvfb setup."
fi

# Kill Burp Suite process (again, for cleanup)
pkill -f "BurpSuiteCommunity"
