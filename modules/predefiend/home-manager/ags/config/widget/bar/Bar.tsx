import { App } from 'astal/gtk3'
import { Variable, GLib, bind } from 'astal'
import { Astal, Gtk, Gdk } from 'astal/gtk3'
import Hyprland from 'gi://AstalHyprland'
import Mpris from 'gi://AstalMpris'
import Battery from 'gi://AstalBattery'
import Wp from 'gi://AstalWp'
import Network from 'gi://AstalNetwork'
import Tray from 'gi://AstalTray'

function SysTray() {
    const tray = Tray.get_default()

    return (
        <box className="SysTray">
            {bind(tray, 'items').as((items) =>
                items.map((item) => (
                    <menubutton
                        tooltipMarkup={bind(item, 'tooltipMarkup')}
                        usePopover={false}
                        actionGroup={bind(item, 'action-group').as((ag) => [
                            'dbusmenu',
                            ag,
                        ])}
                        menuModel={bind(item, 'menu-model')}
                    >
                        <icon gicon={bind(item, 'gicon')} />
                    </menubutton>
                )),
            )}
        </box>
    )
}

function Wifi() {
    const network = Network.get_default()
    const wifi = bind(network, 'wifi')

    return (
        <box visible={wifi.as(Boolean)}>
            {wifi.as(
                (wifi) =>
                    wifi && (
                        <icon
                            tooltipText={bind(wifi, 'ssid').as(String)}
                            className="Wifi"
                            icon={bind(wifi, 'iconName')}
                        />
                    ),
            )}
        </box>
    )
}

function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return (
        <box className="AudioSlider" css="min-width: 140px">
            <icon icon={bind(speaker, 'volumeIcon')} />
            <slider
                hexpand
                onDragged={({ value }) => (speaker.volume = value)}
                value={bind(speaker, 'volume')}
            />
        </box>
    )
}

function BatteryLevel() {
    const bat = Battery.get_default()

    return (
        <box className="Battery" visible={bind(bat, 'isPresent')}>
            <icon icon={bind(bat, 'batteryIconName')} />
            <label
                label={bind(bat, 'percentage').as((p) => `${Math.floor(p * 100)} %`)}
            />
        </box>
    )
}

function Media() {
    const mpris = Mpris.get_default()

    return (
        <box className="Media">
            {bind(mpris, 'players').as((ps) =>
                ps[0] ? (
                    // <box>
                    <box
                        className="Cover"
                        valign={Gtk.Align.CENTER}
                        tooltipMarkup={bind(ps[0], 'title').as(
                            (title) => `${title} - ${ps[0].artist}`,
                        )}
                        css={bind(ps[0], 'coverArt').as(
                            (cover) => `background-image: url('${cover}');`,
                        )}
                    />
                ) : (
                    //<label
                    //  label={bind(ps[0], "title").as(
                    //    () => `${ps[0].title} - ${ps[0].artist}`,
                    //  )}
                    //  justification="right"
                    //  truncate="end"
                    //  wrap={true}
                    //  xalign={0}
                    //  maxWidthChars={18}
                    ///>
                    // </box>
                    '🎵'
                ),
            )}
        </box>
    )
}

function Workspaces() {
    const hypr = Hyprland.get_default()

    return (
        <box className="Workspaces">
            {bind(hypr, 'workspaces').as((wss) =>
                wss
                    .filter((ws) => !(ws.id >= -99 && ws.id <= -2)) // filter out special workspaces
                    .sort((a, b) => a.id - b.id)
                    .map((ws) => (
                        <button
                            className={bind(hypr, 'focusedWorkspace').as((fw) =>
                                ws === fw ? 'focused' : '',
                            )}
                            onClicked={() => ws.focus()}
                        >
                            {ws.id}
                        </button>
                    )),
            )}
        </box>
    )
}

function FocusedClient() {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, 'focusedClient')

    return (
        <box className="Focused" visible={focused.as(Boolean)}>
            {focused.as(
                (client) =>
                    client && (
                        <label
                            label={bind(client, 'title').as(String)}
                            tooltipMarkup={bind(client, 'title').as(String)}
                            justification="left"
                            truncate="end"
                            xalign={0}
                            wrap={true}
                            maxWidthChars={26}
                        />
                    ),
            )}
        </box>
    )
}

function Time({ format = '%A %I:%M %p,  %B %d.' }) {
    const time = Variable<string>('').poll(
        1000,
        () => GLib.DateTime.new_now_local().format(format)!,
    )

    return <label className="Time" onDestroy={() => time.drop()} label={time()} />
}

export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return (
        <window
            className="Bar"
            gdkmonitor={monitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            margin-top={8}
            margin-bottom={0}
            margin-left={8}
            margin-right={8}
            anchor={TOP | LEFT | RIGHT}
        >
            <centerbox>
                <box hexpand halign={Gtk.Align.START}>
                    <Workspaces />
                    <FocusedClient />
                </box>
                <box>
                    <Time />
                </box>
                <box hexpand halign={Gtk.Align.END}>
                    {/* <Wifi /> */}
                    <Media />
                    <AudioSlider />
                    <BatteryLevel />
                    <SysTray />
                </box>
            </centerbox>
        </window>
    )
}
