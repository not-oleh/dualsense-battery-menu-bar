import AppKit
import GameController

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let menu = NSMenu()
menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
item.menu = menu
GCController.shouldMonitorBackgroundEvents = true

func symbol(_ name: String) -> NSAttributedString {
    let a = NSTextAttachment()
    a.image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
    return NSAttributedString(attachment: a)
}

func refresh() {
    let s = NSMutableAttributedString(attributedString: symbol("gamecontroller"))
    guard let b = GCController.controllers().compactMap(\.battery).first else {
        s.append(NSAttributedString(string: "\u{2009}–"))
        item.button?.attributedTitle = s
        return
    }
    let pct = Int((b.batteryLevel * 100).rounded())
    let charging = b.batteryState == .charging
    let full = b.batteryState == .full
    let bars = [0, 25, 50, 75, 100].min { abs($0 - pct) < abs($1 - pct) }!
    s.append(NSAttributedString(string: "\u{2009}\(pct)%\u{2009}"))
    s.append(symbol(charging || full ? "battery.100.bolt" : "battery.\(bars)"))
    item.button?.attributedTitle = s
    item.button?.toolTip = charging ? "Charging" : full ? "Full" : "On battery"
}

for n in [Notification.Name.GCControllerDidConnect, .GCControllerDidDisconnect] {
    NotificationCenter.default.addObserver(forName: n, object: nil, queue: .main) { _ in refresh() }
}
// shortcut: polls every 30s since GCDeviceBattery has no change notification
Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in refresh() }
refresh()
app.run()
