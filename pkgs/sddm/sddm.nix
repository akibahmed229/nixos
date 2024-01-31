{ pkgs
, imgLink ? { url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/Photo-of-Valley.jpg"; sha256 = "sha256-86ja7yfSdMAaFFdfDqQS8Yq5yjZjXPMLTIgExcnzbXc="; }
, ...
}:

let
  image =
    if imgLink.url == "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/Photo-of-Valley.jpg" then
      pkgs.fetchurl
        {
          url = imgLink.url;
          sha256 = imgLink.sha256;
        }
    else
      pkgs.fetchurl
        {
          url = imgLink.url;
          sha256 = imgLink.sha256;
        };
in
pkgs.stdenv.mkDerivation {
  name = "sddm-theme";
  src = pkgs.fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-sugar-dark";
    rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
    sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
  };

  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
    cd $out/
    rm Background.jpg
    cp -r ${image} new.jpg
    cp -r new.jpg $out/Background.jpg
  '';

  meta = with pkgs.lib; {
    description = "A dark theme for SDDM";
    homepage = "https://github.com/MarianArlt/sddm-sugar-dark";
    platforms = platforms.linux;
    maintainers = [ maintainers.akibahmed229 ];
    license = licenses.gpl3;
  };
}
