// system import
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Active theme selector (switch here to change)
    property Item get: gruvbox

    // ==============================
    // Gruvbox Dark (Soft)
    // ==============================
    Item {
        id: gruvbox

        // Base palette
        property string base00: "#32302f" // bg
        property string base01: "#3c3836"
        property string base02: "#504945"
        property string base03: "#665c54"
        property string base04: "#bdae93"
        property string base05: "#d5c4a1"
        property string base06: "#ebdbb2"
        property string base07: "#fbf1c7"
        property string red: "#fb4934"
        property string orange: "#fe8019"
        property string yellow: "#fabd2f"
        property string green: "#b8bb26"
        property string aqua: "#8ec07c"
        property string blue: "#83a598"
        property string purple: "#d3869b"
        property string brown: "#d65d0e"

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base06               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: green
        property string errorColor: red
        property string warningColor: yellow
        property string infoColor: aqua
        property string accentColor: orange             // highlight/accent

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base06
        property string iconColor: green
        property string iconPressedColor: orange
        property bool buttonBorderShadow: true
        property bool onTop: true
    }

    // ==============================
    // Rosé Pine
    // ==============================
    Item {
        id: rosePine

        // Base palette
        property string base00: "#191724" // bg
        property string base01: "#1f1d2e"
        property string base02: "#26233a"
        property string base03: "#555169"
        property string base04: "#6e6a86"
        property string base05: "#e0def4"
        property string base06: "#f0f0f3"
        property string base07: "#c5c3ce"
        property string base08: "#e2e1e7"
        property string base09: "#eb6f92" // red / pink
        property string base0A: "#f6c177" // yellow / orange
        property string base0B: "#ebbcba" // peach / greenish tone
        property string base0C: "#31748f" // teal / aqua
        property string base0D: "#9ccfd8" // cyan / blue
        property string base0E: "#c4a7e7" // lavender / purple
        property string base0F: "#e5e5e5"

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base05               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: base0B
        property string errorColor: base09
        property string warningColor: base0A
        property string infoColor: base0C
        property string accentColor: base0E             // highlight/accent

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base05
        property string iconColor: base0D
        property string iconPressedColor: base09
        property bool buttonBorderShadow: true
        property bool onTop: true
    }

    // ==============================
    // Catppuccin Mocha
    // ==============================
    Item {
        id: catppuccinMocha

        // Base palette
        property string base00: "#1e1e2e" // base
        property string base01: "#181825" // mantle
        property string base02: "#313244" // surface0
        property string base03: "#45475a" // surface1
        property string base04: "#585b70" // surface2
        property string base05: "#cdd6f4" // text
        property string base06: "#f5e0dc" // rosewater
        property string base07: "#b4befe" // lavender
        property string base08: "#f38ba8" // red
        property string base09: "#fab387" // peach
        property string base0A: "#f9e2af" // yellow
        property string base0B: "#a6e3a1" // green
        property string base0C: "#94e2d5" // teal
        property string base0D: "#89b4fa" // blue
        property string base0E: "#cba6f7" // mauve
        property string base0F: "#f2cdcd" // flamingo

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base05               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: base0B
        property string errorColor: base08
        property string warningColor: base0A
        property string infoColor: base0D
        property string accentColor: base0E             // highlight/accent

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base05
        property string iconColor: base0D
        property string iconPressedColor: base09
        property bool buttonBorderShadow: true
        property bool onTop: true
    }

    // ==============================
    // Nord
    // ==============================
    Item {
        id: nord

        // Base palette
        property string base00: "#2E3440" // Polar Night 0
        property string base01: "#3B4252" // Polar Night 1
        property string base02: "#434C5E" // Polar Night 2
        property string base03: "#4C566A" // Polar Night 3
        property string base04: "#D8DEE9" // Snow Storm 0
        property string base05: "#E5E9F0" // Snow Storm 1
        property string base06: "#ECEFF4" // Snow Storm 2
        property string base07: "#8FBCBB" // Frost 0
        property string base08: "#BF616A" // Red
        property string base09: "#D08770" // Orange
        property string base0A: "#EBCB8B" // Yellow
        property string base0B: "#A3BE8C" // Green
        property string base0C: "#88C0D0" // Frost 1 (Cyan)
        property string base0D: "#81A1C1" // Frost 2 (Blue)
        property string base0E: "#B48EAD" // Purple
        property string base0F: "#5E81AC" // Frost 3 (Dark Blue)

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base05               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: base0B
        property string errorColor: base08
        property string warningColor: base0A
        property string infoColor: base0D
        property string accentColor: base0C             // highlight/accent

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base05
        property string iconColor: base0C
        property string iconPressedColor: base09
        property bool buttonBorderShadow: true
        property bool onTop: true
    }

    // ==============================
    // Darcula
    // ==============================
    Item {
        id: darcula

        // Base palette
        property string base00: "#2b2b2b" // background
        property string base01: "#323232" // line cursor
        property string base02: "#323232" // statusline
        property string base03: "#606366" // line numbers
        property string base04: "#a4a3a3" // selected line number
        property string base05: "#a9b7c6" // foreground
        property string base06: "#ffc66d" // function bright yellow
        property string base07: "#ffffff" // pure white
        property string base08: "#4eade5" // cyan
        property string base09: "#689757" // blue
        property string base0A: "#bbb529" // yellow
        property string base0B: "#6a8759" // string green
        property string base0C: "#629755" // comment green
        property string base0D: "#9876aa" // purple
        property string base0E: "#cc7832" // orange
        property string base0F: "#808080" // gray

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base05               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: base0B
        property string errorColor: base0E
        property string warningColor: base0A
        property string infoColor: base08
        property string accentColor: base06             // highlight/accent

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base05
        property string iconColor: base06
        property string iconPressedColor: base0E
        property bool buttonBorderShadow: true
        property bool onTop: true
    }

    // ==============================
    // Everforest
    // ==============================
    Item {
        id: everforest

        // Base palette
        property string base00: "#2f383e" // bg0 (dark medium)
        property string base01: "#374247" // bg1
        property string base02: "#4a555b" // bg3
        property string base03: "#859289" // grey1
        property string base04: "#9da9a0" // grey2
        property string base05: "#d3c6aa" // fg
        property string base06: "#e4e1cd" // bg3 (light medium)
        property string base07: "#fdf6e3" // bg0 (light medium)
        property string base08: "#7fbbb3" // blue
        property string base09: "#d699b6" // purple
        property string base0A: "#dbbc7f" // yellow
        property string base0B: "#83c092" // aqua
        property string base0C: "#e69875" // orange
        property string base0D: "#a7c080" // green
        property string base0E: "#e67e80" // red
        property string base0F: "#eaedc8" // bg_visual

        // Semantic palette
        property string bgColor: base00
        property string fbColor: base01                 // foreground box bg
        property string textColor: base05               // primary text
        property string hoverColor: base02              // hover background
        property string successColor: base0D
        property string errorColor: base0E
        property string warningColor: base0A
        property string infoColor: base08
        property string accentColor: base0C             // orange highlight

        // Utility
        property string whiteColor: "#ffffff"
        property string blackColor: "#000000"
        property string transparent: "#00000000"

        // Component-specific (good practice)
        property string buttonBackground: base01
        property string buttonHover: base02
        property string buttonBorder: base03
        property string buttonText: base05
        property string iconColor: base08
        property string iconPressedColor: base0C
        property bool buttonBorderShadow: true
        property bool onTop: true
    }
}
