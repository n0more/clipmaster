import AppKit
import SwiftUI
import Combine

@MainActor
class AppController {
    private var statusItem: NSStatusItem!
    private var historyWindow: NSWindow?
    private var addPromptWindow: NSWindow?
    private var setTemperatureWindow: NSWindow?
    private var promptsSettingsWindow: NSWindow?
    private var modelSelectionWindow: NSWindow?
    private var accessibilityAlertWindow: NSWindow?
    private var ollamaURLWindow: NSWindow?
    private var hotkeysSettingsWindow: NSWindow?
    private let container: RootContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: RootContainer) {
        self.container = container
        setupStatusItem()
        setupHotkeyListener()
        
        container.promptService.$prompts.sink { [weak self] _ in self?.buildMenu() }.store(in: &cancellables)
        container.promptService.$activePrompt.sink { [weak self] _ in self?.buildMenu() }.store(in: &cancellables)
        container.settingsService.$temperature.sink { [weak self] _ in self?.buildMenu() }.store(in: &cancellables)
        container.settingsService.$selectedModel.sink { [weak self] _ in self?.buildMenu() }.store(in: &cancellables)
        container.settingsService.$ollamaURL.sink { [weak self] _ in self?.buildMenu() }.store(in: &cancellables)
        
        // Fetch models on startup.
        Task {
            let apiURL = container.settingsService.ollamaURL
            let models = await container.ollamaService.fetchAvailableModels(apiURL: apiURL)
            container.settingsService.updateAvailableModels(models)
        }
    }

    // MARK: - Menu Setup
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "ClipMaster")
        }
        buildMenu()
    }
    
    private func buildMenu() {
        let menu = NSMenu()
        
        // --- Settings Section ---
        menu.addItem(NSMenuItem(title: "Settings", action: nil, keyEquivalent: ""))
        
        let hotkeysItem = NSMenuItem(title: "Configure Hotkeys...", action: #selector(showHotkeysSettingsWindow), keyEquivalent: "")
        hotkeysItem.target = self
        menu.addItem(hotkeysItem)
        
        let urlString = "Ollama URL: \(container.settingsService.ollamaURL)"
        let urlItem = NSMenuItem(title: urlString, action: #selector(showOllamaURLWindow), keyEquivalent: "")
        urlItem.target = self
        menu.addItem(urlItem)
        
        let modelString = "Model: \(container.settingsService.selectedModel.isEmpty ? "Not Set" : container.settingsService.selectedModel)"
        let modelItem = NSMenuItem(title: modelString, action: #selector(showModelSelectionWindow), keyEquivalent: "")
        modelItem.target = self
        menu.addItem(modelItem)
        
        let tempString = String(format: "Temperature: %.2f", container.settingsService.temperature)
        let tempItem = NSMenuItem(title: tempString, action: #selector(showSetTemperatureWindow), keyEquivalent: "")
        tempItem.target = self
        menu.addItem(tempItem)
        menu.addItem(NSMenuItem.separator())
        
        // --- Prompts Section ---
        menu.addItem(NSMenuItem(title: "Prompts", action: nil, keyEquivalent: ""))
        for prompt in container.promptService.prompts {
            let menuItem = NSMenuItem(title: prompt, action: #selector(promptSelected(_:)), keyEquivalent: "")
            menuItem.target = self
            if prompt == container.promptService.activePrompt { menuItem.state = .on }
            menu.addItem(menuItem)
        }
        menu.addItem(NSMenuItem.separator())
        let addPromptItem = NSMenuItem(title: "Add New Prompt...", action: #selector(showAddPromptWindow), keyEquivalent: "")
        addPromptItem.target = self
        menu.addItem(addPromptItem)

        let editPromptsItem = NSMenuItem(title: "Edit Prompts...", action: #selector(showPromptsSettingsWindow), keyEquivalent: "")
        editPromptsItem.target = self
        menu.addItem(editPromptsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Quit ClipMaster", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    
    @objc private func promptSelected(_ sender: NSMenuItem) {
        container.promptService.setActivePrompt(sender.title)
    }
    
    // MARK: - Window Management
    
    @objc private func showAddPromptWindow() {
        if let window = addPromptWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let addPromptView = AddPromptView(
            onSave: { [weak self] newPrompt in
                self?.container.promptService.addPrompt(newPrompt)
                self?.addPromptWindow?.close()
                self?.addPromptWindow = nil
                NSApp.setActivationPolicy(.accessory)
            },
            onCancel: { [weak self] in
                self?.addPromptWindow?.close()
                self?.addPromptWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        )
        
        let hostingController = NSHostingController(rootView: addPromptView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Add New Prompt"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.addPromptWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc private func showSetTemperatureWindow() {
        if let window = setTemperatureWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let setTempView = SetTemperatureView(
            initialTemperature: container.settingsService.temperature,
            onDone: { [weak self] in
                self?.setTemperatureWindow?.close()
                self?.setTemperatureWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        )
        .environmentObject(container.settingsService)
        
        let hostingController = NSHostingController(rootView: setTempView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Set Temperature"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.setTemperatureWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func showPromptsSettingsWindow() {
        if let window = promptsSettingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let promptsSettingsView = PromptsSettingsView(
            promptService: container.promptService,
            onDone: { [weak self] in
                self?.promptsSettingsWindow?.close()
                self?.promptsSettingsWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        )
        
        let hostingController = NSHostingController(rootView: promptsSettingsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Edit Prompts"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.promptsSettingsWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc private func showModelSelectionWindow() {
        if let window = modelSelectionWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let modelSelectionView = ModelSelectionView(
            settingsService: container.settingsService,
            onDone: { [weak self] in
                self?.modelSelectionWindow?.close()
                self?.modelSelectionWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        )
        
        let hostingController = NSHostingController(rootView: modelSelectionView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Select Model"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.modelSelectionWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc private func showOllamaURLWindow() {
        if let window = ollamaURLWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let urlView = OllamaURLView(
            settingsService: container.settingsService,
            onDone: { [weak self] in
                self?.ollamaURLWindow?.close()
                self?.ollamaURLWindow = nil
                NSApp.setActivationPolicy(.accessory)
                
                // Re-fetch models after URL change
                Task {
                    let apiURL = self?.container.settingsService.ollamaURL ?? ""
                    let models = await self?.container.ollamaService.fetchAvailableModels(apiURL: apiURL) ?? []
                    self?.container.settingsService.updateAvailableModels(models)
                }
            }
        )
        
        let hostingController = NSHostingController(rootView: urlView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Set Ollama URL"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.ollamaURLWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    @objc private func showHotkeysSettingsWindow() {
        if let window = hotkeysSettingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let hotkeysView = HotkeysSettingsView(
            settingsService: container.settingsService,
            onDone: { [weak self] in
                self?.hotkeysSettingsWindow?.close()
                self?.hotkeysSettingsWindow = nil
                NSApp.setActivationPolicy(.accessory)
            }
        )
        
        let hostingController = NSHostingController(rootView: hotkeysView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Configure Hotkeys"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        
        self.hotkeysSettingsWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Permissions
    
    func checkAccessibilityPermissions() {
        guard !AccessibilityService.hasPermissions() else { return }
        
        if let window = accessibilityAlertWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let alertView = AccessibilityAlertView()
        
        let hostingController = NSHostingController(rootView: alertView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Accessibility Access Needed"
        window.styleMask = [.titled]
        window.isReleasedWhenClosed = false
        
        self.accessibilityAlertWindow = window
        
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Hotkey & Window Management
    
    private func setupHotkeyListener() {
        // This is now handled by HotKeyService, which is initialized in RootContainer.
        // We just need to listen for the notifications.
        NotificationCenter.default
            .publisher(for: .toggleHistoryWindow)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.toggleHistoryWindowAtCursor()
            }
            .store(in: &cancellables)
            
        NotificationCenter.default
            .publisher(for: .processLastItemWithOllama)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.container.historyViewModel.processLastClipboardItem()
                }
            }
            .store(in: &cancellables)
            
        NotificationCenter.default
            .publisher(for: .selectPrompt1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.container.promptService.setActivePrompt(byIndex: 0)
            }
            .store(in: &cancellables)
            
        NotificationCenter.default
            .publisher(for: .selectPrompt2)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.container.promptService.setActivePrompt(byIndex: 1)
            }
            .store(in: &cancellables)
            
        NotificationCenter.default
            .publisher(for: .selectPrompt3)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.container.promptService.setActivePrompt(byIndex: 2)
            }
            .store(in: &cancellables)
    }

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
            window.makeFirstResponder(window.contentViewController?.view)
        }
    }

    private func createHistoryWindow() {
        let menuView = MenuBarView()
            .environmentObject(container.historyViewModel)
            .modelContainer(container.persistenceService.mainContext.container)

        let hostingController = NSHostingController(rootView: menuView)
        let viewSize = CGSize(width: 300, height: 400)
        hostingController.view.frame.size = viewSize
        
        let window = PopupPanel(
            contentRect: NSRect(origin: .zero, size: viewSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        
        self.historyWindow = window
    }
}