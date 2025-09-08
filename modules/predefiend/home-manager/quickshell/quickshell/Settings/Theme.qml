pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property Item get: nordic

    Item {
        id: black

        property string barBgColor: "#cc000000"
        property string buttonBorderColor: "#BBBBBB"
        property string buttonBackgroundColor: "#222222"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "blue"
        property string iconPressedColor: "dark_blue"
    }

    Item {
        id: nordic

        // Nord color palette
        property string barBgColor: "#aa2E3440"  // Nord0 - Polar Night
        property string buttonBorderColor: "#4C566A"  // Nord3 - Polar Night
        property string buttonBackgroundColor: "#3D4550"
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#88C0D0"  // Nord7 - Frost
        property string iconPressedColor: "#81A1C1"  // Nord9 - Frost
    }

    Item {
        id: cyberpunk

        // Tokyo Neon color palette
        property string barBgColor: "#881A0B2E"  // Deep purple-black
        property string buttonBorderColor: "#FF2A6D"  // Neon pink
        property string buttonBackgroundColor: "#1A1A2E"  // Dark blue-black
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#05D9E8"  // Electric blue
        property string iconPressedColor: "#FF2A6D"  // Neon pink
    }

    Item {
        id: material

        // Material Design 3 color palette
        property string barBgColor: "#cc1F1F1F"  // Surface dark
        property string buttonBorderColor: "#2D2D2D"  // Surface variant
        property string buttonBackgroundColor: "#2D2D2D"  // Surface variant
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#90CAF9"  // Primary light
        property string iconPressedColor: "#64B5F6"  // Primary medium
    }

    Item {
        id: catppuccin

        // Catppuccin Mocha color palette
        property string barBgColor: "#aa1E1E2E"  // Base
        property string buttonBorderColor: "#313244"  // Surface0
        property string buttonBackgroundColor: "#313244"  // Surface0
        property bool buttonBorderShadow: true
        property bool onTop: true
        property string iconColor: "#89B4FA"  // Blue
        property string iconPressedColor: "#74C7EC"  // Sapphire
    }
}
