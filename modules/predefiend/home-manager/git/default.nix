{
  pkgs,
  user,
  lib,
  config,
  ...
}:
lib.mkIf (user == "akib") {
  home.packages = with pkgs; [diff-so-fancy];
  programs.git = {
    enable = true;
    package = pkgs.git;
    includes = [
      {inherit (config.sops.templates."git-user.conf") path;}
    ];
    settings = {
      commit = {
        gpgSign = true;
      };
      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };

      init = {
        defaultBranch = "main";
      };

      diff = {
        context = 3; # less context in diffs
        renames = "copies"; # detect copies as renames in diffs
        interHunkContext = 10; # merge near hunks in diffs
      };

      log = {
        abbrevCommit = true; # short commits
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };

      status = {
        branch = true;
        short = true;
        showStash = true;
        showUntrackedFiles = "all"; # show individual untracked files
      };

      pager = {
        branch = false; # no need to use pager for git branch
        diff = "diff-so-fancy | $PAGER"; # diff-so-fancy as diff pager
      };

      push = {
        autoSetupRemote = true; # easier to push new branches
        default = "current"; # push only current branch by default
        followTags = true; # push also tags
        gpgSign = false; # my remotes doesn't support sign pushes
      };

      pull = {
        rebase = true;
      };

      submodule = {
        fetchJobs = 16;
      };

      rebase = {
        autoStash = true;
      };

      # Colors
      "color \"blame\"" = {
        highlightRecent = "black bold,1 year ago,white,1 month ago,default,7 days ago,blue";
      };

      "color \"branch\"" = {
        current = "magenta";
        local = "default";
        remote = "yellow";
        upstream = "green";
        plain = "blue";
      };

      "color \"diff\"" = {
        meta = "black bold";
        frag = "magenta";
        context = "white";
        whitespace = "yellow reverse";
      };

      interactive = {
        diffFilter = "diff-so-fancy --patch";
        singlekey = true;
      };

      "url \"git@github.com:\"" = {
        insteadOf = "gh:";
      };
      "url \"git@gitlab.com:\"" = {
        insteadOf = "gl:";
      };
    };
  };
}
