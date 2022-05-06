{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./system.nix
    ];

  # Boot
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

  # zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Networking
  time.timeZone = "America/New_York";
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # DE
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # User accounts
  users.users.mario = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Install packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Tools
    bottom
    fish
    neovim

    # Applications
    firefox
  ];

  # Additional Services
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
