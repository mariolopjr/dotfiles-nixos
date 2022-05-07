{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./connectivity
    ./boot
    (import ./core {inherit inputs;})
    ./gnome
    ./nvidia
    ./networking
    ./graphical
    ./ssh
    ./secrets
    ./stark
  ];
}
