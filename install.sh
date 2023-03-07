# shellcheck disable=SC2016
printReturn () {
    tput rc
    echo "$1"
    tput sc
}

getVersion () {
    ver=$(grep version ~/.welcome/welcome.sh 2> /dev/null | sed 's/.*=//')

    if [ -z "$ver" ]; then
        echo -e "\bUnknown"
        return
    fi

    echo "$ver"
}

univRead () { # Universal read command for bash and zsh
    echo -en "$1"
    if [[ "$environment" = "bash" ]]; then
        read -p " " -n 1 -r;
    elif [[ "$environment" = "zsh" ]]; then
        read -q "REPLY? " -n 1 -r
    fi
    echo
}

tput sc
if ! [[ $1 == "auto" ]] && [[ -z "$1" ]]; then
    echo "Checking for latest release..."
fi

latestver=$(curl -Ls https://github.com/G2-Games/welcome.sh/releases/latest/download/welcome.sh | grep version | sed 's/.*=//')
oldver=$(grep version ~/.welcome/welcome.sh 2> /dev/null | sed 's/.*=//' | sed 's/[.][.]*//g') && if [[ -z "$oldver" ]]; then oldver=0; fi

version="${1:-$latestver}"

if [[ $1 == "auto" ]] && [[ ${latestver/[.][.]*/} -le $oldver ]]; then
    exit 0
elif [[ $1 == "auto" ]]; then
    version=$latestver
fi

vernum=${version/[.][.]*/}
bashrc=~/.bashrc
zshrc=~/.zshrc
originaldir=$PWD
environment=$(ps -o args= -p $$ | grep -Em 1 -o '\w{0,5}sh' | head -1)

if [ "$environment" = "bash" ] || [ "$environment" = "zsh" ]; then
    if ! grep -qs 'bash ~/.welcome/welcome.sh' $bashrc &&\
    ! grep -qs 'zsh ~/.welcome/welcome.sh' $zshrc &&\
    ! grep -qs 'bash /home/$USER/.welcome/welcome.sh' $bashrc &&\
    ! grep -qs 'zsh /home/$USER/.welcome/welcome.sh' $zshrc; then

        printReturn "Welcome! Installing v$version in $environment..."

        cd ~/ || return
        mkdir -p ~/.welcome
        if which curl >/dev/null ; then
            curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --output ~/.welcome/welcome.sh
            if [[ $vernum -ge 100 ]]; then
                curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --output ~/.welcome/config.cfg
            fi
        elif which wget >/dev/null ; then
            wget https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --P ~/.welcome/
            if [[ $vernum -ge 100 ]]; then
                wget https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --P ~/.welcome/
            fi
        else
            echo -e "\e[31mCannot download, neither Wget nor cURL is available!\e[0m"
            exit 1
        fi
        chmod +x ~/.welcome/welcome.sh


        if [[ "$environment" = "bash" ]]; then
            echo "Installing to bashrc"
            echo 'bash ~/.welcome/welcome.sh' >> $bashrc
        elif [[ "$environment" = "zsh" ]]; then
            echo "Installing to zshrc"
            echo 'zsh ~/.welcome/welcome.sh' >> $zshrc
        fi

        cd "$originaldir" || return
        tput rc && tput el && tput ed
        echo -e "\e[36mInstalled! \e[0m"
    else
        tput rc
        tput sc
        mkdir -p ~/.welcome
        if ! [[ $1 == "auto" ]]; then
            echo -e "\e[35mwelcome.sh\e[0m already installed!"
        else
            echo -e "\e[32mUpdate available for \e[35mwelcome.sh!\e[0m"
        fi
        if [[ $vernum -gt $oldver ]]; then
            if which curl >/dev/null ; then
                cfgver=$(curl -Ls https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg | grep version | sed 's/.*=//' | sed 's/[.][.]*//g')
            elif which wget >/dev/null; then
                cfgver=$(wget -q https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg -O - | grep version | sed 's/.*=//' | sed 's/[.][.]*//g')
            fi

            univRead "Do you want to \e[36mupdate \e[35mwelcome.sh\e[0m? (\e[36mv$(getVersion)\e[0m => \e[32mv$version\e[0m) \n\e[36mY/n\e[0m"

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [[ $cfgver -gt $(grep version ~/.welcome/config.cfg 2> /dev/null | sed 's/.*=//' | sed 's/[.][.]*//g') ]] && [ -n ~/.welcome/config.cfg ]; then

                    UnivRead "Newer \e[36mconfig\e[0m version available. Do you want to \e[31moverwrite\e[0m your \e[36mconfig\e[0m? \nA backup will be created in the \e[36m.welcome\e[0m folder.\n\e[36mY/n\e[0m"

                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        overcfg=1
                    fi
                elif [ $oldver -lt 100 ]; then
                    overcfg=1
                else
                    overcfg=0
                fi
                tput rc && tput el && tput ed
                echo "Updating..."
                tput sc
                mkdir -p ~/.welcome
                rm ~/.welcome/welcome.sh
                if which curl >/dev/null ;
                then
                    curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --output ~/.welcome/welcome.sh
                    if [[ $vernum -ge 100 ]] && [[ $overcfg -gt 0 ]]; then
                        echo "Backing up: config.cfg >> config_old.cfg"
                        mv ~/.welcome/config.cfg ~/.welcome/config_old.cfg
                        curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --output ~/.welcome/config.cfg
                    fi
                elif which wget >/dev/null ;
                then
                    wget https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --P ~/.welcome/
                    if [[ $vernum -ge 100 ]] && [[ $overcfg -gt 0 ]]; then
                        echo "Backing up: config.cfg >> config_old.cfg"
                        mv ~/.welcome/config.cfg ~/.welcome/config_old.cfg
                        wget https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --P ~/.welcome/
                    fi
                else
                    echo -e "\e[31mCannot update, neither Wget nor cURL is available!\e[0m"
                    exit 1
                fi

                # Check for older versions and replace bashrc lines
                lines=$(grep -sn 'bash ~/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g')
                lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
                for i in $lines; do
                    sed "${i}d" $bashrc > file.tmp && mv file.tmp $bashrc
                done
                echo 'bash ~/.welcome/welcome.sh' >> $bashrc

                lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g')
                lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
                for i in $lines; do
                    sed "${i}d" $zshrc > file.tmp && mv file.tmp $zshrc
                done
                echo 'zsh ~/.welcome/welcome.sh' >> $zshrc

                tput rc && tput el && tput ed
                echo -e "\e[32mUpdated to v$version! \e[0m"
                exit 0
            else
                tput rc && tput el && tput ed
                if ! [[ $1 == "auto" ]]; then
                    echo -e "\e[35mwelcome.sh\e[0m already installed!"
                else
                    exit 0
                fi
            fi
        fi

        univRead "Do you want to \e[31muninstall \e[35mwelcome.sh\e[0m?\n\e[36mY/n\e[0m"

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tput rc && tput el && tput ed
            echo "Goodbye. Uninstalling..."
            tput sc
            rm ~/.welcome/welcome.sh 2> /dev/null
            rm ~/.welcome/config.cfg 2> /dev/null
            rm ~/.welcome/config_old.cfg 2> /dev/null
            rm -r ~/.welcome

            #remove all lines that match the string
            lines=$(grep -sn 'bash ~/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' $bashrc | sed -e 's/:.*//g')
            lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
            for i in $lines; do
                sed "${i}d" $bashrc > file.tmp && mv file.tmp $bashrc
            done

            lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' $zshrc | sed -e 's/:.*//g')
            lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
            for i in $lines; do
                sed "${i}d" $zshrc > file.tmp && mv file.tmp $zshrc
            done

            tput rc && tput el && tput ed
            echo -e "\e[36mUninstalled! \e[0m"
        else
            tput rc && tput el && tput ed
            echo -e "\e[31mCancelled. \e[0m"
            exit 0
        fi
    fi
else
    printf "\e[31;5mERROR:\e[0m \e[31;3mThis script can only be installed in Bash or Zsh.\e[0m\n"
fi
