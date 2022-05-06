{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.graphical.xorg;
in {
  options.m.graphical.xorg = {
    enable = mkOption {
      description = "Enable xserver.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (config.m.graphical.enable && cfg.enable) {
    services.xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
        };
      };

      displayManager.startx.enable = true;
    };
  };
}
