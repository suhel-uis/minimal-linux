
#!/bin/bash

# Start timer
start_time=$(date +%s)

# Update the packages
echo "Updating package lists..."
sudo apt update -yqq

# Install packages Gui
echo "Installing minimal desktop environment and applications..."
sudo apt install software-properties-common apt-transport-https wget -y
sudo apt install -yqq sublime-text
wait # Wait for the GUI installation to complete
echo "GUI installation completed."

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
