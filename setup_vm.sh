#!/bin/bash

DEFAULT_BURP_VERSION="2024.12.1"  # Default version if fetching fails

# Use curl to fetch the webpage and grep to find the version number
BURP_VERSION_RAW=$(curl -s "https://portswigger.net/burp/releases" | grep -oP 'Professional / Community \K\d+\.\d+\.\d+' | head -n 1)

# Check if version extraction was successful
if [ -z "${BURP_VERSION_RAW}" ]; then
  echo "Warning: Could not automatically determine the latest Burp Suite version."
  echo "Falling back to default Burp Suite version: ${DEFAULT_BURP_VERSION}"
BURP_VERSION="${DEFAULT_BURP_VERSION}" # Use default version
else
  BURP_VERSION="${BURP_VERSION_RAW}"
  echo "Latest Burp Suite Community Edition version found: ${BURP_VERSION}"
fi
# -----------------------------------------------------

# Check if the Chrome Remote Desktop code is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Chrome Remote Desktop code is missing."
  echo "Usage: sudo bash <script_name.sh> <chrome_remote_desktop_code>"
  echo "       Please provide the Chrome Remote Desktop code as a command-line argument."
  exit 1 # Exit with an error code
fi

CHROME_REMOTE_DESKTOP_CODE="$1" # Store the first command-line argument as the code

# Update package lists to ensure you have the latest versions
sudo apt update

# Install minimal Xorg, Openbox, Terminal, Network Manager GUI, Menu, and File Manager
echo "Installing minimal Xorg server..."
sudo apt install -y xorg

echo "Installing Openbox window manager..."
sudo apt install -y openbox

echo "Installing LXTerminal terminal emulator..."
sudo apt install -y lxterminal

echo "Installing Network Manager GUI..."
sudo apt install -y network-manager-gnome

echo "Installing jgmenu for application menu..."
sudo apt install -y jgmenu

echo "Installing PCManFM file manager..."
sudo apt install -y pcmanfm

# (Optional) Install policykit-1-gnome - might be needed for GUI authentication
echo "Installing PolicyKit GUI agent (optional)..."
sudo apt install -y policykit-1-gnome

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop..."
curl -o /tmp/chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
sudo apt install -y /tmp/chrome-remote-desktop_current_amd64.deb

# Execute Chrome Remote Desktop start-host command with the provided code
echo "Executing Chrome Remote Desktop start-host command with provided code..."
sudo -u $USER DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="${CHROME_REMOTE_DESKTOP_CODE}" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname) --user-name=$USER

# Install Google Chrome Stable (using apt to handle dependencies)
echo "Installing Google Chrome Stable..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
sudo wget "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite && \
sudo chmod 777 burpsuite && \
sudo ./burpsuite -q

# -----------------------------------------------------
# Configure PERSISTENT System-Wide Proxy Settings for GUI Login using gsettings AFTER installation
echo "-----------------------------------------------------"
echo "Configuring PERSISTENT system-wide proxy settings for GUI login to 127.0.0.1:8080 using gsettings..."
echo "WARNING: This will set system-wide proxy settings using gsettings."
echo "         These settings are designed to be persistent across GUI logins and reboots."
echo "         They are primarily respected by GUI applications in GNOME-based environments."
echo "         Command-line tools and non-GNOME applications might require separate configuration."
echo "         To disable PERSISTENTLY, you will need to use gsettings commands or GUI settings."
echo "-----------------------------------------------------"

# Set proxy mode to 'manual'
sudo -u $USER gsettings set org.gnome.system.proxy mode 'manual'

# Set HTTP proxy settings
sudo -u $USER gsettings set org.gnome.system.proxy.http host '127.0.0.1'
sudo -u $USER gsettings set org.gnome.system.proxy.http port 8080

# Set HTTPS proxy settings
sudo -u $USER gsettings set org.gnome.system.proxy.https host '127.0.0.1'
sudo -u $USER gsettings set org.gnome.system.proxy.https port 8080

# (Optional) Set ignore hosts (no_proxy) - adjust as needed
sudo -u $USER gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.1', '$(hostname -I)']"

echo "Persistent system-wide proxy settings configured for GUI login using gsettings."
echo "Proxy settings should be active in GUI applications after login/reboot."
echo "-----------------------------------------------------"
echo "To DISABLE PERSISTENT system-wide proxy settings set by this script:"
echo "  Option 1: Run the following commands in a terminal:"
echo "    gsettings set org.gnome.system.proxy mode 'none'"
echo "  Option 2: Use the Network settings GUI to disable the proxy:"
echo "    (You might find proxy settings under Network settings or System Settings -> Network -> Network Proxy)"
echo "-----------------------------------------------------"

echo "All commands executed. Please check for any errors above."
echo "Installation and persistent GUI proxy configuration process completed!"
