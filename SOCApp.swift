//
//  SOCApp.swift
//  SOC
//
//  Created on 30/10/2025.
//

import SwiftUI
import AppKit

@main
struct SOCApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class PopoverState: ObservableObject {
    @Published var shouldRefresh = false
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var eventMonitor: Any?
    private let popoverState = PopoverState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configura l'icona nella menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "shield.lefthalf.filled", accessibilityDescription: "SOC")
            image?.isTemplate = true
            button.image = image
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.toolTip = "SOC — Security Operations Center"
        }

        // Configura il popover con lo state observable
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 380, height: 420)
        popover.contentViewController = NSHostingController(rootView: LookupView(popoverState: popoverState))
        
        // L'app appare solo nella menu bar, non nel Dock
        NSApp.setActivationPolicy(.accessory)

        // Monitor per chiudere il popover quando si clicca fuori
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }
        
        // Menu contestuale per click destro sull'icona
        setupContextMenu()
    }
    
    private func setupContextMenu() {
        let menu = NSMenu()
        let localization = LocalizationManager.shared
        
        menu.addItem(NSMenuItem(title: localization.getString(.openButton), action: #selector(showPopover), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        // Opzione Cronologia
        let historyItem = NSMenuItem(title: "Cronologia Ricerche...", action: #selector(showHistory), keyEquivalent: "h")
        historyItem.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: nil)
        menu.addItem(historyItem)
        
        // Opzione Gestione Servizi
        let servicesItem = NSMenuItem(title: "Gestione Servizi...", action: #selector(showServiceSettings), keyEquivalent: "s")
        servicesItem.image = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
        menu.addItem(servicesItem)
        
        // Opzione Language Settings
        let languageItem = NSMenuItem(title: "Language / Lingua...", action: #selector(showLanguageSettings), keyEquivalent: "l")
        languageItem.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        menu.addItem(languageItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: localization.getString(.aboutTitle), action: #selector(showAbout), keyEquivalent: "")
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: localization.getString(.quitButton), action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.button?.menu = menu
    }
    
    @objc private func showHistory() {
        // Questo aprirà la cronologia attraverso la view principale
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.post(name: NSNotification.Name("ShowHistory"), object: nil)
    }
    
    @objc private func showServiceSettings() {
        let windowController = ServiceSettingsWindowController()
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showLanguageSettings() {
        let windowController = LanguageSettingsWindowController()
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showPopover() {
        if let button = statusItem.button {
            // Notifica la view di ricaricare la clipboard
            popoverState.shouldRefresh.toggle()
            
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func showAbout() {
        let localization = LocalizationManager.shared
        let alert = NSAlert()
        alert.messageText = localization.getString(.aboutTitle)
        alert.informativeText = localization.getString(.aboutMessage)
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
