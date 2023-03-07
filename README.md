# welcome.sh
![image](https://user-images.githubusercontent.com/72430668/190891298-c08c8ad8-9270-4549-b3ae-85e48ae2748b.png)

### A nice welcome script for Bash and Zsh
This is a nice little script for your `.bashrc` or `.zshrc` that greets you on every launch, with some helpful (and customizable!) information.

My goal with this script is to keep it simple, just a single line that gives useful information when you start a terminal session.

#### Features:
- Relatively fast
- <span title="Please let me know of other things to support!">Works across many distros (update checking support)</span>
- Clean and simple
- Customizable
- Easy to install and update

#### Requirements:
- Terminal with 24-bit true color support
  - Can check with `printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"`, will return `TRUECOLOR` in Brown if supported<br>
  <sup>Source: [https://github.com/termstandard/colors](https://github.com/termstandard/colors)</sup>
  - [List of supported terminal emulators](https://github.com/termstandard/colors#truecolor-support-in-output-devices)
- A modern version of Bash or Zsh (eg. the `/bin/sh` shell in Ubuntu does **not** work)
<hr>

### Installing:
#### Via Curl
<sub>Bash:</sub>
```
bash -c "$(curl -s https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh)"
``` 
<sub>Zsh:</sub>
```
zsh -c "$(curl -s https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh)"
```

It installs to `~/.welcome/welcome.sh`, and adds a line to the bottom of `~/.bashrc` or `~/.zshrc`

#### Manual Installation
To use it, download the latest `welcome.sh` from <a href="https://github.com/G2-Games/welcome.sh/releases/latest">releases</a> and place it in your home directory. Then add `bash ~/welcome.sh` to your `.bashrc`. It works without the config file, but you can also add that to your home directory for easier manual updates.

### Updating:
Run the script again to check for an update. If you have an older version it will prompt you. You can update **from** any version **to** any newer version. The proper files will be downloaded as necessary.

<hr>

### Configs:
To configure settings, open `~/.welcome/config.cfg` in your text editor of choice. There, you'll find a few settings:

```bash
#==================SETUP=================#
# Select which parts you want active by  #
# commenting them out. For example, on a #
# desktop, disabling the battery message #
# is a good idea. You can also re-order  #
# them to change how they display!       #
#========================================#

greetings=("Welcome" "Greetings" "Hello" "Hi") # Add your own greetings!
randgreeting="off"  #< Turn the random greetings on (eg. "Hello <user>, Hi <user>")
twelvehour="on"     #< Switch between 12 and 24 hour time (eg. 8:00 PM vs 20:00)
rechargenotif="off" #< Notify that you should recharge if below 15%
updatecheck="on"    #< Check for all updates, slows startup a bit
flatpakupd="off"    #< Check for flatpak updates, this slows startup down A LOT
goodgreeting="on"   #< Display greetings like "Good afternoon," else "It's afternoon"
displaydate="off"   #< Unused so far

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
DATE='\e[38;2;50;168;82;1m'   # Future "Date" item color
USRC=$(randcolor)             # Username color

# Greeting colors
NIGH='\e[38;2;200;107;209m'
MORN='\e[38;2;255;164;74m'
AFTN='\e[38;2;250;245;110m'
EVEN='\e[38;2;171;54;3m'

cfgversion=2
```
<hr>

### TODO:
- [ ] Fix issues across other distros
- [ ] Add new features? (Please suggest!)
- [ ] Improve MacOS functionality
