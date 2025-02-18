#!/bin/bash

# Start timer
start_time=$(date +%s)

# Download all files upfront in parallel - Chrome Remote Desktop, Google Chrome Stable, VS Code, Burp Suite Community Edition.
echo "Downloading installation files in parallel..."
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" -O chrome-remote-desktop_current_amd64.deb &
wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O google-chrome-stable_current_amd64.deb &
wget -q "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O -yqq vscode.deb &
wget -q "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite &

# Install code editor (VS Code)
echo "Installing VS Code..."
sudo ${APT_INSTALL_CMD} install -yqq ./vscode.deb
rm vscode.deb

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop..."
sudo apt install -yqq "./chrome-remote-desktop_current_amd64.deb"
rm "./chrome-remote-desktop_current_amd64.deb"

# Install Google Chrome Stable
echo "Installing Google Chrome Stable..."
sudo apt install -yqq "./google-chrome-stable_current_amd64.deb"
rm "./google-chrome-stable_current_amd64.deb"

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
sudo chmod +x burpsuite
sudo ./burpsuite -q
rm burpsuite

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
