{pkgs, unstable, ...}:
{
  home.packages = with pkgs; [
    (pkgs.discord.override {
     withOpenASAR = true;
     withVencord = true;
     vencord = (pkgs.vencord.overrideAttrs {
         src = fetchFromGitHub {
         owner = "Vendicated";
         repo = "Vencord";
         rev = "70943455161031d63a4481249d14833afe94f5a5";
         hash = "sha256-i/n7qPQ/dloLUYR6sj2fPJnvvL80/OQC3s6sOqhu2dQ=";
         };
         });
     })
  ];

# Overlay pulls latest version of Discord
#  nixpkgs.overlays = [                          
 #   (self: super: {
#     discord = super.discord.overrideAttrs (
#         _: { src = builtins.fetchTarball {
#         url = #"https://discord.com/api/download?platform=linux&format=tar.gz";
     #    sha256 = "0yzgkzb0200w9qigigmb84q4icnpm2hj4jg400payz7igxk95kqk";
 #        };
#         }
 #        );
#     })
#  ];
}
