# Install directory for Burp certificate
BURP_CERT_DIR="$HOME/burp_certificate"
mkdir -p "${BURP_CERT_DIR}"

# Install xvfb if not already installed (just to be sure)
echo "Ensuring xvfb is installed..."
sudo apt install -yqq xvfb
echo "xvfb installation complete."

# Ensure net-tools (for netstat) is installed
echo "Ensuring net-tools is installed (for netstat)..."
sudo apt install -yqq net-tools
echo "net-tools installation complete."


# Check for processes using port 8080 BEFORE starting Burp Suite
echo "Checking for processes already using port 8080 BEFORE starting Burp Suite..."
PORT_8080_PROCESSES=$(sudo lsof -i :8080) # Use lsof to list processes using port 8080
if [ -n "${PORT_8080_PROCESSES}" ]; then # Check if the variable is NOT empty (meaning something is using the port)
  echo "Warning: Port 8080 is already in use BEFORE starting Burp Suite!"
  echo "Processes using port 8080:"
  echo "${PORT_8080_PROCESSES}"
  echo "Please investigate and resolve the port conflict before proceeding."
  return 1 # Exit the script as we cannot start Burp Suite on port 8080 if it's in use.
else
  echo "Port 8080 is free before starting Burp Suite."
fi

# Attempt to run Burp Suite in foreground with xvfb and capture output
echo "Attempting to run Burp Suite in foreground WITH xvfb to capture output..."
BURP_START_COMMAND="xvfb-run /opt/BurpSuiteCommunity/BurpSuiteCommunity" # Removed --disable-extensions for this test

# Try running Burp Suite in foreground with xvfb and capture any output (including errors)
BURP_OUTPUT=$(timeout 60s "${BURP_START_COMMAND}" 2>&1) # Capture both stdout and stderr, timeout after 60s
BURP_START_STATUS=$? # Get the exit status of the Burp Suite command

echo "Burp Suite startup command: ${BURP_START_COMMAND}"
echo "Burp Suite output (stdout and stderr):"
echo "${BURP_OUTPUT}"
echo "Burp Suite startup exit status: ${BURP_START_STATUS}"

if [ $BURP_START_STATUS -eq 0 ]; then
  echo "Burp Suite seems to have started successfully (exit code 0, with xvfb - foreground)."
else
  echo "Error: Burp Suite startup FAILED (non-zero exit code: ${BURP_START_STATUS}, with xvfb - foreground)."
  echo "Please examine the Burp Suite output above for error messages."
  return 1 # Exit the script with an error code
fi

# Check if Burp Suite process is running (using pgrep -f)
if pgrep -f "BurpSuiteCommunity"; then
  echo "Burp Suite process is running (via xvfb)."
else
  echo "Error: Burp Suite process is NOT running after waiting (even with xvfb)."
  echo "Please check for any errors during Burp Suite startup."
  pkill -f "BurpSuiteCommunity" # Attempt to kill any zombie processes
  return 1 # Exit with error
fi

# Check if port 8080 is listening (try netstat, fallback to ss)
if command -v netstat &> /dev/null; then
  if netstat -tulnp | grep ':8080'; then
    echo "Port 8080 is listening (using netstat)."
  else
    echo "Error: Port 8080 is NOT listening after Burp Suite startup (with xvfb, netstat)."
    echo "This is unexpected. Burp Suite should be listening on port 8080 by default."
    pkill -f "BurpSuiteCommunity"
    return 1
  fi
elif command -v ss &> /dev/null; then # Fallback to ss if netstat is not found
  if ss -tulnp | grep ':8080'; then
    echo "Port 8080 is listening (using ss)."
  else
    echo "Error: Port 8080 is NOT listening after Burp Suite startup (with xvfb, ss)."
    echo "This is unexpected. Burp Suite should be listening on port 8080 by default."
    pkill -f "BurpSuiteCommunity"
    return 1
  fi
else
  echo "Error: Neither netstat nor ss commands found. Cannot check port 8080."
  echo "Please install net-tools or iproute2 package."
  pkill -f "BurpSuiteCommunity"
  return 1
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
