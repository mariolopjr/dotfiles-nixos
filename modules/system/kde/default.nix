{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.mario.kde;
in {
  options.mario.kde = {
    enable = mkOption {
      description = "Enable KDE programs";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs;
      [
      ]

    programs = {
      # nothing
    };

    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
  };
}
