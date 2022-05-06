{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.graphical;
in {
  options.m.graphical.applications = {
    enable = mkOption {
      type = types.bool;
      description = "Enable graphical applications";
    };
  };

  config = {
    home.packages = with pkgs; [
      discord
      wdisplays

      flameshot
      libsixel
    ];

    xdg.configFile = {
      "discord/settings.json" = {
        text = ''
          {
            "SKIP_HOST_UPDATE": true
          }
        '';
      };
    };
  };
}
