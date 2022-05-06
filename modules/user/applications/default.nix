{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.m.applications;
in {
  options.m.applications = {
    enable = mkOption {
      description = "Enable a set of common applications";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.packages = with pkgs; [
      # Security
      bitwarden
      agenix-cli

      # Notes
      obsidian

      # ssh mount
      sshfs

      # Deployment
      deploy-rs

      # CLI apps
      nnn
    #   grit
      timewarrior

      # Productivity Suite
      pdftk

      # Video
      youtube-dl

      # Bookmarks
    #   buku

      # Fonts
      (nerdfonts.override {fonts = ["VictorMono"];})
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # Calculator
      bc
      bitwise

      # Utilities
      alejandra
    ];

    fonts.fontconfig.enable = true;

    programs.taskwarrior = {
      enable = true;
    };

    # Taskwarrior + timewarrior integration: https://timewarrior.net/docs/taskwarrior/
    home.activation = {
      tasktime = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${config.xdg.dataHome}/task/hooks/
        $DRY_RUN_CMD rm -rf ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
        $DRY_RUN_CMD cp ${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior ${config.xdg.dataHome}/task/hooks/
        PYTHON3="#!${pkgs.python3}/bin/python3"
        $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i "1s@.*@$PYTHON3@" ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
        $DRY_RUN_CMD chmod +x ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
      '';
    };

    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        vo = "gpu";
        hwdec = "auto-safe";
        ytdl-format = "ytdl-format=bestvideo[height<=?1920][fps<=?30][vcodec!=?vp9]+bestaudio/best";
      };
    };
  };
}
