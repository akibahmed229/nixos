{pkgs, ...}: {
  # --- Prompt setup (Oh My Posh) ---
  oh-my-posh = {
    enable = true;
    package = pkgs.oh-my-posh;
    enableBashIntegration = true;
    enableZshIntegration = true;
    useTheme = "gruvbox";
  };
}
