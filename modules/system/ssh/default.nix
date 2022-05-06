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

    type = mkOption {
      description = "SSH client or server";
      type = types.enum ["client" "server"];
      default = "client";
    };

    authorizedKeys = mkOption {
      description = "Authorized ssh keys";
      type = types.listOf types.str;
    };

    initrdKeys = mkOption {
      description = "SSH key for initrd";
      type = types.listOf types.str;
    };

    ports = mkOption {
      default = [22];
      type = with types; listOf port;
      description = "SSH ports";
    };

    firewall = mkOption {
      type = types.enum ["world" "wg"];
      description = "Open firewall to everyone or wireguard";
    };

    hostKeyAge = mkOption {
      type = types.path;
      description = "Encrypted SSH host key file";
    };

    hostKeyPath = mkOption {
      default = "/etc/ssh/host_private_key";
      type = types.path;
      description = "Path to decrypted SSH key";
    };
  };

  config = mkMerge [
    (mkIf (cfg.type == "client") {
      programs.ssh.startAgent = true;
    })
    (mkIf (cfg.type == "server") (mkMerge [
      (mkIf (cfg.firewall == "world") {
        services.openssh.openFirewall = true;
      })
      (
        let
          wgconf = config.m.wireguard;
        in
          mkIf
          (cfg.firewall == "wg" && (assertMsg wgconf.enable "Wireguard must be enabled for wireguard ssh firewall"))
          {
            services.openssh.openFirewall = false;
            networking.firewall.interfaces.${wgconf.interface}.allowedTCPPorts = cfg.ports;
          }
      )

      {
        services.openssh = {
          enable = true;
          ports = cfg.ports;
          hostKeys = [];
          extraConfig = ''
            HostKey ${cfg.hostKeyPath}
          '';
        };

        # terminfo's for correct formatting of ssh terminal
        environment.systemPackages = [
          pkgs.kitty.terminfo
        ];

        age.secrets.ssh_host_private_key = {
          file = cfg.hostKeyAge;
          path = cfg.hostKeyPath;
          mode = "600";
        };

        users.users.root = {
          openssh.authorizedKeys.keys = cfg.authorizedKeys;
        };
      }
    ]))
  ];
}
