import AppKit
import GameController

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let menu = NSMenu()
let statusToggle = menu.addItem(withTitle: "Show Status Text", action: #selector(Clicker.toggle), keyEquivalent: "")
menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
// Pop the menu manually at the button's bottom edge: item.menu drops it with a gap.
class Clicker: NSObject {
    @objc func toggle() { UserDefaults.standard.set(!showStatus, forKey: "showStatus"); refresh() }
    @objc func click(_ b: NSStatusBarButton) { menu.appearance = NSApp.effectiveAppearance; menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: b) }
}
let clicker = Clicker()
item.button?.target = clicker
item.button?.action = #selector(Clicker.click(_:))
statusToggle.target = clicker
var showStatus: Bool { UserDefaults.standard.bool(forKey: "showStatus") }
// Sony's SST typeface is proprietary, so it's used only if the user has it installed.
let statusFont: NSFont = NSFontManager.shared.availableFontFamilies.first { $0.hasPrefix("SST") }
    .flatMap { NSFontManager.shared.font(withFamily: $0, traits: [], weight: 5, size: NSFont.menuBarFont(ofSize: 0).pointSize) }
    ?? NSFont.menuBarFont(ofSize: 0)
GCController.shouldMonitorBackgroundEvents = true

func symbol(_ name: String) -> NSAttributedString {
    let a = NSTextAttachment()
    a.image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
    return NSAttributedString(attachment: a)
}

func refresh() {
    statusToggle.state = showStatus ? .on : .off
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
    let status = charging ? "Charging" : full ? "Full" : "On battery"
    if showStatus { s.append(NSAttributedString(string: "\u{2009}" + status, attributes: [.font: statusFont])) }
    item.button?.attributedTitle = s
    item.button?.toolTip = status
}

for n in [Notification.Name.GCControllerDidConnect, .GCControllerDidDisconnect] {
    NotificationCenter.default.addObserver(forName: n, object: nil, queue: .main) { _ in refresh() }
}
// shortcut: polls every 30s since GCDeviceBattery has no change notification
Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in refresh() }
refresh()
app.run()
