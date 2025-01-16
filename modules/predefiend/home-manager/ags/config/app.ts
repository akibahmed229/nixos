import { App } from "astal/gtk3";
import style from "./scss/style.scss";
import Bar from "./widget/bar/Bar";
import Applauncher from "./widget/launcher/Applauncher";
import NotificationPopups from "./widget/notification/NotificationPopups";
import OSD from "./widget/osd/osd";

App.start({
  css: style,
  instanceName: "app",
  requestHandler(request, res) {
    print(request);
    res("ok");
  },
  main() {
    App.get_monitors().map(Bar);
    App.get_monitors().map(NotificationPopups);
    App.get_monitors().map(OSD);
    Applauncher;
  },
});
