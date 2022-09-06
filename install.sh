version=0.2.4
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
        if which curl >/dev/null ;
        then
            curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --output /home/$USER/.welcome/welcome.sh
        elif which wget >/dev/null ;
        then
            wget https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --P /home/$USER/.welcome/
        else
            echo "Cannot download, neither wget nor curl is available."
            exit 1
        fi
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
            if grep -n 'bash /home/$USER/.welcome/welcome.sh' $bashrc ;
            then
                line=$(grep -n 'bash /home/$USER/.welcome/welcome.sh' $bashrc)
                line=${line%:*}
                sed -i "${line}d" $bashrc
            fi
            if grep -n 'zsh /home/$USER/.welcome/welcome.sh' $zshrc ;
            then
                line=$(grep -n 'zsh /home/$USER/.welcome/welcome.sh' $zshrc)
                line=${line%:*}
                sed -i "${line}d" $zshrc
            fi
            tput rc el ed
            echo -e "\e[36mUninstalled! \e[0m"
        else
            tput rc el ed
            echo -e "\e[32mCancelled. \e[0m"
        fi
    fi
else
    printf "\e[31;5mERROR:\e[0m \e[31;3mThis script can only be installed in bash or zsh.\e[0m\n"
fi
