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
		6)	# ERROR: WITH ENTERING TOOLBOX
			echo "Setting up a Fedora toolbox.."
			sleep 1
			toolbox create -y fedora
			toolbox enter fedora
			echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
			echo "fastestmirror=True" >> /etc/dnf/dnf.conf
			sudo dnf upgrade -y
			sudo dnf install -y htop btop lolcat neofetch xeyes
			exit
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
			rpm-ostree kargs --append='rd.plymouth=0 plymouth.enable=0 mitigations=off nowatchdog'
			sudo sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
			sudo sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf
			echo "Disabling NetworkManager-wait-online.service"
			sudo systemctl disable NetworkManager-wait-online.service
			echo "Applying medium power saving to disk devices"
			echo "ACTION==\"add\", SUBSYSTEM==\"scsi_host\", KERNEL==\"host*\", ATTR{link_power_management_policy}=\"med_power_with_dipm\"" | sudo tee /etc/udev/rules.d/hd_power_save.rules
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
		9)	echo "Installing Nvidia drivers!"
			sleep 1
			echo "This feature is not available yet!"
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
