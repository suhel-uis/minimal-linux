#!/bin/bash

# Start timer
start_time=$(date +%s)

DEFAULT_BURP_VERSION="2024.12.1"

# Fetch Burp version (improved error handling)
BURP_VERSION_RAW=$(curl -s "https://portswigger.net/burp/releases" | grep -oP 'Professional / Community \K\d+\.\d+\.\d+' | head -n 1)

if [ -z "${BURP_VERSION_RAW}" ]; then
  echo "Warning: Could not automatically determine the latest Burp Suite version."
  echo "Falling back to default Burp Suite version: ${DEFAULT_BURP_VERSION}"
  BURP_VERSION="${DEFAULT_BURP_VERSION}"
else
  BURP_VERSION="${BURP_VERSION_RAW}"
  echo "Latest Burp Suite Community Edition version found: ${BURP_VERSION}"
fi

# Update package lists (combined for efficiency)
echo "Updating package lists..."
sudo apt update

# Install packages (combined for efficiency and better readability)
echo "Installing minimal desktop environment and essential tools..."
sudo apt install -y xorg openbox lxterminal network-manager-gnome jgmenu pcmanfm policykit-1-gnome

# Install Chrome Remote Desktop (improved error handling and cleanup)
echo "Installing Chrome Remote Desktop..."
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" -O /tmp/chrome-remote-desktop.deb  # More descriptive filename
if [ $? -eq 0 ]; then # Check wget success
    sudo apt install -y /tmp/chrome-remote-desktop.deb
    rm /tmp/chrome-remote-desktop.deb # Cleanup
else
    echo "Error: Failed to download Chrome Remote Desktop."
    exit 1 # Or handle differently
fi

# Install Google Chrome Stable (improved error handling and cleanup)
echo "Installing Google Chrome Stable..."
wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O /tmp/google-chrome-stable.deb # More descriptive filename
if [ $? -eq 0 ]; then # Check wget success
  sudo apt install -y ./tmp/google-chrome-stable.deb
  rm /tmp/google-chrome-stable.deb # Cleanup
else
  echo "Error: Failed to download Google Chrome Stable."
  exit 1 # Or handle differently
fi


# Install Burp Suite Community Edition (improved error handling and permissions)
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
wget -q "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite
if [ $? -eq 0 ]; then # Check wget success
  chmod +x burpsuite # More secure than 777
  sudo ./burpsuite -q
else
  echo "Error: Failed to download Burp Suite."
  exit 1 # Or handle differently
fi

# End timer and calculate duration
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "All commands executed. Please check for any errors above."
echo "Installation process completed in ${duration} seconds."

exit 0 # Indicate successful completion
