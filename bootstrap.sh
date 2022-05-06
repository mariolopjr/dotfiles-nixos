## Script based off of easy-arch script: https://github.com/classy-giraffe/easy-arch

# Cleaning the TTY.
clear

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# Setting up a password for the LUKS Container (function).
password_selector () {
    read -r -s -p "Insert password for the LUKS container (you're not going to see the password): " password
    if [ -z "$password" ]; then
        print "You need to enter a password for the LUKS Container in order to continue."
        password_selector
    fi
    dd if=/dev/urandom of=./key.bin bs=1024 count=4 &>/dev/null

    echo -n "$password" | cryptsetup luksFormat "$CRYPTROOT" -d -
    echo -n "$password" | cryptsetup luksAddKey "$CRYPTROOT" key.bin -d -
    cryptsetup open "$CRYPTROOT" cryptroot -d key.bin
    BTRFS="/dev/mapper/cryptroot"
}

# Selecting the target for the installation.
print "Welcome to easy-nixos, a script made in order to simplify the process of installing NixOS."
PS3="Please select the disk where NixOS is going to be installed: "
select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");
do
    DISK=$ENTRY
    print "Installing NixOS on $DISK."
    break
done

# Deleting old partition scheme.
read -r -p "This will delete the current partition table on $DISK. Do you agree [y/N]? " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    print "Wiping $DISK."
    wipefs -af "$DISK" &>/dev/null
    sgdisk -Zo "$DISK" &>/dev/null
else
    print "Quitting."
    exit
fi

# Creating a new partition scheme.
print "Creating the partitions on $DISK."
parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart CRYPTROOT 513MiB 100% \

ESP="/dev/disk/by-partlabel/ESP"
CRYPTROOT="/dev/disk/by-partlabel/CRYPTROOT"

# Informing the Kernel of the changes.
print "Informing the Kernel about the disk changes."
partprobe "$DISK"

# Formatting the ESP as FAT32.
print "Formatting the EFI Partition as FAT32."
mkfs.fat -F 32 $ESP &>/dev/null

# Creating a LUKS Container for the root partition.
print "Creating LUKS Container for the root partition."
password_selector

# Formatting the LUKS Container as BTRFS.
print "Formatting the LUKS container as BTRFS."
mkfs.btrfs $BTRFS
mount $BTRFS /mnt

# Creating BTRFS subvolumes.
print "Creating BTRFS subvolumes."
for volume in @ @home @root @var_log @nix
do
    btrfs su cr /mnt/$volume
done

# Mounting the newly created subvolumes.
umount /mnt
print "Mounting the newly created subvolumes."
mount -o ssd,noatime,compress-force=zstd:3,discard=async,subvol=@ $BTRFS /mnt
mkdir -p /mnt/{nix,home,root,var/log,boot}
mount -o ssd,noatime,compress-force=zstd:3,discard=async,subvol=@nix $BTRFS /mnt/nix
mount -o ssd,noatime,compress-force=zstd:3,discard=async,subvol=@home $BTRFS /mnt/home
mount -o ssd,noatime,compress-force=zstd:3,discard=async,subvol=@root $BTRFS /mnt/root
mount -o ssd,noatime,compress-force=zstd:3,discard=async,subvol=@var_log $BTRFS /mnt/var/log
chattr +C /mnt/var/log
mount $ESP /mnt/boot/

# Copy over LUKS encryption key
mkdir -p /mnt/etc/secrets/initrd
cp key.bin /mnt/etc/secrets/initrd
chmod 000 /mnt/etc/secrets/initrd/key.bin
