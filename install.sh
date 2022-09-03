#!/bin/bash
version=0.1
bashrc="/home/$USER/.bashrc"

if ! grep -q 'bash /home/$USER/.welcome/welcome.sh' $bashrc;
then
    tput sc
    echo "Welcome! Installing..."
    cd /home/$USER
    mkdir -p /home/$USER/.welcome
    curl https://raw.githubusercontent.com/G2-Games/welcome-sh/main/welcome.sh --output /home/$USER/.welcome/welcome.sh
    chmod +x /home/$USER/.welcome/welcome.sh
    echo 'bash /home/$USER/.welcome/welcome.sh' >> $bashrc
    tput rc el ed
    echo -e "\e[36mInstalled! \e[0m"
else
    tput sc
    echo -e "\e[35mwelcome.sh\e[0m already installed!"
    echo -en "\e[31mDo you want to uninstall welcome.sh?\e[0m\n\e[36mY/n\e[0m"
    read -p " " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        rm /home/$USER/.welcome/welcome.sh
        rmdir /home/$USER/.welcome
        sed -i 's#bash /home/$USER/.welcome/welcome.sh##g' $bashrc
        tput rc el ed
        echo -e "\e[36mUninstalled! \e[0m"
    else
        tput rc el ed
        echo -e "\e[32mCancelled. \e[0m"
    fi

fi
