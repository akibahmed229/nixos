{pkgs, ...}: {
  plugins.lualine = {
    enable = true;

    componentSeparators = {
      left = "";
      right = "";
    };

    sectionSeparators = {
      left = "";
      right = "";
    };

    sections = {
      lualine_c = [
        {
          name = "filename";

          extraConfig = {
            path = 1;
          };
        }
      ];
    };
  };
}
