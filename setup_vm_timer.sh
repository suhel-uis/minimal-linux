
#!/bin/bash

# Start timer
start_time=$(date +%s)

# Check if apt-fast is already installed
if command -v apt-fast &> /dev/null; then
  echo "apt-fast is already installed. Skipping installation."
  APT_INSTALL_CMD="apt-fast"
else
  echo "apt-fast is not installed. Proceeding with installation."
  # Install apt-fast
  echo "Installing apt-fast..."
  sudo add-apt-repository ppa:apt-fast/stable -yqq 2> /dev/null # Suppress add-apt-repository output
  sudo apt update -yqq 2> /dev/null # Suppress apt update output
  sudo apt install apt-fast -yqq 2> /dev/null # Suppress apt install output

  # Check again if apt-fast is installed after attempting installation
  if command -v apt-fast &> /dev/null; then
    APT_INSTALL_CMD="apt-fast"
    echo "apt-fast installed successfully. Using apt-fast for package installations."
  else
    APT_INSTALL_CMD="apt"
    echo "apt-fast installation failed. Falling back to using apt for package installations."
  fi
fi

# Update the packages
echo "Updating package lists..."
sudo ${APT_INSTALL_CMD} update -yqq

# Install packages Gui
echo "Installing minimal desktop environment and applications..."
sudo ${APT_INSTALL_CMD} install software-properties-common apt-transport-https wget -y
sudo ${APT_INSTALL_CMD} install -yqq sublime-text
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
