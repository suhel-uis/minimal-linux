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

# Install apt-fast
echo "Installing apt-fast..."
sudo add-apt-repository universe -yqq
sudo apt update -yqq
sudo apt install apt-fast -yqq

# Update the packages using apt-fast
echo "Updating package lists using apt-fast..."
sudo apt-fast update -yqq

# Install packages Gui using apt-fast
echo "Installing minimal desktop environment and applications using apt-fast..."
sudo apt-fast install -yqq xorg openbox lxterminal network-manager-gnome jgmenu pcmanfm policykit-1-gnome

# Install GUI unpack software (File Roller) using apt-fast
echo "Installing GUI unpack software (File Roller) using apt-fast..."
sudo apt-fast install -yqq file-roller

# Install code editor gedit using apt-fast
echo "Install code editor gedit using apt-fast..."
sudo apt-fast install -yqq gedit

# Install Chrome Remote Desktop (download with wget for potential speed improvement, and install without download)
echo "Installing Chrome Remote Desktop..."
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" && sudo apt install -yqq "./chrome-remote-desktop_current_amd64.deb" && rm "./chrome-remote-desktop_current_amd64.deb"

# Install Google Chrome Stable (download with wget, install without download, and remove .deb)
echo "Installing Google Chrome Stable..."
wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && sudo apt install -yqq "./google-chrome-stable_current_amd64.deb" && rm "./google-chrome-stable_current_amd64.deb"

# Install Burp Suite Community Edition (wget for download, install without downloading, and remove burpsuite)
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
wget -q "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite && sudo chmod +x burpsuite && sudo ./burpsuite -q && rm burpsuite

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
