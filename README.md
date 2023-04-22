# fedora-silverblue-postinstall
A Fedora Silverblue post installation script  
  
This is WIP! More features to be added and a lot of code cleanup and compartmentalization.  
  
Fedora Silverblue is an 'immutable' distribution.  
This means we heavily relly on flatpaks for our GUI applications and containers (toolbox) for our terminal based applications.  

This post-install script provides a menu and an easy to use experience. You just press a number and enter.  
The script will apply mostly all the configuration I do on my Fedora Silverblue installs and is opinionated.  

## Update system
Updates the system to the latest version. Does not upgrade to a new Fedora release.

## Enable auto update checking
Enables auto update checking without downloading them. You can check if there are new updates using `rpm-osree status` or `rpm-ostree status -v` for a list of the updated packages. To upgrade either choose option 1 or run `rpm-ostree upgrade`

## Enable flathub repository
Removes Fedora's filtered flathub version and adds the full Flathub repository. Also updates any flatpaks that are installed.

## Install Software
Remember what we discussed in the beggining of this ReadMe?  
This option will install any flatpaks declared in [flatpak-packages.txt](./flatpak-packages.txt)

## Setup a Fedora Toolbox
Creates a Fedora toolbox, installs some packages and speeds up dnf for this container

## Speed up performance, boot and shutdown
### These are not tested on AMD machines.
Grub timeout changed from 5 secs to 2 secs  
Systemd stop units timeouts changed from 90secs to 15secs  
Disables mitigations for Intel cpus  
Disables boot splash screen  
Disables NetworkManager-wait-online.service  
Enables Sata Active Link Power Management to med_power_with_dipm [archwiki](https://wiki.archlinux.org/title/Power_management#SATA_Active_Link_Power_Management)

## Install intel-undervolt
Overlays intel-undervolt  
Displays how to use and configure it
