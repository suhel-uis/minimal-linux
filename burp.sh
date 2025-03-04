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


# --- Change working directory to Burp Suite install location ---
echo "Changing working directory to Burp Suite installation directory..."
BURP_INSTALL_DIR="/opt/BurpSuiteCommunity" # Define Burp Suite install directory
mkdir -p "${BURP_INSTALL_DIR}" # Ensure directory exists (though it should already)
cd "${BURP_INSTALL_DIR}" || { # Change directory, exit if fails
  echo "Error: Could not change directory to ${BURP_INSTALL_DIR}"
  return 1
}
echo "Working directory changed to: $(pwd)" # Print current working directory


# --- 1. Verify xvfb-run command (direct execution) ---
echo "Verifying xvfb-run command (direct execution)..."
XVFB_RUN_CHECK_OUTPUT=$(xvfb-run echo "xvfb-run test" 2>&1) # Try a simple command with xvfb-run
XVFB_RUN_CHECK_STATUS=$?
echo "xvfb-run echo output:"
echo "${XVFB_RUN_CHECK_OUTPUT}"
echo "xvfb-run echo exit status: ${XVFB_RUN_CHECK_STATUS}"

if [ $XVFB_RUN_CHECK_STATUS -ne 0 ]; then
  echo "Error: xvfb-run command is NOT working (direct execution)."
  echo "Please check your xvfb installation and PATH."
  return 1
else
  echo "xvfb-run command seems to be working (direct execution)."
fi


# --- 2. List contents of Burp Suite installation directory ---
echo "Listing contents of Burp Suite installation directory: /opt/BurpSuiteCommunity"
BURP_DIR_CONTENTS=$(ls -l /opt/BurpSuiteCommunity)
echo "${BURP_DIR_CONTENTS}"


# Attempt to run Burp Suite in foreground with xvfb and capture output (using just the name now)
echo "Attempting to run Burp Suite in foreground WITH xvfb from current directory..."
BURP_START_COMMAND="xvfb-run BurpSuiteCommunity" # Use just 'BurpSuiteCommunity' - NO './'

# Try running Burp Suite in foreground with xvfb and capture any output (including errors)
BURP_OUTPUT=$(timeout 60s "${BURP_START_COMMAND}" 2>&1) # Capture both stdout and stderr, timeout after 60s
BURP_START_STATUS=$? # Get the exit status of the Burp Suite command

echo "Burp Suite startup command: ${BURP_START_COMMAND}"
echo "Burp Suite output (stdout and stderr):"
echo "${BURP_OUTPUT}"
echo "Burp Suite startup exit status: ${BURP_START_STATUS}"

if [ $BURP_START_STATUS -eq 0 ]; then
  echo "Burp Suite seems to have started successfully (exit code 0, with xvfb - foreground, from install dir, NO './')."
else
  echo "Error: Burp Suite startup FAILED (non-zero exit code: ${BURP_START_STATUS}, with xvfb - foreground, from install dir, NO './')."
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
