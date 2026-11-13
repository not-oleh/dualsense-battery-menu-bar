# DualSense Battery Menu Bar

A tiny macOS menu bar app that shows the battery level of a connected PS5 DualSense controller (Bluetooth or USB), plus a bolt icon while charging.

## Install

Download `DualSenseBattery.zip` from [Releases](../../releases), unzip, then:

```bash
xattr -d com.apple.quarantine DualSenseBattery && ./DualSenseBattery
```

(The binary is unsigned, so the quarantine flag must be removed.)

To start at login: System Settings → General → Login Items → add `DualSenseBattery`.

## Build from source

```bash
swiftc -O main.swift -o DualSenseBattery
```

Click the icon → "Show Status Text" to also show Charging / Full / On battery. If Sony's SST font is installed, it's used for that text (not bundled — it's proprietary).

Requires macOS 11.3+. Uses Apple's GameController framework; refreshes every 30 s.
