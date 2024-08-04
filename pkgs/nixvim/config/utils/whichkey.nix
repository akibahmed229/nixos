{
  plugins.mini.enable = true;
  plugins.which-key = {
    enable = true;
    ignoreMissing = false; # enable this to hide mappings for which you didn't specify a label
    showHelp = true; # show help message on the command line when the popup is visible
    keyLabels = {};
    icons = {
      breadcrumb = "»";
      separator = "➜";
      group = "+";
    };
    popupMappings = {
      scrollDown = "<c-d>";
      scrollUp = "<c-u>";
    };
    window = {
      border = "single"; # none, single, double, shadow
      position = "bottom"; # bottom, top
      winblend = 0;
    };
    layout = {
      height = {
        min = 4;
        max = 25;
      }; # min and max height of the columns
      width = {
        min = 20;
        max = 50;
      }; # min and max width of the columns
      spacing = 3; # spacing between columns
      align = "left"; # align columns left, center or right
    };
  };
}
