{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.boot;
in {
  options.m.boot = {
    type = mkOption {
      description = "Type of boot. Default encrypted-efi";
      default = null;
      type = types.enum ["encrypted-efi"];
    };
  };

  config = let
    bootConfig = mkMerge [
      (mkIf (cfg.type == "encrypted-efi") {
        boot.loader = {
          efi.canTouchEfiVariables = true;

          systemd-boot = {
            enable = true;
            configurationLimit = 20;
          };
        };

        boot.initrd = {
          luks.devices."cryptroot" = {
            device = "/dev/disk/by-partlabel/CRYPTROOT";
            keyFile = "/key.bin";
            allowDiscards = true;
          };
          secrets = {
            "key.bin" = "/etc/secrets/initrd/key.bin";
          };
        };

        fileSystems."/" = {
          device = "/dev/disk/by-label/BTRFSROOT";
          fsType = "btrfs";
          options = [ "ssd,noatime,compress-force=zstd:3,discard=async,subvol=@" ];
        };

        fileSystems."/nix" = {
          device = "/dev/disk/by-label/BTRFSROOT";
          fsType = "btrfs";
          options = [ "ssd,noatime,compress-force=zstd:3,discard=async,subvol=@nix" ];
        };

        fileSystems."/home" = {
          device = "/dev/disk/by-label/BTRFSROOT";
          fsType = "btrfs";
          options = [ "ssd,noatime,compress-force=zstd:3,discard=async,subvol=@home" ];
        };

        fileSystems."/root" = {
          device = "/dev/disk/by-label/BTRFSROOT";
          fsType = "btrfs";
          options = [ "ssd,noatime,compress-force=zstd:3,discard=async,subvol=@root" ];
        };

        fileSystems."/var/log" = {
          device = "/dev/disk/by-label/BTRFSROOT";
          fsType = "btrfs";
          options = [ "ssd,noatime,compress-force=zstd:3,discard=async,subvol=@var_log" ];
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-partlabel/ESP";
          fsType = "vfat";
        };

        zramSwap = {
          enable = true;
          algorithm = "zstd";
        };
      })
    ];
  in
    bootConfig;
}
