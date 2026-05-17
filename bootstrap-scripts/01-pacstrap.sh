set -euxo pipefail

pacstrap -K /mnt base linux-zen linux-firmware sudo networkmanager
genfstab -U /mnt >> /mnt/etc/fstab


echo "chroot command: \# arch-chroot /mnt"
