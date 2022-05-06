{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.gpg;
in {
  options.m.gpg = {
    enable = mkOption {
      description = "Enable gpg";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      pinentry-gnome
    ];

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      enableExtraSocket = true;
      enableScDaemon = false;
    };
  };
}
