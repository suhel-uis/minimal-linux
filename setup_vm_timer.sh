#!/bin/bash

# Start timer
start_time=$(date +%s)

DEFAULT_BURP_VERSION="2024.12.1"

# Fetch Burp version with timeout
BURP_VERSION_RAW=$(curl -s --connect-timeout 5 "https://portswigger.net/burp/releases" | grep -oP 'Professional / Community \K\d+\.\d+\.\d+' | head -n 1)

if [ -z "${BURP_VERSION_RAW}" ]; then
  echo "Warning: Could not determine Burp version. Using default: ${DEFAULT_BURP_VERSION}"
  BURP_VERSION="${DEFAULT_BURP_VERSION}"
else
  BURP_VERSION="${BURP_VERSION_RAW}"
  echo "Burp Suite version: ${BURP_VERSION}"
fi

# Update package lists
echo "Updating package lists..."
sudo apt update -yqq

# Install LXDE (Lightweight DE)
echo "Installing LXDE..."
sudo apt install -yqq lxde

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop..."
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" && sudo apt install -yqq "./chrome-remote-desktop_current_amd64.deb" && rm "./chrome-remote-desktop_current_amd64.deb"

# Install Google Chrome Stable
echo "Installing Google Chrome Stable..."
wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && sudo apt install -yqq "./google-chrome-stable_current_amd64.deb" && rm "./google-chrome-stable_current_amd64.deb"

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
wget -q "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite && sudo chmod +x burpsuite && sudo ./burpsuite -q && rm burpsuite

# End timer
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "Installation complete in ${duration} seconds."
