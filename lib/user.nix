{
  pkgs,
  home-manager,
  lib,
  system,
  # overlays,
  ...
}:
with builtins; {
  mkHMUser = {
    userConfig,
    username,
  }:
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs;
      stateVersion = "21.05";
      configuration = let
        trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
        machineData =
          if trySettings.success
          then trySettings.value
          else {};

        machineModule = {
          pkgs,
          config,
          lib,
          ...
        }: {
          options.machineData = lib.mkOption {
            default = {};
            description = "Settings passed from nixos system configuration. If not present will be empty";
          };

          config.machineData = machineData;
        };
      in {
        m = userConfig;

        # nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;

        systemd.user.startServices = true;
        home.stateVersion = "21.05";
        home.username = username;
        home.homeDirectory = "/home/${username}";

        imports = [../modules/user machineModule pkgs.homeage.homeManagerModules.homeage];
      };
      homeDirectory = "/home/${username}";
    };

  mkSystemUser = {
    name,
    groups,
    uid,
    shell,
    ...
  }: {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      extraGroups = groups;
      uid = uid;
      initialPassword = "password";
      shell = shell;
    };
  };
}
