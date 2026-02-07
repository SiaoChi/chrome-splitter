import AppKit
import ApplicationServices

enum WindowDestination {
    case left
    case right
    case full
}

enum MoveWindowResult {
    case success
    case accessibilityPermissionMissing
    case frontAppNotChrome
    case windowNotFound
    case failedToSetFrame
}

final class WindowSnapper {
    func moveFrontmostChromeWindow(to destination: WindowDestination) -> MoveWindowResult {
        guard AXIsProcessTrusted() else {
            return .accessibilityPermissionMissing
        }

        guard let app = NSWorkspace.shared.frontmostApplication,
              app.bundleIdentifier == "com.google.Chrome" else {
            return .frontAppNotChrome
        }

        let appElement = AXUIElementCreateApplication(app.processIdentifier)

        guard let window = focusedWindow(for: appElement) else {
            return .windowNotFound
        }

        guard let screen = targetScreen(for: window),
              let targetRect = targetRect(on: screen, destination: destination) else {
            return .failedToSetFrame
        }

        let topY = NSScreen.screens.map { $0.frame.maxY }.max() ?? screen.frame.maxY
        let axOrigin = CGPoint(x: targetRect.minX, y: topY - targetRect.maxY)

        var position = axOrigin
        var size = CGSize(width: targetRect.width, height: targetRect.height)

        guard let positionValue = AXValueCreate(.cgPoint, &position),
              let sizeValue = AXValueCreate(.cgSize, &size) else {
            return .failedToSetFrame
        }

        let setPositionStatus = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        let setSizeStatus = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)

        return (setPositionStatus == .success && setSizeStatus == .success) ? .success : .failedToSetFrame
    }

    private func focusedWindow(for appElement: AXUIElement) -> AXUIElement? {
        var focusedWindowRef: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindowRef)
        guard status == .success,
              let focusedWindowRef,
              CFGetTypeID(focusedWindowRef) == AXUIElementGetTypeID() else {
            return nil
        }

        return (focusedWindowRef as! AXUIElement)
    }

    private func targetScreen(for window: AXUIElement) -> NSScreen? {
        guard let position = axPoint(for: kAXPositionAttribute, in: window),
              let size = axSize(for: kAXSizeAttribute, in: window) else {
            return NSScreen.main
        }

        let cocoaCenter = cocoaCenterPointFromAX(position: position, size: size)
        return NSScreen.screens.first { $0.frame.contains(cocoaCenter) } ?? NSScreen.main
    }

    private func targetRect(on screen: NSScreen, destination: WindowDestination) -> CGRect? {
        let visible = screen.visibleFrame.integral
        guard visible.width > 0, visible.height > 0 else {
            return nil
        }

        switch destination {
        case .left:
            return CGRect(x: visible.minX, y: visible.minY, width: visible.width / 2, height: visible.height)
        case .right:
            return CGRect(x: visible.minX + (visible.width / 2), y: visible.minY, width: visible.width / 2, height: visible.height)
        case .full:
            return visible
        }
    }

    private func cocoaCenterPointFromAX(position: CGPoint, size: CGSize) -> CGPoint {
        let topY = NSScreen.screens.map { $0.frame.maxY }.max() ?? 0
        let cocoaMinY = topY - (position.y + size.height)
        return CGPoint(x: position.x + (size.width / 2), y: cocoaMinY + (size.height / 2))
    }

    private func axPoint(for attribute: String, in element: AXUIElement) -> CGPoint? {
        var valueRef: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(element, attribute as CFString, &valueRef)
        guard status == .success,
              let valueRef,
              CFGetTypeID(valueRef) == AXValueGetTypeID() else {
            return nil
        }

        let value = valueRef as! AXValue
        guard AXValueGetType(value) == .cgPoint else {
            return nil
        }

        var point = CGPoint.zero
        guard AXValueGetValue(value, .cgPoint, &point) else {
            return nil
        }
        return point
    }

    private func axSize(for attribute: String, in element: AXUIElement) -> CGSize? {
        var valueRef: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(element, attribute as CFString, &valueRef)
        guard status == .success,
              let valueRef,
              CFGetTypeID(valueRef) == AXValueGetTypeID() else {
            return nil
        }

        let value = valueRef as! AXValue
        guard AXValueGetType(value) == .cgSize else {
            return nil
        }

        var size = CGSize.zero
        guard AXValueGetValue(value, .cgSize, &size) else {
            return nil
        }
        return size
    }
}
