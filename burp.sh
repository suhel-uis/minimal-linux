# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Run Burp Suite in background and download certificate
echo "Running Burp Suite in background to download certificate..."
nohup /opt/BurpSuiteCommunity/BurpSuiteCommunity --disable-extensions > /dev/null 2>&1 &

sleep 60 # Wait for Burp Suite to start (increased to 60 seconds)

# Check if Burp Suite process is running (using pgrep -f)
if pgrep -f "BurpSuiteCommunity"; then
  echo "Burp Suite process is running."
else
  echo "Error: Burp Suite process is NOT running after waiting."
  echo "Please check for any errors during Burp Suite startup. (No detailed logs for Community Edition)"
  #  In a real scenario, we might check for potential error logs if Burp Suite CE had them.
  pkill -f "BurpSuiteCommunity" # Attempt to kill just in case a zombie process exists.
  return 1 # Exit the script with an error code
fi

# Check if port 8080 is listening
if netstat -tulnp | grep ':8080'; then
  echo "Port 8080 is listening (something is using it)."
else
  echo "Error: Port 8080 is NOT listening after Burp Suite startup."
  echo "This is unexpected. Burp Suite should be listening on port 8080 by default."
  pkill -f "BurpSuiteCommunity" # Attempt to kill if port is not listening
  return 1 # Exit the script with an error code
fi


echo "Downloading Burp Suite CA certificate..."
PROXY_HOST="127.0.0.1:8080" # Proxy settings to use for curl, matching your script's proxy settings
CERT_FILE="<span class="math-inline">\{BURP\_CERT\_DIR\}/cacert\.der"
curl \-\-proxy "</span>{PROXY_HOST}" http://burp/cert -o "<span class="math-inline">\{CERT\_FILE\}"
CERT\_DOWNLOAD\_STATUS\=</span>? # Capture the exit status of the curl command

if [ $CERT_DOWNLOAD_STATUS -eq 0 ]; then
  echo "Burp Suite CA certificate downloaded to: ${CERT_FILE}"
else
  echo "Error: Failed to download Burp Suite CA certificate (again)."
  echo "Curl error code: ${CERT_DOWNLOAD_STATUS}"
  echo "Please check Burp Suite configuration and network settings."
fi

# Kill Burp Suite process (again, to ensure cleanup)
pkill -f "BurpSuiteCommunity"
