#!/bin/bash

# Start timer
start_time=$(date +%s)

# Read Chrome Remote Desktop code from command line argument
CHROME_ROMETE_USER_NAME="$1"
CHROME_REMOTE_DESKTOP_CODE="$2"
PRE_CONFIGURED_PIN="123456"
shift

# Download all files upfront in parallel - Chrome Remote Desktop, Google Chrome Stable, VS Code, Burp Suite Community Edition.
echo "Downloading installation files in parallel..."
wget -q "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" -O chrome-remote-desktop_current_amd64.deb 

wait # Wait for all background wget processes to complete
echo "Downloads completed."

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop..."
sudo apt install -yqq "./chrome-remote-desktop_current_amd64.deb"
rm "./chrome-remote-desktop_current_amd64.deb"

# Start Chrome Remote Desktop host if code is provided
if [ -n "${CHROME_REMOTE_DESKTOP_CODE}" ]; then
  echo "Starting Chrome Remote Desktop..."
  # Run start-host as the current user, not as root directly
     DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="${CHROME_REMOTE_DESKTOP_CODE}" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname) --user-name="${CHROME_ROMETE_USER_NAME}" --pin="${PRE_CONFIGURED_PIN}"
  else
  echo "Chrome Remote Desktop start skipped because code was not provided."
fi

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
