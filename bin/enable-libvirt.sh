#!/bin/bash

message_virt_not_supported="Your CPU does not support hardware virtualization (svm or vmx)."
grep -E "svm|vmx" /proc/cpuinfo > /dev/null
if [[ $? -ne 0 ]]; then
  echo $message_virt_not_supported
  exit 1
fi

. /etc/os-release
if [[ "${ID}" == "arch" ]]; then
  sudo pacman -Syu qemu-desktop virt-manager virt-viewer dnsmasq iproute2 iptables ebtables
elif [[ "$ID" == "ubuntu" ]]; then
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
elif [[ "$ID" == "fedora" ]]; then
    sudo dnf install @virtualization
else
    echo "Unsupported OS: $ID"
    exit 1
fi

sudo systemctl enable --now libvirtd.service
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)
sudo sed -i 's/#unix_sock_group/unix_sock_group/;s/#unix_sock_rw_perms/unix_sock_rw_perms/' /etc/libvirt/libvirtd.conf
sudo systemctl restart libvirtd.service
sudo systemctl status libvirtd

echo "Please log out and log back in to apply the group changes."
