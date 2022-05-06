{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.spotify;
in {
  options.m.spotify = {
    enable = mkOption {
      description = "Enable spotify";
      type = types.bool;
      default = false;
    };

    spotifyd = {
      enable = mkOption {
        description = "Enable spotifyd daemon";
        type = types.bool;
        default = false;
      };

      configFile = mkOption {
        description = ''
          Config file for spotifyd
          (expects age encrypted file for homeage)
        '';
        type = types.path;
        default = ./spotifydconfig.toml.age;
      };
    };

    config = mkIf (cfg.enable) {
      xdg.configFile = {};

      homeage.file = {
        "spotifydconfig" = {
          source = cfg.secretKey;
          decryptPath = "spotifyd/config.toml";
          lnOnStartup = [
            "${config.xdg.configHome}/github/secretkey.json"
          ];
        };
      };
    };
  };
}
