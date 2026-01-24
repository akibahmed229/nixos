{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.git;
in {
  options.hm.git = {
    enable = mkEnableOption "Git configuration";

    useSopsTemplate = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to include the git-user.conf template from Sops.";
    };

    signCommits = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to GPG sign commits by default.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.diff-so-fancy];

    programs.git = {
      enable = true;
      package = pkgs.git;

      # Dynamically include the sops template if enabled
      includes = optionals (cfg.useSopsTemplate && config.sops.templates ? "git-user.conf") [
        {path = config.sops.templates."git-user.conf".path;}
      ];

      settings = {
        # Core & Init
        init.defaultBranch = "main";
        core = {
          compression = 9;
          whitespace = "error";
          preloadindex = true;
        };

        # Signing
        commit.gpgSign = cfg.signCommits;

        # Pushing & Pulling
        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
          gpgSign = false; # Often fails on remotes that don't support it
        };
        pull.rebase = true;
        rebase.autoStash = true;

        # Diffing (using diff-so-fancy)
        diff = {
          context = 3;
          renames = "copies";
          interHunkContext = 10;
        };
        interactive.diffFilter = "diff-so-fancy --patch";
        pager.diff = "diff-so-fancy | $PAGER";

        # Logging & Status
        log = {
          abbrevCommit = true;
          graphColors = "blue,yellow,cyan,magenta,green,red";
        };
        status = {
          branch = true;
          short = true;
          showStash = true;
          showUntrackedFiles = "all";
        };

        # URL Shorteners
        url = {
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
        };

        # Colors (Moved to separate block for readability)
        color = {
          blame = {
            highlightRecent = "black bold,1 year ago,white,1 month ago,default,7 days ago,blue";
          };
          branch = {
            current = "magenta";
            local = "default";
            remote = "yellow";
            upstream = "green";
            plain = "blue";
          };
          diff = {
            meta = "black bold";
            frag = "magenta";
            context = "white";
            whitespace = "yellow reverse";
          };
        };
      };
    };
  };
}
