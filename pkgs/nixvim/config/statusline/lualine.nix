{
  plugins.lualine = {
    enable = true;
    theme = "nord";

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
