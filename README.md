# welcome.sh
![image](https://user-images.githubusercontent.com/72430668/188241809-fd94292e-23a4-4bba-bb76-82b863bbdddb.png)
### A nice welcome script for Bash
This is a nice little script for your `.bashrc` that greets you on every launch, with some helpful (and customizable!) information.

My goal with this script is to keep it simple, just a single line that gives useful information when you start the terminal.

#### Features:
- Relatively fast
- <span title="Please let me know of other things to support!">Works across many distros (update checking support)</span>
- Clean and simple
- Written entirely in Bash
<hr>

### Installing:
#### Via Curl
```
bash -c "$(curl -s https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh)"
``` 
#### Or wget
```
bash -c "$(wget -q https://raw.githubusercontent.com/G2-Games/welcome.sh/main/install.sh -O -)"
```

It installs to `~/.welcome/welcome.sh`, and adds a line to the bottom of `~/.bashrc`

Run again to uninstall.

#### Manual Installation
To use it, download `welcome.sh` and place it in your home directory. Then add `/home/$USER/welcome.sh` to your `.bashrc`

### Updating:
WIP

Currently you can update by uninstalling and reinstalling, but this wipes all settings. I am working on making a better way to do this.
<hr>

### Configs:
To configure settings, open `welcome.sh` in your text editor of choice and go to the bottom. There, you'll find a few settings:

![github2](https://user-images.githubusercontent.com/72430668/188288031-78727633-79da-42c4-8f1e-1fdafb9fe1a2.png)


Here, you can re-arrange the modules, and turn off and on flatpak and recharge notifications. I recommend leaving flatpak off as it makes startup incredibly slow. 

I'm planning on making this config section a separate file later to make changing settings easier and updating easier.
<hr>

### TODO:
- [x] Add easier way to install and update
- [ ] Fix issues across other distros
- [ ] Add new features?
