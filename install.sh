version="${1:-1.0.2}"
vernum=$(echo $version | sed 's/[.][.]*//g' )
bashrc=~/.bashrc
zshrc=~/.zshrc
originaldir=$PWD
environment=$(ps -o args= -p $$ | grep -Em 1 -o '\w{0,5}sh' | head -1)
if [ "$environment" = "bash" ] || [ "$environment" = "zsh" ];
then
    if ! grep -qs 'bash ~/.welcome/welcome.sh' $bashrc && ! grep -qs 'zsh ~/.welcome/welcome.sh' $zshrc && ! grep -qs 'bash /home/$USER/.welcome/welcome.sh' $bashrc && ! grep -qs 'zsh /home/$USER/.welcome/welcome.sh' $zshrc;
    then
        echo "Welcome! Installing v$version in $environment..."
        tput sc
        cd ~/
        mkdir -p ~/.welcome
        if which curl >/dev/null ;
        then
            curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --output ~/.welcome/welcome.sh
            if [[ $vernum -ge 100 ]]; then
                curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/config.cfg --output ~/.welcome/config.cfg
            fi
        elif which wget >/dev/null ;
        then
            wget https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --P ~/.welcome/
            if [[ $vernum -ge 100 ]]; then
                wget https://github.com/G2-Games/welcome.sh/releases/download/v${version}/config.cfg --P ~/.welcome/
            fi
        else
            echo -e "\e[31mCannot download, neither Wget nor cURL is available!\e[0m"
            exit 1
        fi
        chmod +x ~/.welcome/welcome.sh
        if [[ "$environment" = "bash" ]];
        then
            echo "Installing to bashrc"
            echo 'bash ~/.welcome/welcome.sh' >> $bashrc
        elif [[ "$environment" = "zsh" ]];
        then
            echo "Installing to zshrc"
            echo 'zsh ~/.welcome/welcome.sh' >> $zshrc
        fi
        cd "$originaldir"
        tput rc el ed
        echo -e "\e[36mInstalled! \e[0m"
    else
        tput sc
        echo -e "\e[35mwelcome.sh\e[0m already installed!"
        if [[ $vernum -gt $(grep version ~/.welcome/welcome.sh | sed 's/.*=//' | sed 's/[.][.]*//g') ]]; then
            cfgver=$(echo $(curl -Ls https://github.com/G2-Games/welcome.sh/releases/download/v$version/config.cfg) | grep version | sed 's/.*=//' | sed 's/[.][.]*//g') # Check the new config version
            echo -en "Do you want to \e[36mupdate \e[35mwelcome.sh\e[0m? (v$(grep version ~/.welcome/welcome.sh | sed 's/.*=//') => v$version) \n\e[36mY/n\e[0m"
            if [[ "$environment" = "bash" ]]; then read -p " " -n 1 -r;
            elif [[ "$environment" = "zsh" ]]; then read -q "REPLY? " -n 1 -r; fi
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [[ $cfgver -gt $(grep version ~/.welcome/config.cfg | sed 's/.*=//' | sed 's/[.][.]*//g') ]]; then
                    echo -en "New config version available. Do you want to \e[31moverwrite\e[0m your config?\n\e[36mY/n\e[0m"
                    if [[ "$environment" = "bash" ]]; then read -p " " -n 1 -r;
                    elif [[ "$environment" = "zsh" ]]; then read -q "REPLY? " -n 1 -r; fi
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        overcfg=1
                    fi
                fi
                tput rc el ed
                echo "Updating..."
                tput sc
                rm ~/.welcome/welcome.sh
                if which curl >/dev/null ;
                then
                    curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --output ~/.welcome/welcome.sh
                    if [[ $vernum -ge 100 ]] && [[ $overcfg -gt 0 ]]; then
                        mv ~/.welcome/config.cfg ~/.welcome/config_old.cfg
                        curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v${version}/config.cfg --output ~/.welcome/config.cfg
                    fi
                elif which wget >/dev/null ;
                then
                    wget https://github.com/G2-Games/welcome.sh/releases/download/v${version}/welcome.sh --P ~/.welcome/
                    if [[ $vernum -ge 100 ]] && [[ $overcfg -gt 0 ]]; then
                        mv ~/.welcome/config.cfg ~/.welcome/config_old.cfg
                        wget https://github.com/G2-Games/welcome.sh/releases/download/v${version}/config.cfg --P ~/.welcome/
                    fi
                else
                    echo -e "\e[31mCannot update, neither Wget nor cURL is available!\e[0m"
                    exit 1
                fi

                # Check for older versions and replace bashrc lines
                lines=$(grep -sn 'bash ~/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g')
                lines=$(printf '%s\n' "$( echo "$lines" )" | sort | tac | tr '\n' ' '; echo)
                for i in $( echo "$lines" ); do
                    sed "${i}d" $bashrc > file.tmp && mv file.tmp $bashrc
                done
                echo 'bash ~/.welcome/welcome.sh' >> $bashrc

                lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g')
                lines=$(printf '%s\n' "$( echo "$lines" )" | sort | tac | tr '\n' ' '; echo)
                for i in $( echo "$lines" ); do
                    sed "${i}d" $zshrc > file.tmp && mv file.tmp $zshrc
                done
                echo 'zsh ~/.welcome/welcome.sh' >> $zshrc

                tput rc el ed
                echo -e "\e[32mUpdated to v$version! \e[0m"
                exit 0
            else
                tput rc el ed
                echo -e "\e[35mwelcome.sh\e[0m already installed!"
            fi
        fi
        echo -en "Do you want to \e[31muninstall \e[35mwelcome.sh\e[0m?\n\e[36mY/n\e[0m"
        if [[ "$environment" = "bash" ]]; then read -p " " -n 1 -r;
        elif [[ "$environment" = "zsh" ]]; then read -q "REPLY? " -n 1 -r; fi
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tput rc el ed
            echo "Goodbye. Uninstalling..."
            tput sc
            rm ~/.welcome/welcome.sh
            rm ~/.welcome/config.cfg
            rmdir ~/.welcome

            #remove all lines that match the string
            lines=$(grep -sn 'bash ~/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g')
            lines=$(printf '%s\n' "$( echo "$lines" )" | sort | tac | tr '\n' ' '; echo)
            for i in $( echo "$lines" ); do
                sed "${i}d" $bashrc > file.tmp && mv file.tmp $bashrc
            done

            lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g')
            lines=$(printf '%s\n' "$( echo "$lines" )" | sort | tac | tr '\n' ' '; echo)
            for i in $( echo "$lines" ); do
                sed "${i}d" $zshrc > file.tmp && mv file.tmp $zshrc
            done

            tput rc el ed
            echo -e "\e[36mUninstalled! \e[0m"
        else
            tput rc el ed
            echo -e "\e[31mCancelled. \e[0m"
            exit 0
        fi
    fi
else
    printf "\e[31;5mERROR:\e[0m \e[31;3mThis script can only be installed in Bash or Zsh.\e[0m\n"
fi
