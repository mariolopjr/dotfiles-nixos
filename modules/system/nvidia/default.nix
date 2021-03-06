{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.nvidia;
in {
  options.m.nvidia = {
    enable = mkOption {
      description = "Use nvidia driver";
      type = types.bool;
      default = false;
    };

    enable-beta = mkOption {
      description = "Use nvidia-beta driver";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    hardware.nvidia.package =
      mkIf cfg.enable-beta config.boot.kernelPackages.nvidiaPackages.beta;

    environment.systemPackages = with pkgs;
      [
        "nvidia-x11"
        "nvidia-settings"
      ];
  };
}
