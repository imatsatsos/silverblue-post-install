#!/bin/bash

clear
echo "#####  Fedora 38 Silverblue Setup #####"
echo "Please Choose one of the following options:"
echo "* this menu will reappear *"

#Other variables
#OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

items=("Enable RPM Fusion - Enables the RPM Fusion free and non-free repos"
       "Update system to latest version. Does NOT upgrade to new Fedora release."
       "Enable auto update checking. Does NOT download them!"
       "Enable Flathub - Enables Flathub repo and updates flatpaks"
       "Install Software - Installs a bunch flatpaks"
       "Setup a Fedora toolbox"
       "Speed up performance, boot and shutdown. WARNING! will disable cpu mitigations"
       "Install intel-undervolt"
       "Install Nvidia - Install akmod nvidia drivers"
       "Quit")

while true; do
	select item in "${items[@]}"
	do 
    case $REPLY in
			# ISSUE: RPM Fusion needs a reboot and further setup to unlock it from a release version on silverblue
		1)	echo "Enabling RPM Fusion!"
			sleep 1
			sudo rpm-ostree install \
			    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
			    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
			echo "RPM Fusion enabled. You must reboot for the changes to take effect!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		2)	echo "Upgrading the system components!"
			sleep 1
			rpm-ostree status
			rpm-ostree upgrade
			# FEATURE: Needs a check when no updates are done to not suggest a reboot
			echo "System upgrade complete. A reboot is recommended at this stage!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		3)	echo "Enabling automatic update checking!"
			sleep 1
			sudo sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=check/' /etc/rpm-ostreed.conf
			rpm-ostree reload
			sudo systemctl enable rpm-ostreed-automatic.timer --now
			echo "Automatic update checking is now enabled!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		4)	echo "Enabling flathub repo and updating flatpaks!"
			sleep 1
			flatpak update
			flatpak remote-delete flathub --force
			flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
			flatpak update --appstream
			flatpak update -y
			echo "Flathub enabled and flatpaks updated!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		5)	echo "Installing flatpaks!"
			sleep 1
			PACKAGES=$(< ./flatpak-packages.txt)
			for PKG in $PACKAGES; do
				flatpak install --user flathub $PKG
			done
			echo "All flatpaks installed!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		6)	echo "Setting up a Fedora toolbox.."
			sleep 1
			toolbox create -y fedora
			toolbox run -c fedora sudo tee -a /etc/dnf/dnf.conf > /dev/null << EOF
max_parallel_downloads=10
fastestmirror=True
EOF
			toolbox run -c fedora sudo dnf upgrade -y
			toolbox run -c fedora sudo dnf install -y neovim exa lolcat tldr fastfetch xeyes
			toolbox list
			echo "Fedora toolbox is ready!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		# FEATURE: Add checks
		7)	echo "Speeding up performance, boot and shutdown"
			sleep 1
			echo "Setting grub timeout to 2 seconds!"
			sudo sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=2/' /etc/default/grub
			echo "Setting nomitigations, noplymouth, nowatchdog"
			rpm-ostree kargs --append='rd.plymouth=0 plymouth.enable=0 mitigations=off nowatchdog libahci.ignore_sss=1'
			sudo sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
			sudo sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf
			echo "Disabling services.."
			sudo systemctl disable NetworkManager-wait-online.service
			sudo systemctl disable ModemManager.service
			echo "Applying medium power saving to disk devices"
			sudo cp -fv ./udev/hd_power_save.rules /etc/udev/rules.d/hd_power_save.rules
			echo "Applying i/o scheduler [none] to SSD devices"
			sudo cp -fv ./udev/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules
			echo "Applying vm.max_map_count tweak"
			echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.conf
			echo "Applied all changes!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		8)	echo "Installing intel-undervolt"
			sleep 1
			rpm-ostree install intel-undervolt
			echo "intel-undervolt is installed. A reboot is required."
			echo ">  to configure, edit /etc/intel-undervolt.conf"
			echo ">  to apply-on-boot, systemctl enable intel-undervolt.service"
			echo ">  intel-undervolt read  # displays current values"
			echo ">  intel-undervolt measure  # displays power draw!"
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		9)	echo "Installing Nvidia drivers!"; sleep 1
			sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia
			sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
			echo "Nvidia drivers are now installed!"
			echo "Please restart your system."
			read -p "Press any key to continue... " -n1 -s
			break
			;;
		10)
			echo "We are done! Enjoy!"
			exit 0
			;;
	esac
	done
done
