{
  pkgs,
  user,
  lib,
  ...
}:
lib.mkIf (user == "akib") {
  programs.git = {
    enable = true;
    package = pkgs.git;
    userName = "akibahmed229";
    userEmail = "akib4418@gmail.com";
    extraConfig = {
      user = {
        signingkey = "akib4418@gmail.com";
      };
      commit = {
        gpgSign = true;
      };
    };
  };
}
