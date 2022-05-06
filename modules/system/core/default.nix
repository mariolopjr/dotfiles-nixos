{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.core;
in {
  options.m.core = {
    enable = mkOption {
      description = "Enable core options";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/New_York";

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Nix search paths/registries from:
    # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/166d6ebd9f0de03afc98060ac92cba9c71cfe550/lib/options.nix
    # Context thread: https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/166d6ebd9f0de03afc98060ac92cba9c71cfe550/lib/options.nix
    nix = let
      flakes =
        filterAttrs
        (name: value: value ? outputs)
        inputs;
      flakesWithPkgs =
        filterAttrs
        (name: value:
          value.outputs ? legacyPackages || value.outputs ? packages)
        flakes;
      nixRegistry = builtins.mapAttrs (name: v: {flake = v;}) flakes;
    in {
      registry = nixRegistry;
      nixPath =
        mapAttrsToList
        (name: _: "${name}=/etc/nix/inputs/${name}")
        flakesWithPkgs;
      package = pkgs.nixUnstable;
      gc = {
        persistent = true;
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
    };

    environment = {
      sessionVariables = {
        EDITOR = "nvim";
      };
      etc =
        mapAttrs'
        (name: value: {
          name = "nix/inputs/${name}";
          value = {source = value.outPath;};
        })
        inputs;

      shells = [pkgs.fish pkgs.bash];
      # ZSH completions
    #   pathsToLink = ["/share/zsh"];
      systemPackages = with pkgs; [
        # Shells and Terminals
        fish
        kitty

        # Misc
        git
        # git-delta # not avail in nix
        ncdu
        exa
        fd
        fzf
        bat
        ddcutil
        gping
        inxi
        usbutils
        dnsutils
        macchina
        unzip

        # Filesystems
        btrfs-progs

        # Secrets
        rage
        agenix-cli

        # Security
        # apparmor
        firejail
        opensnitch

        # Processors
        jq
        gawk
        gnused

        # Downloaders
        curl

        # System monitors
        bottom
        acpi
        pstree

        # Nix tools
        patchelf
        nix-index
        nix-tree
        manix

        # Text editor
        neovim

        # Scripts
        scripts.sysTools

        man-pages
        man-pages-posix
      ];
    };

    security.sudo.extraConfig = "Defaults env_reset,timestamp_timeout=5";
    security.sudo.execWheelOnly = true;

    documentation = {
      enable = true;
      dev.enable = true;
      man = {
        enable = true;
        generateCaches = true;
      };
      info.enable = true;
      nixos.enable = true;
    };
  };
}
