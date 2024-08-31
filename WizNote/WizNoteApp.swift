import SwiftUI
import AppKit

@main
struct WizNoteApp: App {
    // Connects the AppDelegate to the SwiftUI app lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            // Define a Settings scene to satisfy the requirement for a Scene.
            // This won't create a window unless explicitly accessed by the user.
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item with a pencil icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            if let image = NSImage(named: "WizNoteIconx") {
                // Resize the image to fit the menu bar
                image.size = NSSize(width: 19, height: 19) // Adjust the size as needed
                button.image = image
            }
            button.action = #selector(togglePopover(_:))
        }

        // Set up the popover with a SwiftUI view
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.behavior = .transient
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
