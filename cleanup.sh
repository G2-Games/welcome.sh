#!/bin/bash
version=1

echo "Ensuring welcome.sh is installed in the new location..."

# Check if welcome.sh is installed in the old location
if [[ -f ~/.welcome ]]\
    || [[ -f ~/.welcome/welcome.sh ]]\
    || [[ -f ~/.welcome/config.cfg ]];
then
    # Modify the files with proper paths
    sed "${i}d" "$zshrc" > file.tmp && mv file.tmp "$zshrc"

    # Create the directories in the proper spots
    mkdir -p ~/.config/welcome.sh/
    mkdir -p ~/.local/bin/

    # Move the welcome files to the proper folders
    mv ~/.welcome/config.cfg ~/.config/welcome.sh/config.cfg
    mv ~/.welcome/welcome.sh ~/.local/bin/welcome.sh

    echo "welcome.sh is now installed in the new location!"
else
    echo "welcome.sh is already installed properly!"
fi
