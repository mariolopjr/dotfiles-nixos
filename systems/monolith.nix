{ config, pkgs, ... }:

# Configuration specific to monolith
{
  networking.hostName = "monolith";

  # Enable nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
}
