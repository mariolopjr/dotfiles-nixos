{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.graphical.wayland;
in {
  options.m.graphical.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        gtkUsePortal = true;
      };
    };
  };
}
