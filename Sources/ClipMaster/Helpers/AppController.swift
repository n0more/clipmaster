import AppKit
import SwiftUI
import Combine

@MainActor
class AppController {
    private var statusItem: NSStatusItem!
    private var historyWindow: NSWindow?
    private let container: RootContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: RootContainer) {
        self.container = container
        setupStatusItem()
        setupHotkeyListener()
    }

    // MARK: - Setup Methods

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "ClipMaster")
        }
        
        let menu = NSMenu()
        menu.addItem(
            withTitle: "Quit ClipMaster",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem.menu = menu
    }

    private func setupHotkeyListener() {
        NotificationCenter.default
            .publisher(for: .toggleHistoryWindow)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.toggleHistoryWindowAtCursor()
            }
            .store(in: &cancellables)
    }

    // MARK: - Window Management

    private func toggleHistoryWindowAtCursor() {
        if historyWindow == nil {
            createHistoryWindow()
        }
        
        if let window = historyWindow, window.isVisible {
            window.close()
        } else {
            guard let window = historyWindow else { return }
            
            var mouseLocation = NSEvent.mouseLocation
            mouseLocation.y -= window.frame.height
            
            window.setFrameOrigin(mouseLocation)
            window.makeKeyAndOrderFront(nil)
            
            // CRITICAL FIX: Explicitly make our view the one that receives keyboard events.
            window.makeFirstResponder(window.contentViewController?.view)
        }
    }

    private func createHistoryWindow() {
        let menuView = MenuBarView()
            .environmentObject(container)
            .environmentObject(container.historyViewModel)
            .modelContainer(container.persistenceService.mainContext.container)

        let hostingController = NSHostingController(rootView: menuView)
        let viewSize = CGSize(width: 300, height: 400)
        hostingController.view.frame.size = viewSize
        
        // Use our custom PopupPanel.
        let window = PopupPanel(
            contentRect: NSRect(origin: .zero, size: viewSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        
        // Set to false to prevent the window from auto-hiding. We will control its closing manually.
        window.hidesOnDeactivate = false
        
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        
        self.historyWindow = window
    }

    // MARK: - Permissions

    public func checkAccessibilityPermissions() {
        #if !DEBUG
        let hasRequested = UserDefaults.standard.bool(forKey: "hasRequestedAccessibilityPermissions")
        if hasRequested { return }
        
        if !AccessibilityService.hasPermissions() {
            showPermissionsWindow()
        }
        
        UserDefaults.standard.set(true, forKey: "hasRequestedAccessibilityPermissions")
        #endif
    }
    
    private var permissionsWindow: NSWindow?
    private func showPermissionsWindow() {
        if permissionsWindow == nil {
            let swiftUIView = AccessibilityAlertView()
            let hostingController = NSHostingController(rootView: swiftUIView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Accessibility Permission"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = true
            window.center()
            self.permissionsWindow = window
        }
        permissionsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}