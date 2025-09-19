#!/bin/bash

# Set variables:
PRE_CONFIGURED_PIN="123456"
TIMEZONE="Europe/Lisbon"

# set timezone if a variable is defined
if [ -n "${TIMEZONE}" ]; then
  sudo timedatectl set-timezone ${TIMEZONE}
fi

# Function to extract code from Chrome Remote Desktop command
extract_chrome_code() {
    local full_command="$1"
    # Extract the code between quotes after --code=
    echo "$full_command" | grep -oP '(?<=--code=")[^"]*'
}

# Read Chrome Remote Desktop code from command line argument or prompt user
if [ -n "$1" ]; then
    # If argument provided, check if it's a full command or just the code
    if [[ "$1" == *"--code="* ]]; then
        # It's a full command, extract the code
        CHROME_REMOTE_DESKTOP_CODE=$(extract_chrome_code "$1")
        echo "Code extracted from command: ${CHROME_REMOTE_DESKTOP_CODE}"
    else
        # It's just the code
        CHROME_REMOTE_DESKTOP_CODE="$1"
        echo "Using provided code: ${CHROME_REMOTE_DESKTOP_CODE}"
    fi
    shift
else
    # Prompt user for the Chrome Remote Desktop command
    echo "Please paste the complete Chrome Remote Desktop command:"
    echo "Example: DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=\"A/AAX4XfWjLm9kR2pQvN8uY5tE3rS6wZ1oI7bV4cD0fG8hJ2kL9mN6pQ3rS5tU8vW1xY4zA7bC\" --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" --name=\$(hostname)"
    echo ""
    read -p "Enter command: " FULL_CHROME_COMMAND
    
    if [ -n "$FULL_CHROME_COMMAND" ]; then
        CHROME_REMOTE_DESKTOP_CODE=$(extract_chrome_code "$FULL_CHROME_COMMAND")
        if [ -n "$CHROME_REMOTE_DESKTOP_CODE" ]; then
            echo "Code successfully extracted: ${CHROME_REMOTE_DESKTOP_CODE}"
        else
            echo "Error: Could not extract code from the provided command."
            echo "Please make sure the command contains --code=\"...\" format."
            exit 1
        fi
    else
        echo "No command provided. Chrome Remote Desktop will be skipped."
        CHROME_REMOTE_DESKTOP_CODE=""
    fi
fi

# Start timer now
start_time=$(date +%s)


# Get the user name and remote desktop default pin
CHROME_REMOTE_USER_NAME="${SUDO_USER}"

APT_INSTALL_CMD="apt"

# Default IP Address and Port
IP_ADDRESS='127.0.0.1'
PORT=8080


# Update the packages lists and install apt-fast
echo "Installing apt-fast..."
sudo add-apt-repository ppa:apt-fast/stable -y
sudo ${APT_INSTALL_CMD} update -yqq
echo debconf apt-fast/maxdownloads string 16 | sudo debconf-set-selections
echo debconf apt-fast/dlflag boolean true | sudo debconf-set-selections
echo debconf apt-fast/aptmanager string apt-get | sudo debconf-set-selections
sudo ${APT_INSTALL_CMD} install apt-fast -yqq

# Check again if apt-fast is installed after attempting installation
if command -v apt-fast &> /dev/null; then
  APT_INSTALL_CMD="apt-fast"
  echo "apt-fast installed successfully. Using apt-fast for package installations."
 else
  echo "apt-fast installation failed. Using apt for package installations."
fi

# Download all files upfront in parallel - Chrome Remote Desktop, Google Chrome Stable, VS Code, Burp Suite Community Edition.
echo "Downloading installation files in parallel..."
wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O google-chrome-stable_current_amd64.deb &
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" -O chrome-remote-desktop_current_amd64.deb &
wget -q "https://portswigger.net/burp/releases/startdownload?product=community&type=Linux" -O burpsuite &
wait
echo "Downloads completed."

# Install Google Chrome Stable
echo "Installing Google Chrome Stable..."
sudo ${APT_INSTALL_CMD} install -yqq "./google-chrome-stable_current_amd64.deb"
rm "./google-chrome-stable_current_amd64.deb"

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop..."
sudo ${APT_INSTALL_CMD} install -yqq "./chrome-remote-desktop_current_amd64.deb"
rm "./chrome-remote-desktop_current_amd64.deb"

# Start Chrome Remote Desktop host if code is provided
DISPLAY_INSTALL_STATUS=0
if [ -n "${CHROME_REMOTE_USER_NAME}" -a -n "${CHROME_REMOTE_DESKTOP_CODE}" ]; then
  echo "Starting Chrome Remote Desktop..."
  DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="${CHROME_REMOTE_DESKTOP_CODE}" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname) --user-name="${CHROME_REMOTE_USER_NAME}" --pin="${PRE_CONFIGURED_PIN}"
  DISPLAY_INSTALL_STATUS=$?
  wait
  echo "Finish Starting Chrome Remote Desktop"
 else
  echo "Chrome Remote Desktop start skipped because code was not provided."
fi

# Install packages Gui
echo "Installing minimal desktop environment and applications..."
sudo ${APT_INSTALL_CMD} install -yqq xfce4 --no-install-recommends network-manager file-roller dbus-x11 fonts-wqy-microhei fonts-wqy-zenhei fonts-noto-cjk
wait
echo "GUI installation completed."

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition ..."
sudo chmod +x burpsuite
sudo ./burpsuite -q
rm burpsuite

# Install VsCode
echo "Installing VsCode..."
sudo snap install --classic code
wait
echo "VsCode installation completed."
echo "Installing VSCode extensions:"
sudo -u ${CHROME_REMOTE_USER_NAME} code --install-extension esbenp.prettier-vscode
sudo -u ${CHROME_REMOTE_USER_NAME} code --install-extension ipatalas.vscode-postfix-ts
sudo -u ${CHROME_REMOTE_USER_NAME} code --install-extension aaravb.chrome-extension-developer-tools
sudo -u ${CHROME_REMOTE_USER_NAME} code --install-extension solomonkinard.chrome-extension-api
echo "done."

## Reload desktop environment for the current user
#if [ $DISPLAY_INSTALL_STATUS -eq 0 ]; then
#  echo "Reload desktop environment for the current user ${CHROME_REMOTE_USER_NAME}..."
#  sudo systemctl restart chrome-remote-desktop@${CHROME_REMOTE_USER_NAME}.service

#  echo "Setting manual proxy settings (${IP_ADDRESS}:${PORT}) for Chrome Remote Desktop session..."
  #
#  # Create proxy configuration for XFCE4
#  USER_HOME="/home/${CHROME_REMOTE_USER_NAME}"
  #
#  # Set environment variables for proxy (system-wide)
#  echo "export http_proxy=http://${IP_ADDRESS}:${PORT}" | sudo tee -a ${USER_HOME}/.bashrc
#  echo "export https_proxy=http://${IP_ADDRESS}:${PORT}" | sudo tee -a ${USER_HOME}/.bashrc
#  echo "export HTTP_PROXY=http://${IP_ADDRESS}:${PORT}" | sudo tee -a ${USER_HOME}/.bashrc
#  echo "export HTTPS_PROXY=http://${IP_ADDRESS}:${PORT}" | sudo tee -a ${USER_HOME}/.bashrc
  #
#  # Create proxy configuration for applications
#  sudo -u ${CHROME_REMOTE_USER_NAME} mkdir -p ${USER_HOME}/.config/environment.d
#  echo "http_proxy=http://${IP_ADDRESS}:${PORT}" | sudo -u ${CHROME_REMOTE_USER_NAME} tee ${USER_HOME}/.config/environment.d/proxy.conf
#  echo "https_proxy=http://${IP_ADDRESS}:${PORT}" | sudo -u ${CHROME_REMOTE_USER_NAME} tee -a ${USER_HOME}/.config/environment.d/proxy.conf
#  echo "HTTP_PROXY=http://${IP_ADDRESS}:${PORT}" | sudo -u ${CHROME_REMOTE_USER_NAME} tee -a ${USER_HOME}/.config/environment.d/proxy.conf
#  echo "HTTPS_PROXY=http://${IP_ADDRESS}:${PORT}" | sudo -u ${CHROME_REMOTE_USER_NAME} tee -a ${USER_HOME}/.config/environment.d/proxy.conf
  #
#  # Configure Chrome browser proxy settings
#  CHROME_POLICY_DIR="/etc/opt/chrome/policies/managed"
#  sudo mkdir -p ${CHROME_POLICY_DIR}
#  sudo tee ${CHROME_POLICY_DIR}/proxy.json > /dev/null <<EOF
#{
#  "ProxyMode": "fixed_servers",
#  "ProxyServer": "${IP_ADDRESS}:${PORT}",
#  "ProxyBypassList": "localhost,127.0.0.1"
#}
#EOF
  #
#  # Set proper ownership
#  sudo chown -R ${CHROME_REMOTE_USER_NAME}:${CHROME_REMOTE_USER_NAME} ${USER_HOME}/.config
#  sudo chown ${CHROME_REMOTE_USER_NAME}:${CHROME_REMOTE_USER_NAME} ${USER_HOME}/.bashrc
  #
#  echo "Manual proxy settings applied for XFCE4 environment."
#else
#   echo "GUI installation failed. Skipping desktop environment reload."
#fi

# End timer
end_time=$(date +%s)
duration=$((end_time - start_time))

# Calculate hours, minutes, and seconds (using 'duration' now)
duration_hours=$((duration / 3600))
duration_minutes=$(((duration % 3600) / 60))
duration_secs=$((duration % 60))

# Format the duration output
if [ $duration_hours -gt 0 ]; then
  duration_output="${duration_hours} hours, ${duration_minutes} minutes, ${duration_secs} seconds"
elif [ $duration_minutes -gt 0 ]; then
  duration_output="${duration_minutes} minutes, ${duration_secs} seconds"
else
  duration_output="${duration_secs} seconds"
fi

echo "All commands executed. Please check for any errors above."
echo "Installation process completed in ${duration_output}."
