{
  pkgs,
  user,
  lib,
  inputs,
  ...
}: let
  secretsInput = builtins.toString inputs.mySsecrets;
  email = inputs.nixpkgs-unstable.lib.strings.trim (builtins.readFile "${secretsInput}/github/email.txt");
  username = inputs.nixpkgs-unstable.lib.strings.trim (builtins.readFile "${secretsInput}/github/username.txt");
in
  lib.mkIf (user == "akib") {
    programs.git = {
      enable = true;
      package = pkgs.git;
      userName = username;
      extraConfig = {
        user = {
          userEmail = email;
          signingkey = email;
        };
        commit = {
          gpgSign = true;
        };
      };
    };
  }
