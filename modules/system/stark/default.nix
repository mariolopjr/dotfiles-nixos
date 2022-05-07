{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.stark;
in {
  options.m.stark = {
    enable = mkOption {
      description = "Whether to enable stark settings. Also tags as stark for user settings";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {};
}
