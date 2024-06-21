const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const systemtray = await Service.import("systemtray");
import { NotificationPopups } from "./notificationPopups.js";
import { Media } from "./media.js";
import { applauncher } from "./applauncher.js";

// Utils.timeout(100, () =>
//   Utils.notify({
//     summary: "Notification Popup Example",
//     iconName: "info-symbolic",
//     body:
//       "Lorem ipsum dolor sit amet, qui minim labore adipisicing " +
//       "minim sint cillum sint consectetur cupidatat.",
//     actions: {
//       Cool: () => print("pressed Cool"),
//     },
//   }),
// );

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws
      .sort((a, b) => parseInt(a.id) - parseInt(b.id))
      .map(({ id }) =>
        Widget.Button({
          on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
          child: Widget.Label(`${id}`),
          class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
        }),
      ),
  );

  return Widget.Box({
    class_name: "workspaces",
    homogeneous: false,
    spacing: 1,
    children: workspaces,
  });
}

function ClientTitle() {
  return Widget.Label({
    class_name: "client-title",
    label: hyprland.active.client.bind("title"),
    justification: "left",
    truncate: "end",
    xalign: 0,
    wrap: true,
    maxWidthChars: 36,
  });
}

const date = Variable("", {
  poll: [1000, 'date "+%I:%M %b %e."'],
});

function Clock() {
  return Widget.Label({
    class_name: "clock",
    justification: "left",
    label: date.bind(),
  });
}

const calendar = Widget.Calendar({
  showDayNames: true,
  showDetails: true,
  showHeading: true,
  showWeekNumbers: true,
  detail: (self, y, m, d) => {
    return `<span color="white">${y}. ${m}. ${d}.</span>`;
  },
  onDaySelected: ({ date: [y, m, d] }) => {
    print(`${y}. ${m}. ${d}.`);
  },
});

// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
// function Notification() {
//   const popups = notifications.bind("popups");
//   return Widget.Box({
//     class_name: "notification",
//     visible: popups.as((p) => p.length > 0),
//     children: [
//       Widget.Icon({
//         icon: "preferences-system-notifications-symbolic",
//       }),
//       Widget.Label({
//         label: popups.as((p) => p[0]?.summary || ""),
//       }),
//     ],
//   });
// }

// function Media() {
//   const label = Utils.watch("", mpris, "player-changed", () => {
//     if (mpris.players[0]) {
//       const { track_artists, track_title } = mpris.players[0];
//       return `${track_artists.join(", ")} - ${track_title}`;
//     } else {
//       return "Nothing is playing";
//     }
//   });
//
//   return Widget.Button({
//     class_name: "media",
//     on_primary_click: () => mpris.getPlayer("")?.playPause(),
//     on_scroll_up: () => mpris.getPlayer("")?.next(),
//     on_scroll_down: () => mpris.getPlayer("")?.previous(),
//     child: Widget.Label({ label }),
//   });
// }

const win = Widget.Window({
  name: "mpris",
  css: `padding: 10px; border-radius: 12px; margin-top: 50px; border: 1px solid shade(@theme_fg_color, 0.7);`,
  anchor: ["top", "center"],
  child: Media(),
});

const Player = (player) =>
  Widget.Button({
    onClicked: () => {
      if (win.visible) return win.hide();
      else return win.show();
    },
    on_secondary_click: () => player.playPause(),
    child: Widget.Label({
      justification: "center",
      truncate: "end",
      wrap: true,
      maxWidthChars: 46,
    }).hook(player, (label) => {
      const { track_artists, track_title } = player;
      label.label = `${track_artists.join(", ")} - ${track_title}`;
    }),
  });

const players = Widget.Box({
  children: mpris.bind("players").as((p) => p.map(Player)),
});

function Volume() {
  const icons = {
    101: "overamplified",
    67: "high",
    34: "medium",
    1: "low",
    0: "muted",
  };

  function getIcon() {
    const icon = audio.speaker.is_muted
      ? 0
      : [101, 67, 34, 1, 0].find(
          (threshold) => threshold <= audio.speaker.volume * 100,
        );

    return `audio-volume-${icons[icon]}-symbolic`;
  }

  const icon = Widget.Icon({
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
  });

  const slider = Widget.Slider({
    hexpand: true,
    draw_value: false,
    on_change: ({ value }) => (audio.speaker.volume = value),
    setup: (self) =>
      self.hook(audio.speaker, () => {
        self.value = audio.speaker.volume || 0;
      }),
  });

  return Widget.Box({
    class_name: "volume",
    css: "min-width: 160px",
    children: [icon, slider],
  });
}

function BatteryLabel() {
  const value = battery.bind("percent").as((p) => (p > 0 ? p / 100 : 0));
  const icon = battery
    .bind("percent")
    .as((p) => `battery-level-${Math.floor(p / 10) * 10}-symbolic`);

  return Widget.Box({
    class_name: "battery",
    visible: battery.bind("available"),
    children: [
      Widget.Icon({ icon }),
      Widget.LevelBar({
        widthRequest: 140,
        vpack: "center",
        value,
      }),
    ],
  });
}
// System section
// System Tray
function SysTray() {
  const items = systemtray.bind("items").as((items) =>
    items.map((item) =>
      Widget.Button({
        child: Widget.Icon({ icon: item.bind("icon") }),
        on_primary_click: (_, event) => item.activate(event),
        on_secondary_click: (_, event) => item.openMenu(event),
        tooltip_markup: item.bind("tooltip_markup"),
      }),
    ),
  );

  return Widget.Box({
    children: items,
    spacing: 1,
  });
}
// System Monitor Widget (CPU, Memory, Disk, Network) etc
function SystemMonitor() {
  const cpuLabel = Widget.Label({
    label: "󰍛 : N/A%",
    css: "color: @error_color; opacity: 0.8",
  });
  const memoryLabel = Widget.Label({
    label: " : N/A MB",
    css: "color: @warning_color; opacity: 0.8",
  });
  const diskLabel = Widget.Label({
    label: " : N/A%",
  });
  const networkLabel = Widget.Label({
    label: "  N/A    N/A",
  });
  const temperatureLabel = Widget.Label({
    label: " : N/A°C",
  });
  const uptimeLabel = Widget.Label({
    label: " : N/A",
  });

  const widget = Widget.Box({
    spacing: 8,
    children: [cpuLabel, memoryLabel],
  });

  Utils.interval(1000, () => {
    const cpu = Utils.exec(`bash -c "top -bn1 | awk '/Cpu/ { print $2}'"`);
    const memory = Utils.exec(`bash -c "free -m | awk '/Mem/{print $3}'"`);
    const disk = Utils.exec(`bash -c "df -h | awk '/nvme1n1p2/ {print $5}'"`);
    const network = Utils.exec(
      `bash -c "cat /proc/net/dev | grep enp4s0 | awk '{print $2, $10}'"`,
    );
    const temperature = Utils.exec(
      `bash -c "sensors | grep Package | awk '{print $4}'"`,
    );
    const uptime = Utils.exec(`bash -c "uptime -p"`);

    // Update the labels with the new values
    cpuLabel.label = `󰍛 : ${parseInt(cpu)}%`;
    memoryLabel.label = ` : ${parseInt(memory)} MB`;
  });

  return widget;
}

function PowerMenu() {
  return Widget.Button({
    child: Widget.Icon({ icon: "system-shutdown-symbolic" }),
    on_primary_click: () => Utils.exec(`bash -c "wlogout"`),
  });
}

// layout of the bar
function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces(), ClientTitle()],
  });
}
function Center() {
  return Widget.Box({
    spacing: 8,
    children: [
      Player(mpris.players[0]),
      // Media(),
      // Notification()
    ],
  });
}
function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 6,
    children: [
      Volume(),
      BatteryLabel(),
      Clock(),
      SystemMonitor(),
      SysTray(),
      PowerMenu(),
    ],
  });
}
function Bar(monitor = 0) {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    class_name: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    margins: [1, 8],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Left(),
      center_widget: Center(),
      end_widget: Right(),
    }),
  });
}

// finally, we configure the app
App.config({
  style: "./style.css",
  windows: [
    Bar(),
    NotificationPopups(),
    applauncher,

    // you can call it, for each monitor
    // Bar(0),
    // Bar(1)
  ],
});

export {};
