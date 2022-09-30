version=1.0.4
export LC_NUMERIC="en_US.UTF-8" #Fix for locales that use , instead of . as a decimal delimiter
#========Welcome=======#
welcome () {
  msg="Welcome" # Default

  if command -v whoami &>/dev/null ; then
    usr=$(whoami)
  elif command -v id &>/dev/null; then
    usr=$(id -u -n)
  else
    usr=$USER
  fi

  if [ "$randgreeting" = "on" ]; then
    msg=${greetings[$(($RANDOM % $(echo ${#greetings[@]})))]}
  fi

  # Print the welcome message
  echo -en "$msg, ${USRC}${BOLD}$usr${NCOL}. "
}

#=========Time=========#
clock () {
  # Set the current hour and minute
  if [ "$twelvehour" = "on" ]; then
    if [ $(date +%_I) -lt 10 ]; then
      hour="\b$(date +%_I)"
    else
      hour="$(date +%_I)"
    fi
    ampm=$(date +%p)
  else
    hour=$(date +%H)
    bksp="\b \b"
  fi
  minute=$(date +%M)

  # Print the time
  echo -en "The time is ${TIME}$hour${BLNK}:${NCOL}${TIME}$minute $bksp${ampm}${NCOL}. "
}

#=======Greeting=======#
greeting () {
  # Set the hour
  hour=$(date +%H)
  greet="It's"

  if [ "$goodgreeting" = "on" ]; then
    greet="Good"
  fi

  if [ $hour -le 11 ] && [ $hour -gt 6 ]; then
    echo -en "$greet ${MORN}morning${NCOL}. "
  elif [ $hour -eq 12 ]; then
    echo -en "It's ${AFTN}noon${NCOL}. "
  elif [ $hour -le 17 ] && [ $hour -gt 12 ]; then
    echo -en "$greet ${AFTN}afternoon${NCOL}. "
  elif [ $hour -le 19 ] && [ $hour -gt 17 ]; then
    echo -en "$greet ${EVEN}evening${NCOL}. "
  else
    echo -en "It's ${NIGH}night${NCOL}. "
  fi
}

#=====Battery Info=====#
battery () {
  # Set battery level
  # Set a default to prevent errors
  batlvl=0

  if [[ -a "/sys/class/power_supply/BAT0/capacity" ]]; then
    batlvl=$(cat /sys/class/power_supply/BAT0/capacity)
  elif [[ -a "/sys/class/power_supply/BAT1/capacity" ]]; then
    batlvl=$(cat /sys/class/power_supply/BAT1/capacity)
  elif command -v pmset &> /dev/null;then
    batlvl=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
  else
    batlvl=-1
  fi

  # Change color depending on level
  if [ $batlvl -ge 100 ]; then
    echo -en "The battery is ${FULL}fully charged${NCOL}. "
  elif [ $batlvl -gt 0 ]; then
    echo -en "The battery level is "
    if [ $batlvl -le 15 ]; then
      echo -en "${CRIT}$batlvl%${NCOL}. "
      if [ "$rechargenotif" = "on" ]; then
        echo -en "- ${NORM}You should probably recharge${NCOL}. "
      fi
    elif [ $batlvl -le 30 ]; then
      echo -en "${LOW}$batlvl%${NCOL}. "
    else
      echo -en "${NORM}$batlvl%${NCOL}. "
    fi
  fi
}

#========Updates=======#
updates () {
  # Set defaults to prevent errors
  debian=0
  arch=0
  fedora=0
  brew=0
  flatpak=0
  chk=0

  # Check for updates from different places... wonder if there's a better way

  updchk () {
    # Check for APT
    if command -v apt-get &> /dev/null; then
      debian=$(apt-get -s dist-upgrade -V 2> /dev/null | grep '=>' | awk '{print$1}' | wc -l)
    fi

    # Check for different Arch things
    if command -v yay &> /dev/null; then
      arch=$(yay -Qu 2> /dev/null | wc -l)
    elif command -v paru &> /dev/null; then
      arch=$(paru -Quq 2> /dev/null | wc -l)
    elif command -v pacman &> /dev/null; then
      arch=$(pacman -Qu 2> /dev/null | wc -l)
    fi

    # Check for Fedora things
    if command -v dnf &> /dev/null; then
      fedora=$(dnf list updates 2> /dev/null | wc -l)
      fedora=$((fedora-1))
    elif command -v yum &> /dev/null; then
      fedora=$(yum list updates 2> /dev/null | wc -l)
      fedora=$((fedora-1))
    fi

    # Check for Brew  updates
    if command -v brew &> /dev/null; then
      brew=$(brew outdated 2> /dev/null | wc -l)
    fi

    # Check for Flatpak
    if command -v flatpak &> /dev/null && [ "$flatpakupd" = "on" ]; then
      flatpak=$(flatpak remote-ls --updates 2> /dev/null | wc -l)
    fi
    # Add all update counts together
    updates=$(($debian + $arch + $fedora + $flatpak + $brew))
    echo $updates >| ~/.welcome/updates
    pkill -P $pid sleep
    sleep 5
    if [ -a ~/.welcome/updates ]; then
      rm ~/.welcome/updates
    fi
    return 1
  }

  pid=$(echo $$)
  updchk & #Check for updates Asynchronously

  exec 3>&2
  exec 2> /dev/null
  sleep 5
  chk=$(echo $?) &> /dev/null
  exec 2>&3
  exec 3>&-

  if [ -a updates ]; then
    updates=$(cat updates)
    rm ~/.welcome/updates
  fi

  # Check the update amounts and print them out
  if [ $chk -lt 1 ]; then
    echo -en "Update check timed out. "
  else
    if [ $updates -eq 1 ]; then
      echo -en "You have ${NORM}1${NCOL} pending update. "
    elif [ $updates -eq 0 ]; then
      echo -en "You have no pending updates. "
    else
      echo -en "You have ~${NORM}$updates${NCOL} pending updates. "
    fi
  fi
}

#=====Random Color=====#
randcolor() {
# For random colors; this will only generate colors with sufficient   #
# perceptual luma to be readable on a dark background... you may have #
# to modify it for a light one                                        #
  cluma=0
  loops=0
  while [ $(printf %.0f $cluma) -le 100 ] && [ $loops -le 10 ];
  do
    cr=$((0 + $RANDOM % 255))
    crl=$(echo "$cr 0.299" | awk '{print $1 * $2}')
    cg=$((0 + $RANDOM % 255))
    cgl=$(echo "$cg 0.587" | awk '{print $1 * $2}')
    cb=$((0 + $RANDOM % 255))
    cbl=$(echo "$cb 0.114" | awk '{print $1 * $2}')
    cluma=$(echo "$crl $cgl $cbl" | awk '{print $1 + $2 + $3}')
    loops=$((loops+1))
  done
  echo "\e[38;2;${cr};${cg};${cb}m"
}

#=========COLORS=======#
NCOL='\e[0m'
BOLD='\e[1m'
ITAL='\e[3m'
UNDR='\e[4m'
BLNK='\e[5m'

# Battery level colors
CRIT='\e[31m'
LOW='\e[33m'
NORM='\e[32m'
FULL='\e[3;4;92m'

TIME='\e[38;2;224;146;252;1m' # Clock color
DATE='\e[38;2;50;168;82;1m'
USRC=$(randcolor) # <-----------Username color

# Greeting colors
NIGH='\e[38;2;200;107;209m'
MORN='\e[38;2;255;164;74m'
AFTN='\e[38;2;250;245;110m'
EVEN='\e[38;2;171;54;3m'

greetings=("Welcome" "Greetings" "Hello" "Hi") # Add your own greetings!
randgreeting="off"  #< Turn the random greetings on (eg. "Hello <user>, Hi <user>")
twelvehour="on"     #< Switch between 12 and 24 hour time (eg. 8:00 PM vs 20:00)
rechargenotif="off" #< Notify that you should recharge if below 15%
updatecheck="on"    #< Check for general updates
flatpakupd="off"    #< Check for flatpak updates, this slows startup down A LOT
goodgreeting="on"   #< Display greetings like "Good afternoon," else "It's afternoon"

source ~/.welcome/config.cfg

welcome
greeting
clock
battery
if [ "$updatecheck" = "on" ]; then updates; fi
echo # Properly line break at the end
