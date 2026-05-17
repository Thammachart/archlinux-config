set -e

BOOT_PAR=$1
PAR=$2
BTRFS_O=noatime,commit=120,compress=zstd:1
MAPPER_NAME=crypted-archlinux
MAP=/dev/mapper/$MAPPER_NAME

cryptsetup luksFormat \
	--type luks2 \
	--cipher aes-xts-plain64 \
	--hash blake2b-512 \
	--iter-time 2000 \
	--key-size 512 \
	--pbkdf argon2id \
	--use-urandom \
	--verify-passphrase \
	$PAR
cryptsetup open $PAR $MAPPER_NAME

mkfs.btrfs -L archlinux $MAP

mount $MAP /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@root
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@.snapshots
btrfs su cr /mnt/@data

chattr +C /mnt/@var

umount /mnt

mount -o $BTRFS_O,subvol=@ $MAP /mnt
mkdir /mnt/{home,root,var,opt,tmp,.snapshots,boot,data}

mount -o $BTRFS_O,subvol=@home $MAP /mnt/home
mount -o $BTRFS_O,subvol=@root $MAP /mnt/root
mount -o $BTRFS_O,subvol=@var $MAP /mnt/var
mount -o $BTRFS_O,subvol=@opt $MAP /mnt/opt
mount -o $BTRFS_O,subvol=@tmp $MAP /mnt/tmp
mount -o $BTRFS_O,subvol=@.snapshots $MAP /mnt/.snapshots
mount -o $BTRFS_O,subvol=@data $MAP /mnt/data

# mount esp
mount -o defaults,noatime,umask=0077,dmask=022,fmask=033 $BOOT_PAR /mnt/boot
