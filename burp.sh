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

# --- Change working directory to Burp Suite install location ---
echo "Changing working directory to Burp Suite installation directory..."
BURP_INSTALL_DIR="/opt/BurpSuiteCommunity" # Define Burp Suite install directory
mkdir -p "${BURP_INSTALL_DIR}" # Ensure directory exists (though it should already)
cd "${BURP_INSTALL_DIR}" || { # Change directory, exit if fails
  echo "Error: Could not change directory to ${BURP_INSTALL_DIR}"
  return 1
}
echo "Working directory changed to: $(pwd)" # Print current working directory


# Attempt to run Burp Suite in foreground with xvfb and capture output (using relative path now)
echo "Attempting to run Burp Suite in foreground WITH xvfb from current directory..."
BURP_START_COMMAND="xvfb-run ./BurpSuiteCommunity" # Use relative path './BurpSuiteCommunity'

# Try running Burp Suite in foreground with xvfb and capture any output (including errors)
BURP_OUTPUT=$(timeout 60s "${BURP_START_COMMAND}" 2>&1) # Capture both stdout and stderr, timeout after 60s
BURP_START_STATUS=$? # Get the exit status of the Burp Suite command

echo "Burp Suite startup command: ${BURP_START_COMMAND}"
echo "Burp Suite output (stdout and stderr):"
echo "${BURP_OUTPUT}"
echo "Burp Suite startup exit status: ${BURP_START_STATUS}"

if [ $BURP_START_STATUS -eq 0 ]; then
  echo "Burp Suite seems to have started successfully (exit code 0, with xvfb - foreground, from install dir)."
else
  echo "Error: Burp Suite startup FAILED (non-zero exit code: ${BURP_START_STATUS}, with xvfb - foreground, from install dir)."
  echo "Please examine the Burp Suite output above for error messages."
  return 1 # Exit the script with an error code
fi

sleep 15 # Wait a bit more after foreground start


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
