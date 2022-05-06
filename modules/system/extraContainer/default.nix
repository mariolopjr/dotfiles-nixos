{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  options.m.extraContainer = {
    enable = mkOption {
      description = "Enable extra-container";
      type = types.bool;
      default = false;
    };
  };
}
