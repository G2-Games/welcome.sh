#!/bin/zsh

version='0.1'
bashrc="/home/$USER/.bashrc"
zshrc="/home/$USER/.zshrc"
originaldir=$PWD
environment=$(readlink /proc/$$/exe)
if [[ "$environment" = "/usr/bin/bash" ]] || [[ "$environment" = "/usr/bin/zsh" ]];
then
    if ! grep -q 'bash /home/$USER/.welcome/welcome.sh' $bashrc && ! grep -q 'zsh /home/$USER/.welcome/welcome.sh' $zshrc;
    then
        tput sc
        echo "Welcome! Installing..."
        cd /home/$USER
        mkdir -p /home/$USER/.welcome
        curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --output /home/$USER/.welcome/welcome.sh
        chmod +x /home/$USER/.welcome/welcome.sh
        if [[ "$environment" = "/usr/bin/bash" ]];
        then
            echo 'bash /home/$USER/.welcome/welcome.sh' >> $bashrc
            echo "Installing to bashrc"
        elif [[ "$environment" = "/usr/bin/zsh" ]];
        then
            echo 'zsh /home/$USER/.welcome/welcome.sh' >> $zshrc
            echo "Installing to zshrc"
        fi
        cd "$originaldir"
        tput rc el ed
        echo -e "\e[36mInstalled! \e[0m"
    else
        tput sc
        echo -e "\e[35mwelcome.sh\e[0m already installed!"
        echo -en "Do you want to \e[31muninstall \e[35mwelcome.sh\e[0m?\n\e[36mY/n\e[0m"
        if [[ "$environment" = "/usr/bin/bash" ]]
        then
            read -p " " -n 1 -r
        elif [[ "$environment" = "/usr/bin/zsh" ]]
        then
            read -q "REPLY? " -n 1 -r
        fi
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            rm /home/$USER/.welcome/welcome.sh
            rmdir /home/$USER/.welcome
            sed -i 's#bash /home/$USER/.welcome/welcome.sh##g' $bashrc # Try from both
            sed -i 's#zsh /home/$USER/.welcome/welcome.sh##g' $zshrc
            tput rc el ed
            echo -e "\e[36mUninstalled! \e[0m"
        else
            tput rc el ed
            echo -e "\e[32mCancelled. \e[0m"
        fi
    fi
else
    echo "This script can only be installed in bash or zsh."
fi
