#
# Very janky way of declaring all flatpaks used
# Might cause issues on new system installs
# Only use when you know what you're doing
#

{ pkgs, ... }:

{
  services.flatpak.enable = true;
  system.activationScripts = {
    flatpak.text =
      ''
        flatpaks=(
                  "sh.ppy.osu"
                  "io.github.shiftey.Desktop"
                  "com.jgraph.drawio.desktop"
                  "com.jgraph.drawio.desktop"
                  "com.github.flxzt.rnote"
                  "com.github.tchx84.Flatseal"
                  "com.leinardi.gst"
                  "org.gnome.Snapshot"
                  "org.nickvision.tubeconverter"
                  "com.getpostman.Postman"
                  #"com.google.Chrome"
                  #"com.microsoft.Edge"
                  #"io.github.amit9838.weather"
                  #"ir.imansalmani.IPlan"
                  #"md.obsidian.Obsidian"
                  #"io.github.jonmagon.kdiskmark"
                  #"org.gnome.Logs"
                  #"org.mozilla.firefox"
                  #"org.qbittorrent.qBittorrent"
                  #"org.signal.Signal"
                  #"org.telegram.desktop"
                  #"com.mattjakeman.ExtensionManager"
                  #"org.libreoffice.LibreOffice"
                  #"io.github.Figma_Linux.figma_linux"
        )

        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        for package in ''${flatpaks[*]}; do
          check=$(${pkgs.flatpak}/bin/flatpak list --app | ${pkgs.gnugrep}/bin/grep $package)
          if [[ -z "$check" ]] then
            ${pkgs.flatpak}/bin/flatpak install -y flathub $package
          fi
        done

        installed=($(${pkgs.flatpak}/bin/flatpak list --app | ${pkgs.gawk}/bin/awk -F$'\t*' '{$1=$3=$4=$5=""; print $0}'))

        for remove in ''${installed[*]}; do
          if [[ ! " ''${flatpaks[*]} " =~ " ''${remove} " ]]; then
            ${pkgs.flatpak}/bin/flatpak uninstall -y $remove
            ${pkgs.flatpak}/bin/flatpak uninstall -y --unused
          fi
        done
      '';
  };
}
