//
//  BrowserManager.swift
//  SOC
//
//  Browser detection and management
//

import Foundation
import AppKit

// MARK: - Browser Model

struct Browser: Identifiable, Equatable {
    let id: String
    let name: String
    let bundleId: String
    let path: String
    let icon: NSImage?
    
    init(name: String, bundleId: String, path: String) {
        self.id = bundleId
        self.name = name
        self.bundleId = bundleId
        self.path = path
        self.icon = NSWorkspace.shared.icon(forFile: path)
    }
}

// MARK: - Browser Manager

class BrowserManager: ObservableObject {
    static let shared = BrowserManager()
    
    @Published var availableBrowsers: [Browser] = []
    @Published var selectedBrowser: Browser?
    
    private let storageKey = "selectedBrowserId"
    
    // Browser comuni da cercare
    private let knownBrowsers: [(String, String, String)] = [
        ("Safari", "com.apple.Safari", "/Applications/Safari.app"),
        ("Google Chrome", "com.google.Chrome", "/Applications/Google Chrome.app"),
        ("Firefox", "org.mozilla.firefox", "/Applications/Firefox.app"),
        ("Brave Browser", "com.brave.Browser", "/Applications/Brave Browser.app"),
        ("Microsoft Edge", "com.microsoft.edgemac", "/Applications/Microsoft Edge.app"),
        ("Opera", "com.operasoftware.Opera", "/Applications/Opera.app"),
        ("Arc", "company.thebrowser.Browser", "/Applications/Arc.app"),
        ("Vivaldi", "com.vivaldi.Vivaldi", "/Applications/Vivaldi.app"),
        ("DuckDuckGo", "com.duckduckgo.macos.browser", "/Applications/DuckDuckGo.app")
    ]
    
    private init() {
        detectBrowsers()
        loadSelectedBrowser()
    }
    
    // MARK: - Detection
    
    func detectBrowsers() {
        var browsers: [Browser] = []
        let fileManager = FileManager.default
        
        for (name, bundleId, path) in knownBrowsers {
            if fileManager.fileExists(atPath: path) {
                let browser = Browser(name: name, bundleId: bundleId, path: path)
                browsers.append(browser)
            }
        }
        
        // Se non ci sono browser, aggiungi Safari come fallback
        if browsers.isEmpty {
            browsers.append(Browser(
                name: "Safari",
                bundleId: "com.apple.Safari",
                path: "/Applications/Safari.app"
            ))
        }
        
        availableBrowsers = browsers
        
        // Se non c'è un browser selezionato, usa il primo disponibile
        if selectedBrowser == nil || !browsers.contains(where: { $0.id == selectedBrowser?.id }) {
            selectedBrowser = browsers.first
        }
    }
    
    // MARK: - Selection
    
    func selectBrowser(_ browser: Browser) {
        selectedBrowser = browser
        UserDefaults.standard.set(browser.id, forKey: storageKey)
    }
    
    private func loadSelectedBrowser() {
        if let savedId = UserDefaults.standard.string(forKey: storageKey),
           let browser = availableBrowsers.first(where: { $0.id == savedId }) {
            selectedBrowser = browser
        } else {
            selectedBrowser = availableBrowsers.first
        }
    }
    
    // MARK: - Open URL
    
    func openURL(_ url: URL, inBackground: Bool = true) {
        guard let browser = selectedBrowser else {
            // Fallback al browser di sistema
            NSWorkspace.shared.open(url)
            return
        }
        
        let config = NSWorkspace.OpenConfiguration()
        config.activates = !inBackground
        
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: URL(fileURLWithPath: browser.path),
            configuration: config
        ) { _, error in
            if let error = error {
                print("Errore apertura browser: \(error.localizedDescription)")
                // Fallback
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func openURLs(_ urls: [URL], inBackground: Bool = true) {
        for url in urls {
            openURL(url, inBackground: inBackground)
        }
    }
    
    // MARK: - Default Browser
    
    func getDefaultBrowser() -> Browser? {
        // Ottieni il browser di default del sistema
        if let defaultBrowserURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://")!) {
            let path = defaultBrowserURL.path
            if let browser = availableBrowsers.first(where: { $0.path == path }) {
                return browser
            }
        }
        return nil
    }
    
    func useSystemDefault() {
        if let defaultBrowser = getDefaultBrowser() {
            selectBrowser(defaultBrowser)
        }
    }
}
