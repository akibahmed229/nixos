{pkgs, ...}: {
  programs.gemini-cli = {
    enable = true;
    package = pkgs.gemini-cli;
    # defaultModel = "gemini-2.5-flash";
    settings = {
      tools = {
        autoAccept = true;
        shell = {
          showColor = true;
        };
      };

      general = {
        previewFeatures = true;
        preferredEditor = "nvim";
        vimMode = true;
      };

      ui = {
        theme = "Default";
        showLineNumbers = true;
        useFullWidth = true;
      };

      security = {
        auth = {
          selectedType = "oauth-personal";
        };
      };
    };
  };
}
