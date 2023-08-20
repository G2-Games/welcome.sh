getVersion () {
    local ver
    ver=$(grep version ~/.welcome/welcome.sh 2> /dev/null | sed 's/.*=//')

    if [ -z "$ver" ]; then
        echo -e "\bUnknown"
        return
    fi

    echo "$ver"
}

# Universal read command for bash and zsh
univRead () {
    echo -en "$1"
    echo -en "\n[\e[36mY/n\e[0m]"
    if [[ "$environment" = "bash" ]]; then
        read -p " " -r
    elif [[ "$environment" = "zsh" ]]; then
        read -q "REPLY? " -r
    fi
    echo
}

uninstall () {
    # Check if the user actually wishes to uninstall the script
    univRead "Do you want to \e[31muninstall \e[35mwelcome.sh\e[0m?"
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        tput rc el ed
        echo -e "\e[31mUninstall cancelled.\e[0m"
        exit 0
    fi

    tput rc el ed
    echo "Goodbye. Uninstalling..."
    tput sc
    rm ~/.welcome/welcome.sh 2> /dev/null
    rm ~/.welcome/install.sh 2> /dev/null
    rm ~/.welcome/config.cfg 2> /dev/null
    rm ~/.welcome/config_old.cfg 2> /dev/null
    rm -r ~/.welcome

    #remove all lines that match the string
    lines=$(grep -sn 'bash ~/.welcome/welcome.sh' "$bashrc" | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' "$bashrc" | sed -e 's/:.*//g')
    lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
    for i in $lines; do
        sed "${i}d" "$bashrc" > file.tmp && mv file.tmp "$bashrc"
    done

    lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' "$zshrc" | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' "$zshrc" | sed -e 's/:.*//g')
    lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
    for i in $lines; do
        sed "${i}d" "$zshrc" > file.tmp && mv file.tmp "$zshrc"
    done

    tput rc && tput el && tput ed
    echo -e "\e[36mUninstalled! \e[0m"
}

update () {
    tput rc el ed
    echo "Updating..."
    tput sc
    mkdir -p ~/.welcome
    rm ~/.welcome/welcome.sh 2> /dev/null
    rm ~/.welcome/install.sh 2> /dev/null

    curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --output ~/.welcome/welcome.sh
    curl -SL https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh --output ~/.welcome/install.sh
    if [[ $vernum -ge 100 ]] && [[ $overcfg -gt 0 ]]; then
        echo "Backing up: config.cfg >> config_old.cfg"
        mv ~/.welcome/config.cfg ~/.welcome/config_old.cfg
        curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --output ~/.welcome/config.cfg
    fi

    # Check for older versions and replace bashrc lines
    lines=$(grep -sn 'bash ~/.welcome/welcome.sh' "$bashrc" | sed -e 's/:.*//g' && grep -sn 'bash /home/$USER/.welcome/welcome.sh' "$bashrc" | sed -e 's/:.*//g') # Find target line number
    lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g') # Format the line number properly (macos doesn't have Cut)
    for i in $lines; do
        sed "${i}d" "$bashrc" > file.tmp && mv file.tmp "$bashrc"
    done
    echo 'bash ~/.welcome/welcome.sh' >> "$bashrc"

    lines=$(grep -sn 'zsh ~/.welcome/welcome.sh' "$zshrc" | sed -e 's/:.*//g' && grep -sn 'zsh /home/$USER/.welcome/welcome.sh' "$zshrc" | sed -e 's/:.*//g')
    lines=$(printf '%s\n' "$lines" | sed '1!G;h;$!d' | sed ':a;N;$!ba;s/\n/ /g')
    for i in $lines; do
        sed "${i}d" "$zshrc" > file.tmp && mv file.tmp "$zshrc"
    done
    echo 'zsh ~/.welcome/welcome.sh' >> "$zshrc"

    tput rc el ed
    echo -e "\e[32mUpdated to v$version! \e[0m"
}

tput sc
if [[ -z "$1" ]] && [[ $1 != "auto" ]]; then
    echo "Checking for latest release..."
fi

if ! [[ $(command -v curl) ]]; then
    exit 1
fi

latestver=$(curl -Ls https://github.com/G2-Games/welcome.sh/releases/latest/download/welcome.sh | grep version | cut -d= -f2)
oldver=$(grep version ~/.welcome/welcome.sh 2> /dev/null | cut -d= -f2 | sed 's/[.][.]*//g') && if [[ -z "$oldver" ]]; then oldver=0; fi

version="${1:-$latestver}"

if [[ $1 == "auto" ]] && [[ ${latestver//./} -le $oldver ]]; then
    exit 0
elif [[ $1 == "auto" ]]; then
    version=$latestver
fi

vernum=${version//./}
bashrc=~/.bashrc
zshrc=~/.zshrc
originaldir=$PWD
environment=$(ps -o args= -p $$ | grep -Em 1 -o '\w{0,5}sh' | head -1)

# Check if the environment is bash or zsh
if [[ "$environment" != "bash" ]] && [[ "$environment" != "zsh" ]]; then
    tput rc
    printf "\e[31;5mERROR:\e[0m \e[31;3mThis script can only be installed in Bash or Zsh.\e[0m\n"
    printf "\e[32mYou appear to be using %s, which is not a valid shell for\n\
this script!\e[0m Please use \e[3mBash \e[0mor \e[3mZsh.\e[0m\n" "${environment}"
    exit 1
fi

# Check if already installed
if  ! grep -qs 'bash ~/.welcome/welcome.sh' $bashrc &&
    ! grep -qs 'zsh ~/.welcome/welcome.sh' $zshrc &&
    ! grep -qs 'bash /home/$USER/.welcome/welcome.sh' $bashrc &&
    ! grep -qs 'zsh /home/$USER/.welcome/welcome.sh' $zshrc;
then
    #==== Execute if first time installing...====#
    tput rc
    echo "Welcome! Installing v$version in $environment..."
    tput sc

    cd ~/ || exit 1
    mkdir -p ~/.welcome
    curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/welcome.sh --output ~/.welcome/welcome.sh
    curl -SL https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh --output ~/.welcome/install.sh

    if [[ $vernum -ge 100 ]]; then
        curl -SL https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg --output ~/.welcome/config.cfg
    fi
    chmod +x ~/.welcome/welcome.sh

    if [[ "$environment" = "bash" ]]; then
        echo "Installing to bashrc"
        echo 'bash ~/.welcome/welcome.sh' >> $bashrc
    elif [[ "$environment" = "zsh" ]]; then
        echo "Installing to zshrc"
        echo 'zsh ~/.welcome/welcome.sh' >> $zshrc
    fi

    cd "$originaldir" || exit 1
    tput rc el ed
    echo -e "\e[36mInstalled! \e[0m"
else
    #==== Execute if already installed...====#

    tput rc sc el ed
    mkdir -p ~/.welcome
    if ! [[ $1 == "auto" ]]; then
        echo -e "\e[35mwelcome.sh\e[0m already installed!"
    else
        echo -e "\e[32mUpdate available for \e[35mwelcome.sh!\e[0m"
    fi

    if [[ $vernum -gt $oldver ]]; then
        # Pull the new configuration version from github
        newCfgVer=$(curl -Ls https://github.com/G2-Games/welcome.sh/releases/download/v"${version}"/config.cfg | grep version | cut -d= -f2)

        univRead "Do you want to \e[36mupdate \e[35mwelcome.sh\e[0m? (\e[36mv$(getVersion)\e[0m => \e[32mv$version\e[0m)"
        if ! [[ $REPLY =~ ^[Yy]$ ]]; then
            tput rc sc el ed
            echo -e "\e[31mUpdate cancelled.\e[0m"
            update=0
        else
            update=1
        fi

        if [[ $newCfgVer -gt $(grep version ~/.welcome/config.cfg 2> /dev/null | cut -d= -f2) ]]; then
            univRead "Newer \e[36mconfig\e[0m version available. Do you want to \e[31moverwrite\e[0m your \e[36mconfig\e[0m? \nA backup will be created in the \e[36m.welcome\e[0m folder."
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                overcfg=1
            fi
        elif [[ $oldver -lt 100 ]]; then
            overcfg=1
        else
            overcfg=0
        fi
    fi

    if [[ update -gt 0 ]]; then
        update
        exit 0
    fi

    if ! [[ $1 == "auto" ]]; then
        uninstall
        exit 0
    fi
fi
