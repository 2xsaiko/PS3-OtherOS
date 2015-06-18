#!/bin/sh

if [ $# -lt 1 ]; then
	echo "usage: $0 <Linux kernel path>" >&2
	exit 1
fi

umount /var/petitboot/mnt/sda1

echo "Unloading USB drivers ..."

rmmod btusb
rmmod bluetooth
rmmod usbhid
rmmod hid
rmmod ums_usbat
rmmod ums_sddr55
rmmod ums_sddr09
rmmod ums_karma
rmmod ums_jumpshot
rmmod ums_isd200
rmmod ums_freecom
rmmod ums_datafab
rmmod ums_cypress
rmmod ums_alauda
rmmod usb_storage
rmmod ohci_hcd
rmmod ehci_hcd
rmmod usbcore

echo "Booting Linux kernel '$1' ..."

kexec -l $1 --append="root=/dev/ps3vflashh2"
sync
swapoff -a
kexec -e

