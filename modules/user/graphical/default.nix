{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./applications
    ./shared.nix
  ];
}
