{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./core.nix
    ./libreoffice.nix
  ];
}
