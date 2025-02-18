#!/bin/bash

# Start timer
start_time=$(date +%s)

# Download all files upfront in parallel - Chrome Remote Desktop, Google Chrome Stable, VS Code, Burp Suite Community Edition.
echo "Downloading installation files in parallel..."
wget -q "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O -yqq vscode.deb &
wait # Wait for all background wget processes to complete
echo "Downloads completed."

# Install code editor (VS Code)
echo "Installing VS Code..."
sudo apt-fast install -yqq ./vscode.deb
rm vscode.deb

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
