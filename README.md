# dotfiles
My personal dotfiles. Can bootstrap my NixOS and Nix systems. At the moment, only supports my desktop (monolith) and is not functional (just started).

## Bootstrap
sudo -i
sh bootstrap.sh
cp ./configuration.nix /mnt/etc/nixos/configuration.nix
cp ./monolith.nix /mnt/etc/nixos/system.nix
nixos-generate-config --root /mnt
nixos-install

## Install
if error:
`mktemp: failed to create directory via template ‘/mnt/tmp.kYftcsVwDN/initrd-secrets.XXXXXXXXXX’: No such file or directory`
nixos-enter
nixos-install --root /
exit
reboot
