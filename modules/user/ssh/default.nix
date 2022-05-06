{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.ssh;
in {
  options.m.ssh = {
    enable = mkOption {
      description = "Enable ssh";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.ssh = {
      enable = true;
    };
  };
}
