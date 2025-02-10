#!/bin/bash

DEFAULT_BURP_VERSION="2024.12.1"  # Default version if fetching fails

# Use curl to fetch the webpage and grep to find the version number
BURP_VERSION_RAW=$(curl -s "${BURP_VERSION_PAGE_URL}" | grep -oP 'Burp Suite Community Edition \K\d+\.\d+\.\d+')

# Check if version extraction was successful
if [ -z "${BURP_VERSION_RAW}" ]; then
  echo "Warning: Could not automatically determine the latest Burp Suite version."
  echo "Falling back to default Burp Suite version: <span class="math-inline">\{DEFAULT\_BURP\_VERSION\}"
BURP\_VERSION\="</span>{DEFAULT_BURP_VERSION}" # Use default version
else
  BURP_VERSION="${BURP_VERSION_RAW}"
  echo "Latest Burp Suite Community Edition version found: ${BURP_VERSION}"
fi
# -----------------------------------------------------

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

# Install Google Chrome Stable (using apt to handle dependencies)
echo "Installing Google Chrome Stable..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
sudo wget "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite && \
sudo chmod 777 burpsuite && \
sudo ./burpsuite -q

echo "All commands executed. Please check for any errors above."
echo "Installation process completed!"
