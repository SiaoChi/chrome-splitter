import AppKit
import ApplicationServices
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowSnapper = WindowSnapper()
    private let hotKeyManager = HotKeyManager()
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = requestAccessibilityPermission()
        setupStatusBar()
        setupHotKeys()
    }

    private func requestAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func setupStatusBar() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = makeStatusBarImage()
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Left", action: #selector(moveLeft), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Right", action: #selector(moveRight), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Full", action: #selector(moveFull), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        menu.items.forEach { $0.target = self }
        item.menu = menu
        statusItem = item
    }

    private func makeStatusBarImage() -> NSImage {
        let fallback = NSImage(systemSymbolName: "rectangle.split.2x1", accessibilityDescription: "Chrome Splitter")

        let candidateURLs: [URL?] = [
            Bundle.main.resourceURL?.appendingPathComponent("chromesplitter_logo.png"),
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("dist/chromesplitter_logo.png")
        ]

        for url in candidateURLs.compactMap({ $0 }) {
            if let image = NSImage(contentsOf: url) {
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = false
                image.accessibilityDescription = "Chrome Splitter"
                return image
            }
        }

        return fallback ?? NSImage()
    }

    private func setupHotKeys() {
        hotKeyManager.register(keyCode: UInt32(kVK_LeftArrow), modifiers: UInt32(controlKey | optionKey)) { [weak self] in
            self?.move(.left)
        }

        hotKeyManager.register(keyCode: UInt32(kVK_RightArrow), modifiers: UInt32(controlKey | optionKey)) { [weak self] in
            self?.move(.right)
        }

        hotKeyManager.register(keyCode: UInt32(kVK_UpArrow), modifiers: UInt32(controlKey | optionKey)) { [weak self] in
            self?.move(.full)
        }
    }

    @objc private func moveLeft() {
        move(.left)
    }

    @objc private func moveRight() {
        move(.right)
    }

    @objc private func moveFull() {
        move(.full)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func move(_ destination: WindowDestination) {
        switch windowSnapper.moveFrontmostChromeWindow(to: destination) {
        case .success:
            return
        case .accessibilityPermissionMissing:
            _ = requestAccessibilityPermission()
            NSSound.beep()
        case .frontAppNotChrome, .windowNotFound, .failedToSetFrame:
            NSSound.beep()
        }
    }
}
