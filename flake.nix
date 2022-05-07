{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-emoji.url = "nixpkgs/nixos-21.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deploy-rs = {
    #   url = "github:serokell/deploy-rs";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm-nix = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeage = {
      url = "github:jordanisaacs/homeage/activatecheck";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/mariolopjr/secrets.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-emoji,
    # deploy-rs,
    agenix,
    microvm-nix,
    secrets,
    home-manager,
    nur,
    homeage,
    extra-container,
    ...
  } @inputs: let
    inherit (nixpkgs) lib;

    util = import ./lib {
      inherit system pkgs home-manager lib inputs;
    };

    scripts = import ./scripts {
      inherit pkgs lib;
    };

    inherit (util) user;
    inherit (util) host;

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    # Recursively merge (semi-naive)
    # https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
    recursiveMerge = with lib;
      attrList: let
        f = attrPath:
          zipAttrsWith (
            n: values:
              if tail values == []
              then head values
              else if all isList values
              then unique (concatLists values)
              else if all isAttrs values
              then f (attrPath ++ [n]) values
              else last values
          );
      in
        f [] attrList;

    system = "x86_64-linux";

    authorizedKeys = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwoOtZXVOFU7QcKQlW+M+DSBjKZn/tu098sJZwCWuvE mario@techmunchies.net
    '';

    authorizedKeyFiles = pkgs.writeTextFile {
      name = "authorizedKeys";
      text = authorizedKeys;
    };

    defaultClientConfig = {
      core.enable = true;
      boot.type = "encrypted-efi";
      gnome = {
        enable = true;
      };
      connectivity = {
        bluetooth.enable = true;
        sound.enable = true;
        printing.enable = true;
      };
      networking = {
        firewall = {
          enable = true;
          allowKdeconnect = false;
        };
        networkmanager.enable = true;
      };
      graphical = {
        enable = true;
        xorg.enable = false;
        wayland = {
          enable = true;
        };
      };
      nvidia = {
        enable = true;
      };
      ssh = {
        enable = true;
        type = "client";
      };
      extraContainer.enable = true;
    };

    starkConfig = recursiveMerge [
      defaultClientConfig
      {
        stark.enable = true;
        networking = {
          interfaces = ["enp6s0" "wlp5s0"];
        };
        secrets.identityPaths = [secrets.age.system.stark.privateKeyPath];
      }
    ];

    defaultUser = {
      name = "mario";
      groups = ["wheel"];
      uid = 1000;
      shell = pkgs.fish;
    };

    defaultUsers = [defaultUser];

    defaultDesktopUser =
      defaultUser
      // {
        groups = defaultUser.groups ++ ["networkmanager" "video" "libvirtd"];
      };
  in {
    # installMedia = {
    #   kde = host.mkISO {
    #     name = "nixos";
    #     kernelPackage = pkgs.linuxPackages_latest;
    #     initrdMods = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "nvme" "usbhid"];
    #     kernelMods = ["kvm-intel" "kvm-amd"];
    #     kernelParams = [];
    #     systemConfig = {};
    #   };
    # };

    homeManagerConfigurations = {
      m = user.mkHMUser {
        userConfig = {
          graphical = {
            applications = {
              enable = true;
              libreoffice.enable = true;
            };
          };
          applications.enable = true;
          gpg.enable = true;
          git = {
            enable = true;
            allowedSignerFile = builtins.toString authorizedKeyFiles;
          };
          fish.enable = true;
          ssh.enable = true;
          direnv.enable = true;
        };
        username = "mario";
      };
    };

    nixosConfigurations = {
      stark = host.mkHost {
        name = "stark";
        kernelPackage = pkgs.linuxPackages_latest;
        initrdMods = ["ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod"]; # vmware config, will change for actual desktop
        kernelMods = ["kvm-amd"];
        kernelParams = [];
        kernelPatches = [];
        systemConfig = starkConfig;
        users = defaultUsers;
        cpuCores = 12; # 6 cores, 12 threads
        stateVersion = "21.11";
      };
    };

    # checks =
    #   builtins.mapAttrs
    #   (system: deployLib: deployLib.deployChecks self.deploy)
    #   deploy-rs.lib;
  };
}
