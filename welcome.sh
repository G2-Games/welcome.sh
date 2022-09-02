#!/bin/bash

#====Customization=====#
# Set colors for ease of use
NCOL='\e[0m'
CRIT='\e[31m'
LOW='\e[33m'
NORM='\e[32m'
FULL='\e[3;4;92m'
BOLD='\e[1m'
ITAL='\e[3m'
UNDR='\e[4m'
BLNK='\e[5m'
USRC='\e[1;32m'

NIGH='\e[35;1m'
MORN='\e[33m'
AFTN='\e[33;1m'
EVEN='\e[31;1m'

#========Welcome=======#
welcome () {
  # Print the welcome message
  echo -en "Welcome, ${USRC}$USER${NCOL}. "
}

#=======Greeting=======#
greeting () {
  # Set the hour
  hr=$(date +%H)

  if [ $hr -le 11 ] && [ $hr -gt 6 ];
  then
    echo -en "It's ${MORN}morning${NCOL}. "
  elif [ $hr -eq 12 ];
  then
    echo -en "It's ${AFTN}noon${NCOL}. "
  elif [ $hr -le 16 ] && [ $hr -gt 12 ];
  then
    echo -en "It's ${AFTN}afternoon${NCOL}. "
  elif [ $hr -le 19 ] && [ $hr -gt 16 ];
  then
    echo -en "It's ${EVEN}evening${NCOL}. "
  else
    echo -en "It's ${NIGH}night${NCOL}. "
  fi
}

#=====Battery Info=====#
battery () {
  # Set battery level
  if [ -a /sys/class/power_supply/BAT0/capacity ];
  then
    batlvl=$(cat /sys/class/power_supply/BAT0/capacity)
  elif [ -a /sys/class/power_supply/BAT1/capacity ];
  then
    batlvl=$(cat /sys/class/power_supply/BAT1/capacity)
  fi

  # Change color depending on level
  if [ $batlvl -eq 100 ];
  then
    echo -en "The battery is ${FULL}fully charged${NCOL}. "
  else
    echo -en "The battery level is "
    if [ $batlvl -le 15 ];
    then
      echo -en "${CRIT}$batlvl%${NCOL}. "
      echo -en "- ${NORM}You should probably recharge${NCOL}. "
    elif [ $batlvl -le 30 ];
    then
      echo -en "${LOW}$batlvl%${NCOL}. "
    else
      echo -en "${NORM}$batlvl%${NCOL}. "
    fi
  fi
}

#=========Time=========#
clock () {
  # Set the current hour and minute
  hour=$(date +%I)
  minute=$(date +%M)

  # Print the time
  echo -en "The time is ${BOLD}$hour${BLNK}:${NCOL}${BOLD}$minute${NCOL}. "
}

#========Updates=======#
updates () {
  deb=0
  aur=0
  pacman=0
  fedora=0
  flatpak=0

  # Check for updates from different places...

  # Check for APT
  if command -v apt &> /dev/null;
  then
    debian=$(apt-get -s dist-upgrade -V | grep '=>' | awk '{print$1}' | wc -l)
  fi

  # Check for different Arch things
  if command -v yay &> /dev/null;
  then
    arch=$(yay -Qu 2> /dev/null | wc -l)
  elif command -v paru &> /dev/null;
  then
    arch=$(paru -Quq 2> /dev/null | wc -l)
  elif command -v pacman &> /dev/null;
  then
    arch=$(pacman -Qu 2> /dev/null | wc -l)
  fi

  if command -v dnf &> /dev/null;
  then
    fedora=$(dnf list updates 2> /dev/null | wc -l)
    fedora=$((fedora-1))
  elif command -v yum &> /dev/null;
  then
    fedora=$(yum list updates 2> /dev/null | wc -l)
    fedora=$((fedora-1))
  fi

  # Check for Flatpak
  if command -v flatpak &> /dev/null && [ $flatupd == "on" ];
  then
    flatpak=$(flatpak remote-ls --updates 2> /dev/null | wc -l)
  fi


  # Add all update counts together
  updates=$(($debian + $arch + $flatpak + fedora))

  # Check the update amounts and print them out
  if [ $updates -eq 1 ];
  then
    echo -en "You have ${NORM}1${NCOL} pending update. "
  elif [ $updates -eq 0 ];
  then
    echo -en "You have no pending updates. "
  else
    echo -en "You have ~${NORM}$updates${NCOL} pending updates. "
  fi
}

#=========SETUP========#
# Select which parts you want active by commenting them out, and re ordering them.
flatupd="on" # Check for flatpak updates, this slows the script down a lot

welcome
greeting
clock
battery
updates #< This makes startup slower
echo # Properly line break at the end
