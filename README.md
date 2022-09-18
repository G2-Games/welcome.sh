# welcome.sh
![image](https://user-images.githubusercontent.com/72430668/190891298-c08c8ad8-9270-4549-b3ae-85e48ae2748b.png)

### A nice welcome script for Bash and Zsh
This is a nice little script for your `.bashrc` or `.zshrc` that greets you on every launch, with some helpful (and customizable!) information.

My goal with this script is to keep it simple, just a single line that gives useful information when you start a terminal session.

#### Features:
- Relatively fast
- <span title="Please let me know of other things to support!">Works across many distros (update checking support)</span>
- Clean and simple
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
#### Or wget
<sub>Bash:</sub>
```
bash -c "$(wget -q https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh -O -)"
```
<sub>Zsh:</sub>
```
zsh -c "$(wget -q https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh -O -)"
```

It installs to `~/.welcome/welcome.sh`, and adds a line to the bottom of `~/.bashrc` or `~/.zshrc`

Run again to uninstall. Uninstalling will remove it from both Bash and Zsh.

#### Manual Installation
To use it, download `welcome.sh` and place it in your home directory. Then add `/home/$USER/welcome.sh` to your `.bashrc`.

### Updating:
WIP

Currently you can update by uninstalling and reinstalling, but this wipes all settings. I am working on making a better way to do this.
<hr>

### Configs:
To configure settings, open `welcome.sh` in your text editor of choice and go to the bottom. There, you'll find a few settings:

```bash
#=========SETUP========#
# Select which parts you want active by  #
# commenting them out. For example, on a #
# desktop, disabling the battery message #
# is a good idea. You can also re-order  #
# them to change how they display!       #

randgreeting="off"  #< Turn the random greetings on (eg. "Hello <user>, Hi <user>")
twelvehour="on"     #< Switch between 12 and 24 hour time (eg. 8:00pm vs 20:00)
rechargenotif="off" #< Notify that you should recharge if below 15%
flatpakupd="off"    #< Check for flatpak updates, this slows startup down A LOT

welcome
greeting
clock
battery
updates #< This makes startup slower
echo # Properly line break at the end
```

Here, you can re-arrange the modules, and turn off and on flatpak and recharge notifications. I recommend leaving flatpak off as it makes startup incredibly slow. 

I'm planning on making this config section a separate file later to make changing settings easier and updating easier.
<hr>

### TODO:
- [x] Add easier way to install and update
- [ ] Fix issues across other distros
- [ ] Add new features?
